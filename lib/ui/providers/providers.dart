import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/appService/emulator.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import 'edit.dart';

import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class ProvidersScreen extends StatefulWidget {
  final Function(bool) waits;
  const ProvidersScreen({required this.waits});

  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerSearch = TextEditingController();
  late MainModel _mainModel;
  final ScrollController _controllerScroll = ScrollController();

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerName.dispose();
    _controllerPassword.dispose();
    _controllerEmail.dispose();
    _controllerSearch.dispose();
    _mainModel.provider.newProvider = null;
    _mainModel.provider.current = ProviderData.createEmpty();
    super.dispose();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      for (var item in _mainModel.serviceApp.screens)
        if (item.id == "provider")
          _mainModel.serviceApp.selectScreen(item);
      widget.waits(true);
      var ret = await _mainModel.provider.load(context);
      if (ret != null)
        messageError(context, ret);
      widget.waits(false);
    });
    if (_mainModel.provider.newProvider != null)
      _notEditorCreate = false;
    super.initState();
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
              shrinkWrap: true,
            children: _getList(),
          ),
    );
  }

  _getList(){

    // ignore: unnecessary_statements
    context.watch<MainModel>().provider.current;

    List<Widget> list = [];
    list.add(SizedBox(height: 10,));
    list.add(Row(
      children: [
        Expanded(child: SelectableText(strings.get(96),                       /// "Providers",
          style: theme.style25W800,)),
      ],
    ));
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    addButtonsCopyExportSearch(list, _copy, _csv, isMobile(), strings.langCopyExportSearch, _onSearch,
        _pRange, (String value){_pRange = int.parse(value); setState(() {});} );

    int _visibleCount = 0;

    if (_mainModel.provider.ensureVisible.isNotEmpty){
      for (var item in _mainModel.provider.providers){
        if (!_mainModel.getTextByLocale(item.name).toUpperCase().contains(_searchedValue.toUpperCase()))
          continue;
        _currentPage = 1;
        _visibleCount++;
        if (item.id == _mainModel.provider.ensureVisible){
          var _pStart2 = 0;
          do{
            if (_visibleCount-1 > _pStart2 && _visibleCount-1 < _pStart2+_pRange) {
              _pStart = _pStart2;
              Provider.of<MainModel>(context,listen:false).provider.ensureVisible = "";
              break;
            }
            _pStart2+=_pRange;
            _currentPage++;
          }while(_pStart2< _mainModel.provider.providers.length);
        }
      }
    }

    _visibleCount = 0;

    List<DataRow> _cells = [];
    for (var item in _mainModel.provider.providers){
      if (!_mainModel.getTextByLocale(item.name).toUpperCase().contains(_searchedValue.toUpperCase()))
        continue;
      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;
      _cells.add(DataRow(cells: [
        /// name
        DataCell(Container(child: Text(_mainModel.getTextByLocale(item.name),
          overflow: TextOverflow.ellipsis, style: theme.style14W400,))),
        /// email
        DataCell(Container(child: Text(item.login,
          overflow: TextOverflow.ellipsis, style: theme.style14W400,))),
        // preview
        // DataCell(Container(child: Text('${_data.desc}', overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // action
        DataCell(Center(child:Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 5,),
                button2small(strings.get(68), (){        /// "Edit",
                  _notEditorCreate = false;
                  _mainModel.provider.select(item);
                }, color: theme.mainColor.withAlpha(150)),
                SizedBox(width: 5,),
                button2small(strings.get(62), (){_openDialogDelete(item);}, color: dashboardErrorColor.withAlpha(150)), /// "Delete",
                SizedBox(width: 5,),
              ],
            )
        ))
        ]));
    }

    List<DataColumn> _column = [
      DataColumn(label: Expanded(child: Text(strings.get(54), style: theme.style14W600Grey))), /// name
      DataColumn(label: Expanded(child: Text(strings.get(86), style: theme.style14W600Grey))), /// "Email",
      // DataColumn(label: Expanded(child: Text(strings.get(73), style: theme.style14W600Grey))), // Description
      DataColumn(label: Expanded(child: Center(child: Text(strings.get(66), style: theme.style14W600Grey)))), /// action
    ];

    list.add(Container(
        color: (theme.darkMode) ? Colors.black : Colors.white,
        child: horizontalScroll(DataTable(
            columns: _column,
            rows: _cells,
        ), _controllerScroll)
      )
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
    //
    //
    //

    list.add(SizedBox(height: 40));

    if (isMobile()){
      if (!_notEditorCreate)
        list.add(EditInProvider());
      else
        list.add(Center(child: button2small(strings.get(121), (){ /// "Create new provider",
          _notEditorCreate = false;
          _redraw();
        })));
      list.add(SizedBox(height: 10),);
      list.add(EmulatorServiceScreen());
    }
    else
      list.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmulatorServiceScreen(),
            SizedBox(width: 20),
            if (!_notEditorCreate)
              Expanded(child: EditInProvider()),
            if (_notEditorCreate)
              Center(child: button2small(strings.get(121), (){ /// "Create new provider",
                _notEditorCreate = false;
                _redraw();
              })),
          ],
        )
    );

    return list;
  }

  var _notEditorCreate = true;
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

  _openDialogDelete(ProviderData value){
    openDialogDelete(() async {
      Navigator.pop(context); // close dialog
      // demo mode
      if (appSettings.demo)
        return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
      var ret = await Provider.of<MainModel>(context,listen:false).provider.delete(value);
      if (ret == null)
        messageOk(context, strings.get(69)); // "Data deleted",
      else
        messageError(context, ret);
      setState(() {});
    }, context);
  }

  _copy(){
    _mainModel.provider.copy();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.provider.csv(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "providers.csv"
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
