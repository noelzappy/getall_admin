import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class PayoutsScreen extends StatefulWidget {
  final Function(bool) waits;
  const PayoutsScreen({required this.waits});

  @override
  _PayoutsScreenState createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerPayout = TextEditingController();
  final _controllerSearch = TextEditingController();
  final _controllerComment = TextEditingController();
  final List<ComboData> _sortData = [];
  String _sortDataValue = "";
  final ScrollController _controllerScroll = ScrollController();
  late MainModel _mainModel;

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerPayout.dispose();
    _controllerSearch.dispose();
    _controllerComment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _sortDataValue = "timeDesc";
    _sortData.add(ComboData(strings.get(278), "nameAsc")); /// Name Ascend
    _sortData.add(ComboData(strings.get(279), "nameDesc")); /// Name Descend
    _sortData.add(ComboData(strings.get(274), "timeDesc")); /// Time Descend
    _sortData.add(ComboData(strings.get(275), "timeAsc")); /// Time Ascend
    _sortData.add(ComboData(strings.get(277), "totalAsc")); /// Total Ascend
    _sortData.add(ComboData(strings.get(276), "totalDesc")); /// Total Descend
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.waits(true);
      var ret = await _mainModel.provider.loadPayout(context);
      if (ret != null)
        messageError(context, ret);
      widget.waits(false);
    });
    super.initState();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: _getList(),
        ),
    );
  }

  _getList(){
    List<Widget> list = [];
    list.add(SizedBox(height: 10,));
    list.add(Row(
      children: [
        Expanded(child: SelectableText(strings.get(272), /// "Providers Payouts",
          style: theme.style25W800,)),
      ],
    ));
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    addButtonsCopyExportSearch(list, _copy, _csv, isMobile(), strings.langCopyExportSearch, _onSearch,
        _pRange, (String value){_pRange = int.parse(value); setState(() {});} );

    list.add(SizedBox(height: 10,));
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(strings.get(253), style: theme.style14W400,), /// "Sort by",
        Container(
            width: 200,
            child: Combo(inRow: true, text: "",
              data: _sortData,
              value: _sortDataValue,
              onChange: (String value){
                _sortDataValue = value;
                _mainModel.provider.payoutsSort(value, context);
                setState(() {
                });
              },)),
      ],
    ));

    int _visibleCount = 0;

    List<DataRow> _cells = [];
    for (var item in _mainModel.provider.payout){
      if (!_mainModel.getTextByLocale(item.providerName).toUpperCase().contains(_searchedValue.toUpperCase()))
        continue;
      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;

      _cells.add(DataRow(cells: [
        // name
        DataCell(Container(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_mainModel.getTextByLocale(item.providerName),
              overflow: TextOverflow.ellipsis, style: theme.style14W400,),
            // Text(item.login,
            //   overflow: TextOverflow.ellipsis, style: theme.style12W600Grey,),
        ],
        ))),
        // time
        DataCell(Container(child: Text(_mainModel.getDateTimeString(item.time),
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // total
        DataCell(Container(child: Text(getPriceString(item.total),
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // comment
        DataCell(Container(width: 200, child: Text(item.comment,
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),

        ]));
    }

    List<DataColumn> _column = [
      DataColumn(label: Expanded(child: Text(strings.get(54), style: theme.style14W600Grey))), // name
      DataColumn(label: Expanded(child: Text(strings.get(273), style: theme.style14W600Grey))), // time
      DataColumn(label: Expanded(child: Text(strings.get(177), style: theme.style14W600Grey))), // Total
      DataColumn(label: Expanded(child: Text(strings.get(180), style: theme.style14W600Grey))), // Comment
    ];

    list.add(Container(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          child: horizontalScroll(DataTable(
              columns: _column,
              rows: _cells,
        ), _controllerScroll))
    );

    // pagination
    list.add(SizedBox(height: 10,));
    _paginsCount = _visibleCount ~/_pRange;
    // print ("_paginsCount=$_paginsCount _visibleCount=$_visibleCount _visibleCount%_pRange=${_visibleCount%_pRange}");
    if (_visibleCount%_pRange > 0)
      _paginsCount++;
    List<Widget> list2 = [];
    if (_paginsCount > 12){
      var _st = _currentPage - 5;
      var _end = _currentPage + 5;
      if (_st < 1)
        _st = 1;
      else
        list2.add(Text("  ...  ", style: theme.style16W800,));
      if (_end > _paginsCount)
        _end = _paginsCount;
      for (var i = _st; i <= _end; i++){
        list2.add(button168("$i", theme.mainColor, 5, (){_pagin(i);}, (i == _currentPage) ? false : true));
        list2.add(SizedBox(width: 5,));
      }
      if (_end != _paginsCount)
        list2.add(Text("  ...  ", style: theme.style16W800,));
    }else
      for (var i = 1; i <= _paginsCount; i++){
        list2.add(button168("$i", theme.mainColor, 5, (){_pagin(i);}, (i == _currentPage) ? false : true));
        list2.add(SizedBox(width: 5,));
      }
    var t = _pStart+_pRange;
    if (t > _visibleCount)
      t = _visibleCount;
    list.add(Row(
      children: [
        if (!isMobile())
          SizedBox(width: 40,),
        Text("${_pStart+1}-$t ${strings.get(88)} $_visibleCount", style: TextStyle(fontSize: 18),), // from
        Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: list2,))
      ],
    ));

    return list;
  }

  var _paginsCount = 0;
  var _pStart = 0;
  var _pRange = 10;
  var _currentPage = 1;
  _pagin(int i){
    _pStart = (i-1) * _pRange;
    // print("_pagin _pStart =$_pStart i=$i");
    _currentPage = i;
    _redraw();
  }

  _copy(){
    _mainModel.provider.copyPayouts();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.provider.csvPayouts(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "payouts.csv"
      ..style.display = 'none'
      ..click();
  }

  String _searchedValue = "";
  _onSearch(String value){
    _searchedValue = value;
   _redraw();
  }

  // _addButtonsCopyExportSearch(List<Widget> list){
  //   //
  //   if (isMobile()) {
  //     list.add(Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         button2small(strings.get(58), // "Copy",
  //             theme.style14W600White, theme.mainColor, theme.radius, (){_copy();}, true),
  //         SizedBox(width: 10,),
  //         button2small(strings.get(59), // "Export to CSV",
  //             theme.style14W600White, theme.mainColor, theme.radius, (){_csv();}, true),
  //         Expanded(child: Container(),),
  //       ],
  //     ));
  //     list.add(SizedBox(height: 10,));
  //     list.add(Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         Text(strings.get(89), style: theme.style14W400,), // "Show",
  //         Container(
  //             width: 120,
  //             child: Combo(inRow: true, text: "",
  //               data: _paginData,
  //               value: _pRange.toString(),
  //               onChange: (String value){
  //                 _pRange = int.parse(value);
  //                 setState(() {
  //                 });
  //               },)),
  //         SizedBox(width: 5,),
  //         Text(strings.get(90), style: theme.style14W400,), // "entries",
  //       ],
  //     ));
  //     list.add(SizedBox(height: 10,));
  //     list.add(Container(width: 120,
  //         child: textElement2(strings.get(60), "", _controllerSearch, _onSearch)));
  //   }else{
  //     list.add(Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         button2small(strings.get(58), // "Copy",
  //             theme.style14W600White, theme.mainColor, theme.radius, (){_copy();}, true),
  //         SizedBox(width: 10,),
  //         button2small(strings.get(59), // "Export to CSV",
  //             theme.style14W600White, theme.mainColor, theme.radius, (){_csv();}, true),
  //         Expanded(child: Container(),),
  //         //
  //         Text(strings.get(89), style: theme.style14W400,), // "Show",
  //         Container(
  //             width: 120,
  //             child: Combo(inRow: true, text: "",
  //               data: _paginData,
  //               value: _pRange.toString(),
  //               onChange: (String value){
  //                 _pRange = int.parse(value);
  //                 setState(() {
  //                 });
  //               },)),
  //         SizedBox(width: 5,),
  //         Text(strings.get(90), style: theme.style14W400,), // "entries",
  //         //
  //         SizedBox(width: 30,),
  //         Container(width: 200,
  //             child: textElement2(strings.get(60), "", _controllerSearch, _onSearch))
  //       ],
  //     ));
  //   }
  //   list.add(SizedBox(height: 10,));
  // }
}
