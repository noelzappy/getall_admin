import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import '../model/responsive.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(bool) waits;
  const FavoritesScreen({required this.waits});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  late MainModel _mainModel;
  final List<ComboData> _sortData = [];
  String _sortDataValue = "";
  List<ProductData> _services = [];
  final ScrollController _controllerScroll = ScrollController();

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _sortDataValue = "countAsc";
    _resort();
    _sortData.add(ComboData(strings.get(278), "nameAsc")); /// Name Ascend
    _sortData.add(ComboData(strings.get(279), "nameDesc")); /// Name Descend
    _sortData.add(ComboData(strings.get(323), "catAsc")); /// Category Ascend
    _sortData.add(ComboData(strings.get(324), "catDesc")); /// Category Descend
    _sortData.add(ComboData(strings.get(325), "proAsc")); /// Provider Ascend
    _sortData.add(ComboData(strings.get(326), "proDesc")); /// Provider Descend
    _sortData.add(ComboData(strings.get(321), "countAsc")); /// Count Ascend
    _sortData.add(ComboData(strings.get(322), "countDesc")); /// Count Descend
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.waits(true);
      var ret = await _mainModel.provider.loadPayout(context);
      if (ret != null)
        messageError(context, ret);
      widget.waits(false);
    });
    super.initState();
  }

  _resort(){
    _services = [];
    for (var item in _mainModel.service.services)
      if (item.favoritesCount != 0)
        _services.add(item);
    if (_sortDataValue == "countAsc")
      _services.sort((a, b) => a.favoritesCount.compareTo(b.favoritesCount));
    if (_sortDataValue == "countDesc")
      _services.sort((a, b) => b.favoritesCount.compareTo(a.favoritesCount));
    if (_sortDataValue == "nameAsc")
      _services.sort((a, b) => getTextByLocale(a.name, strings.locale).compareTo(getTextByLocale(b.name, strings.locale)));
    if (_sortDataValue == "nameDesc")
      _services.sort((a, b) => getTextByLocale(b.name, strings.locale).compareTo(getTextByLocale(a.name, strings.locale)));
    if (_sortDataValue == "catAsc")
      _services.sort((a, b) => _mainModel.category.compareToCategoryName(a, b, context));
    if (_sortDataValue == "catDesc")
      _services.sort((a, b) => _mainModel.category.compareToCategoryName(b, a, context));
    if (_sortDataValue == "proAsc")
      _services.sort((a, b) => _mainModel.category.compareToProviderName(a, b, context));
    if (_sortDataValue == "proDesc")
      _services.sort((a, b) => _mainModel.category.compareToProviderName(b, a, context));
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
        Expanded(child: SelectableText(strings.get(320), /// "Favorites",
          style: theme.style25W800,)),
      ],
    ));
    list.add(SizedBox(height: 8,));
    list.add(SelectableText(strings.get(327), /// "This list includes services that users add to favorites in their applications. The count is how many users have added this service to their favorites.
      style: theme.style12W400,));
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
                _resort();
                _redraw();
              },)),
      ],
    ));

    int _visibleCount = 0;

    List<DataRow> _cells = [];
    for (var item in _services){
      if (!_mainModel.getTextByLocale(item.name).toUpperCase().contains(_searchedValue.toUpperCase()))
        continue;
      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;

      _cells.add(DataRow(cells: [
        // name
        DataCell(Container(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_mainModel.getTextByLocale(item.name),
              overflow: TextOverflow.ellipsis, style: theme.style14W400,),
            // Text(item.login,
            //   overflow: TextOverflow.ellipsis, style: theme.style12W600Grey,),
        ],
        ))),
        // category
        DataCell(Container(child: Text(item.category.isNotEmpty ? _mainModel.category.getCategoryName(item.category[0], context) : "",
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // provider
        DataCell(Container(child: Text(item.providers.isNotEmpty ? _mainModel.provider.getProviderName(item.providers[0], context) : "",
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // count
        DataCell(Container(width: 200, child: Text(item.favoritesCount.toString(),
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),

        ]));
    }

    List<DataColumn> _column = [
      DataColumn(label: Expanded(child: Text(strings.get(54), style: theme.style14W600Grey))), // Name
      DataColumn(label: Expanded(child: Text(strings.get(158), style: theme.style14W600Grey))), // Category
      DataColumn(label: Expanded(child: Text(strings.get(178), style: theme.style14W600Grey))), // Provider
      DataColumn(label: Expanded(child: Text(strings.get(283), style: theme.style14W600Grey))), // Count
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
    var text = "";
    for (var item in _services){
      var _cat = "";
      if (item.category.isNotEmpty)
        _cat = _mainModel.category.getCategoryName(item.category[0], context);
      var _pro = "";
      if (item.providers.isNotEmpty)
        _pro = _mainModel.provider.getProviderName(item.providers[0], context);
      text = "$text${_mainModel.getTextByLocale(item.name)}\t$_cat\t$_pro\t${item.favoritesCount}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    List<List> t2 = [];
    t2.add([
      strings.get(54), // Name
      strings.get(158), // Category
      strings.get(178), // Provider
      strings.get(283), // Count
    ]);
    for (var item in _services){
      var _cat = "";
      if (item.category.isNotEmpty)
        _cat = _mainModel.category.getCategoryName(item.category[0], context);
      var _pro = "";
      if (item.providers.isNotEmpty)
        _pro = _mainModel.provider.getProviderName(item.providers[0], context);
      t2.add([
        _mainModel.getTextByLocale(item.name),
        _cat,
        _pro,
        item.favoritesCount
      ]);
    }
    var _data = ListToCsvConverter().convert(t2);

    html.AnchorElement()
      ..href = '${Uri.dataFromString(_data, mimeType: 'text/plain', encoding: utf8)}'
      ..download = "favorites.csv"
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
  //             (){_copy();}),
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
  //         child: textElement2(strings.get(60), "", _controllerSearch, _onSearch))); /// "Search",
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
