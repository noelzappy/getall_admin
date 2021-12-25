import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import '../model/responsive.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class CustomersScreen extends StatefulWidget {
  final Function(bool) waits;
  const CustomersScreen({required this.waits});

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  final _controllerAddress = TextEditingController();
  final _controllerComments = TextEditingController();
  late MainModel _mainModel;

  @override
  void dispose() {
    _controllerSearch.dispose();
    _controllerAddress.dispose();
    _controllerComments.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.waits(true);
      var ret = await _mainModel.notifyModel.loadUsers();
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
    return ListView(
      children: _getList(),
    );
  }

  _getList(){

    // ignore: unnecessary_statements
    // context.watch<MainModel>().booking.bookings;

    List<Widget> list = [];

    List<Widget> list3 = [];
    list3.add(SizedBox(height: 10,));
    list3.add(Row(
      children: [
        Expanded(child: SelectableText(strings.get(255), /// Customers list
          style: theme.style25W800,)),
      ],
    ));
    list3.add(SizedBox(height: 20,));
    list3.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list3.add(SizedBox(height: 10,));
    addButtonsCopyExportSearch(list3, _copy, _csv, isMobile(), strings.langCopyExportSearch, _onSearch,
        _pRange, (String value){_pRange = int.parse(value); setState(() {});} );

    list.add(Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: list3
        )));

    list.add(SizedBox(height: 10,));

    int _visibleCount = 0;
    _visibleCount = 0;

    for (var item in _mainModel.notifyModel.users){
      if (item.providerApp)
        continue;
      if (item.role.isNotEmpty)
        continue;
      if (!item.name.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !item.email.toUpperCase().contains(_searchedValue.toUpperCase())
        ) continue;

      _visibleCount++;
      if (_visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+_pRange)
        continue;
      list.add(Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (theme.darkMode) ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _item(item)
      ));
    }

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

    return list;
  }

  _item(UserData item){
    return Container(
      width: windowWidth,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 80,
                  width: 80,
                  child: (item.logoServerPath.isEmpty) ? CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"), radius: 50,) :
                  ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                          item.logoServerPath,
                          height: 80,
                          fit: BoxFit.cover))),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 10,),
                  Row(children: [
                    SelectableText(strings.get(54) + ":", style: theme.style14W600Grey,), /// "Name",
                    SizedBox(width: 10,),
                    Expanded(child: Text(item.name, style: theme.style14W800),)
                  ]),
                  SizedBox(height: 10,),
                  Row(children: [
                    SelectableText(strings.get(86) + ":", style: theme.style14W600Grey,), /// "Email",
                    SizedBox(width: 10,),
                    Expanded(child: Text(item.email, style: theme.style14W800),)
                  ]),
                  SizedBox(height: 10,),
                  Row(children: [
                    SelectableText(strings.get(182) + ":", style: theme.style14W600Grey,), /// "Status",
                    SizedBox(width: 10,),
                    if (item.visible)
                      Expanded(child: Text(strings.get(256), style: theme.style16W800Green),), /// Enabled
                    if (!item.visible)
                      Expanded(child: Text(strings.get(257), style: theme.style16W800Red),) /// "Disabled",
                  ]),
                ],
              )),
              SizedBox(width: 10,),
              if (!isMobile())
                _buttons(item),
              if (!isMobile())
                SizedBox(width: 10,),
            ],
          ),
          if (isMobile())
            SizedBox(height: 10,),
          if (isMobile())
            _buttons(item),
        ],
      ),
    );
  }

  _buttons(UserData item){
    return Column(
      children: [
        button2small(item.visible ? strings.get(258) : strings.get(259), (){_enable(item);}), // "Disable",  "Enable",
        SizedBox(height: 10,),
        button2small(strings.get(62), (){_delete(item);}), // "Delete",
      ],
    );
  }

  _enable(UserData item) async {
    var ret = await Provider.of<MainModel>(context,listen:false).userSetEnable(item);
    if (ret != null)
      messageError(context, ret);
    _redraw();
  }

  _delete(UserData item){
      openDialogDelete(() async {
        Navigator.pop(context); // close dialog
        // demo mode
        if (appSettings.demo)
          return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
        var ret = await Provider.of<MainModel>(context,listen:false).deleteUser(item);
        if (ret == null)
          messageOk(context, strings.get(69)); // "Data deleted",
        else
          messageError(context, ret);
        setState(() {});
      }, context);
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
    _mainModel.notifyModel.copyCustomers();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.notifyModel.csvCustomers(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "customers.csv"
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
