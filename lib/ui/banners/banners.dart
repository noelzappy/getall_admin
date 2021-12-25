import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/ui/appService/emulator.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:ondemand_admin/model/serviceappsettings.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'edit.dart';

class BannersScreen extends StatefulWidget {
  final Function(bool) waits;
  const BannersScreen({required this.waits});

  @override
  _BannersScreenState createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  late MainModel _mainModel;
  final _currentEditWindowKey = GlobalKey();
  final ScrollController _controllerScroll = ScrollController();

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerSearch.dispose();
    _mainModel.banner.current = BannerData.createEmpty();
    super.dispose();
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.waits(true);
      _mainModel.serviceApp.select = Screen("banner", "banner", []);
      var ret = await _mainModel.banner.load();
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
        Expanded(child: SelectableText(strings.get(328), /// "Banners",
          style: theme.style25W800,)),
      ],
    ));
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    addButtonsCopyExportSearch(list, _copy, _csv, isMobile(), strings.langCopyExportSearch, _onSearch,
        _pRange, (String value){_pRange = int.parse(value); setState(() {});} );
    list.add(SizedBox(height: 10,));

    int _visibleCount = 0;
    if (_mainModel.banner.ensureVisible.isNotEmpty){
      for (var item in _mainModel.banner.banners){
        if (!item.name.toUpperCase().contains(_searchedValue.toUpperCase()))
          continue;
        _currentPage = 1;
        _visibleCount++;
        if (item.id == _mainModel.banner.ensureVisible){
          var _pStart2 = 0;
          do{
            if (_visibleCount-1 > _pStart2 && _visibleCount-1 < _pStart2+_pRange) {
              _pStart = _pStart2;
              _mainModel.banner.ensureVisible = "";
              break;
            }
            _pStart2+=_pRange;
            _currentPage++;
          }while(_pStart2<_mainModel.banner.banners.length);
        }
      }
    }
    _visibleCount = 0;

    List<DataRow> _cells = [];
    for (var item in _mainModel.banner.banners){
      if (!item.name.toUpperCase().contains(_searchedValue.toUpperCase()))
        continue;
      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;

      _cells.add(DataRow(cells: [
        // name
        DataCell(Container(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name,
              overflow: TextOverflow.ellipsis, style: theme.style14W400,),
        ],
        ))),
        // type
        DataCell(Container(child: Text(item.type,
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // status
        DataCell(Container(child: Text("",
            overflow: TextOverflow.ellipsis, style: theme.style14W400))),
        // action
        DataCell(Center(child:Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 5,),
            button2small(strings.get(68), (){ /// "Edit",
              _notEditorCreate = false;
              _mainModel.banner.select(item);
              if (_currentEditWindowKey.currentContext != null)
                Scrollable.ensureVisible(_currentEditWindowKey.currentContext!, duration: Duration(seconds: 1));
            }, color: theme.mainColor.withAlpha(150)),
            SizedBox(width: 5,),
            button2small(strings.get(62),  /// "Delete",
                (){_openDialogDelete(item);}, color: dashboardErrorColor.withAlpha(150)),
            SizedBox(width: 5,),
          ],
        )))

        ]));
    }

    List<DataColumn> _column = [
      DataColumn(label: Expanded(child: Text(strings.get(54), style: theme.style14W600Grey))), // Name
      DataColumn(label: Expanded(child: Text(strings.get(329), style: theme.style14W600Grey))), // Banner type
      DataColumn(label: Expanded(child: Text(strings.get(182), style: theme.style14W600Grey))), // Status
      DataColumn(label: Expanded(child: Text(strings.get(66), style: theme.style14W600Grey))), // Action
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

    list.add(SizedBox(height: 40));

    if (isMobile()){
      if (!_notEditorCreate)
        list.add(Container(
          key: _currentEditWindowKey,
          child: EditInBanner()));
      else
        list.add(Center(child: button2small(strings.get(333), (){ /// "Create new banner",
          _notEditorCreate = false;
          _redraw();
        })));
      list.add(SizedBox(height: 10),);
      list.add(EmulatorServiceScreen());
    }else
      list.add(Row(
          children: [
            EmulatorServiceScreen(),
            SizedBox(width: 20),
            Expanded(child: Column(
              children: [
                if (!_notEditorCreate)
                  Container(
                      key: _currentEditWindowKey,
                      child: EditInBanner()),
                if (_notEditorCreate)
                  Center(child: button2small(strings.get(333), (){ /// "Create new banner",
                    _notEditorCreate = false;
                    _redraw();
                  })),
              ],
            ))
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

  _copy(){
    _mainModel.banner.copy();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.banner.csv(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "banners.csv"
      ..style.display = 'none'
      ..click();
  }

  String _searchedValue = "";
  _onSearch(String value){
    _searchedValue = value;
   _redraw();
  }

  _openDialogDelete(BannerData value){
    openDialogDelete(() async {
      Navigator.pop(context); // close dialog
      var ret = await _mainModel.banner.delete(value);
      if (ret == null)
        messageOk(context, strings.get(69)); /// "Data deleted",
      else
        messageError(context, ret);
      setState(() {});
    }, context);
  }
}
