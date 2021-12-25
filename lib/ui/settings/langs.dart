import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../strings.dart';
import '../theme.dart';

class AppLangScreen extends StatefulWidget {
  final Function(bool) waits;
  const AppLangScreen({required this.waits});

  @override
  _AppLangScreenState createState() => _AppLangScreenState();
}

class _AppLangScreenState extends State<AppLangScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerText = TextEditingController();
  final dataKey = GlobalKey();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerPassword.dispose();
    _controllerEmail.dispose();
    _controllerText.dispose();
    super.dispose();
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
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user == null)
    //   return logout(context);

    List<Widget> list = [];
    list.add(SizedBox(height: 10,));
    list.add(SelectableText(strings.get(107), style: theme.style25W800,)); /// Languages
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    var _selectApp = Row(
      children: [
        Text(strings.get(109), style: theme.style14W400,), /// "Select Application",
        Expanded(child: Container(
            width: 120,
            child: Combo(inRow: true, text: "",
              data: _mainModel.appsDataCombo,
              value: _mainModel.appsDataComboValue,
              onChange: (String value){
                _mainModel.langs.setApp(value);
                _redraw();
              },))),
      ],
    );

    var _defLang = Row(
      children: [
        Text(strings.get(131), style: theme.style14W400,), /// "Default language",
        Expanded(child: Container(
            width: 120,
            child: Combo(inRow: true, text: "",
              data: _mainModel.langDataCombo,
              value: _mainModel.langs.getDefaultLangByApp(),
              onChange: (String value){
                _mainModel.langs.setDefaultLangByApp(value);
                _redraw();
              },))),
      ],
    );

    if (isMobile()){
      list.add(_selectApp);
      list.add(SizedBox(height: 20,));
      list.add(_defLang);
    }else
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: _selectApp),
          SizedBox(width: 20,),
          Expanded(child: _defLang),
        ],
      ));

    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    if (isMobile()) {
      list.add(_selectLanguage());
      list.add(SizedBox(height: 10,));
      list.add(_showAndSearch());
    }else
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: _selectLanguage()),
        SizedBox(width: 20,),
        _showAndSearch(),
      ],
    ));
    list.add(SizedBox(height: 10,));

    int _visibleCount = 0;

    List<DataRow> _cells = [];
    for (var item in _mainModel.listWordsForEdit){
      if (!item.word.toUpperCase().contains(_searchedValue.toUpperCase()))
        continue;
      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;
      //
      // print("------------------> -------------> item.controller=${item.controller}");
      _cells.add(DataRow(cells: [
        // id
        DataCell(Container(child: Text(item.id, overflow: TextOverflow.ellipsis, style: theme.style14W400,))),
        // word
        DataCell(Container(child: textElement2("", "", item.controller, (String val){
          item.word = val;
          _mainModel.langs.saveWord(item.id, val);
        })))

      ]));
    }

    List<DataColumn> _column = [
      DataColumn(label: Expanded(child: Text(strings.get(114), style: theme.style14W600Grey))), // id
      DataColumn(label: Expanded(child: Text(strings.get(113), style: theme.style14W600Grey))), // word
    ];

    list.add(SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: (windowWidth/2 < 600) ? 600 : windowWidth-400,
              color: (theme.darkMode) ? Colors.black : Colors.white,
              child: DataTable(
                  columns: _column,
                  rows: _cells,
            )))));

    // pagination
    list.add(SizedBox(height: 10,));
    _paginsCount = _visibleCount ~/_pRange;
    // print("AppLangScreen _paginsCount=$_paginsCount _visibleCount=$_visibleCount _visibleCount%_pRange=${_visibleCount%_pRange}");
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
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));
    list.add(Row(
      children: [
        button2small(strings.get(9), _save), // "Save"
      ],
    ));

    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(strings.get(207) + ":", style: theme.style14W400,), // "Add new language",
        SizedBox(width: 5,),
        Expanded(child: Container(
            width: 120,
            child: Combo(inRow: true, text: "",
              data: _mainModel.langs.getNewLangList(),
              value: _mainModel.langs.newLandValue,
              onChange: (String value){
                Provider.of<MainModel>(context,listen:false).langs.newLandValue = value;
                setState(() {
                });
              },))),
        SizedBox(width: 20,),
        if (!isMobile())
          button2small(strings.get(209), _create), /// "Create"
      ],
    ));
    if (isMobile()){
      list.add(SizedBox(height: 10,));
      list.add(button2small(strings.get(209), _create)); /// "Create"
    }

    list.add(SizedBox(height: 10,));
    list.add(Text(strings.get(208),  /// "By default all words will be in english language. You must translate all words by himself.",
      style: theme.style16W800Red,),);

    list.add(SizedBox(height: 100,));
    return list;
  }

  _create() async {
    widget.waits(true);
    var ret = await Provider.of<MainModel>(context,listen:false).langs.createNewLanguage();
    if (ret == null)
      messageOk(context, strings.get(210)); /// "Language added",
    else
      messageError(context, ret);
    widget.waits(false);
  }

  _save() async {
    if (appSettings.demo)
      return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
    widget.waits(true);
    var ret = await Provider.of<MainModel>(context,listen:false).langs.saveLanguageWords();
    if (ret == null)
      messageOk(context, "${strings.get(185)} ${_mainModel.editLangNowDataComboValue}"); /// "Data saved for language: ",
    else
      messageError(context, ret);
    widget.waits(false);
  }

  var _paginsCount = 0;
  var _pStart = 0;
  var _pRange = 10;
  var _currentPage = 1;
  _pagin(int i){
    _pStart = (i-1) * _pRange;
    // print("AppLangScreen _pagin _pStart =$_pStart i=$i");
    _currentPage = i;
    _redraw();
  }
  final List<ComboData> _paginData = [ComboData("5", "5"), ComboData("10", "10"), ComboData("15", "15"), ComboData("20", "20"),
    ComboData("30", "30"), ComboData("50", "50"), ComboData("100", "100"),];

  String _searchedValue = "";
  _onSearch(String value){
    _currentPage = 1;
    _searchedValue = value;
    _pStart = 0;
   _redraw();
  }

  _selectLanguage(){
    return Row(
      children: [
        Text(strings.get(108), style: theme.style14W400, overflow: TextOverflow.ellipsis,), /// "Select language",
        Expanded(child: Container(
            width: 120,
            child: Combo(inRow: true, text: "",
              data: _mainModel.langDataCombo,
              value: _mainModel.editLangNowDataComboValue,
              onChange: (String value) async {
                await Provider.of<MainModel>(context,listen:false).setLang(value);
                setState(() {
                });
              },)))
      ],
    );
  }

  _showAndSearch(){
    if (isMobile())
      return Column(
        children: [
          Row(
            children: [
              Text(strings.get(89), style: theme.style14W400,), // "Show",
              Expanded(child: Container(
                  child: Combo(inRow: true, text: "",
                    data: _paginData,
                    value: _pRange.toString(),
                    onChange: (String value){
                      _pRange = int.parse(value);
                      setState(() {
                      });
                    },))),
              SizedBox(width: 5,),
              Text(strings.get(90), style: theme.style14W400,), // "entries",
            ],
          ),
          SizedBox(height: 10,),
          Container(child: textElement2(strings.get(60), "", _controllerText, _onSearch))
        ],
      );
    return Row(
      children: [
        Text(strings.get(89), style: theme.style14W400,), // "Show",
        Container(
            width: 120,
            child: Combo(inRow: true, text: "",
              data: _paginData,
              value: _pRange.toString(),
              onChange: (String value){
                _pRange = int.parse(value);
                setState(() {
                });
              },)),
        SizedBox(width: 5,),
        Text(strings.get(90), style: theme.style14W400,), // "entries",
        SizedBox(width: 20,),
        Container(width: 200, child: textElement2(strings.get(60), "", _controllerText, _onSearch))
      ],
    );
  }
}


