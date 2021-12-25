import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/elements/datetime.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final Function(bool) waits;
  const BookingScreen({required this.waits});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  final _controllerAddress = TextEditingController();
  final _controllerComments = TextEditingController();
  late MainModel _mainModel;

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.waits(true);
      var ret = await _mainModel.provider.load(context);
      if (ret != null)
        messageError(context, ret);
      ret = await _mainModel.notifyModel.loadUsers();
      if (ret != null)
        messageError(context, ret);
      ret = await _mainModel.service.load(context);
      if (ret != null)
        messageError(context, ret);
      widget.waits(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    _controllerAddress.dispose();
    _controllerComments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Directionality(
        textDirection: strings.direction,
        child: ListView(
      children: _getList(),
    ));
  }

  _setBooking(){
    if (appSettings.bookingCountUnread != 0)
      FirebaseFirestore.instance.collection("settings").doc("main")
        .set({"booking_count_unread": 0}, SetOptions(merge:true));
  }

  _getList(){

    // ignore: unnecessary_statements
    // context.watch<MainModel>().booking.bookings;

    _setBooking();

    List<Widget> list = [];

    List<Widget> list3 = [];
    list3.add(SizedBox(height: 10,));
    list3.add(Row(
      children: [
        Expanded(child: SelectableText(strings.get(181), // Booking list
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

    // list.add(SizedBox(height: 10,));

    list.add(Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: (isMobile())
            ? Column(
              children: [
                _sortBy1(),
                SizedBox(height: 10,),
                _sortBy1a(),
                SizedBox(height: 10,),
                _sortBy2(),
                SizedBox(height: 10,),
                _sortBy2a(),
              ],
            )
            : (isDesktopMore1300()) ?
                Row(
                    children: [
                      Expanded(child: _sortBy1()),
                      SizedBox(width: 10,),
                      Expanded(child: _sortBy1a()),
                      SizedBox(width: 10,),
                      Expanded(child: _sortBy2()),
                      SizedBox(width: 10,),
                      Expanded(child: _sortBy2a()),
                    ]
                )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _sortBy1()),
                      SizedBox(width: 10,),
                      Expanded(child: _sortBy1a()),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(child: _sortBy2()),
                      SizedBox(width: 10,),
                      Expanded(child: _sortBy2a()),
                    ],
                  ),
                ],
              )
      )
    );

    int _visibleCount = 0;
    _visibleCount = 0;

    for (var item in bookings){
      if (!item.customer.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !getTextByLocale(item.provider, strings.locale).toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !item.address.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !item.comment.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !getTextByLocale(item.service, strings.locale).toUpperCase().contains(_searchedValue.toUpperCase())
        )
        continue;
      if (_mainModel.provider.providersComboValue != "1")
        if (_mainModel.provider.providersComboValue != item.providerId)
          continue;
      if (_mainModel.notifyModel.userSelected != "-1")
        if (_mainModel.notifyModel.userSelected != item.customerId)
          continue;
      if (_mainModel.service.serviceSelected != "-1")
        if (_mainModel.service.serviceSelected != item.serviceId)
          continue;
      if (_mainModel.statusesComboValueBookingSearch != "-1")
        if (_mainModel.statusesComboValueBookingSearch != item.status)
          continue;

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

  _item(OrderData item){
    List<Widget> _addons = [];
    _addons.add(SizedBox(height: 5,));
    _addons.add(Container(
      margin: EdgeInsets.only(right: 100),
        child: Text(strings.get(347), style: theme.style14W400,)),); /// "Addons",
    _addons.add(SizedBox(height: 10,));
    bool _found = false;
    if (item.addon.isNotEmpty) {
      for (var item in item.addon) {
        if (!item.selected)
          continue;
        _addons.add(Container(
            margin: strings.direction == TextDirection.ltr ? EdgeInsets.only(left: 20) : EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Text("${getTextByLocale(item.name, strings.locale)} ${item.needCount}x${getPriceString(item.price)}",
                  style: theme.style14W400,),
                SizedBox(width: 10,),
                Text(getPriceString(item.needCount*item.price),
                  style: theme.style14W800,)
              ],
            )
        ));
        _addons.add(SizedBox(height: 5,));
        _found = true;
      }
    }
    if (!_found)
      _addons = [];

    //
    //
    //
    List<Widget> _statuses = [];
    var _style = theme.style16W800;
    var _first = true;
    for (var item2 in appSettings.statuses){
      if (_style == theme.style16W800Green)
        _style = theme.style16W800Grey;
      if (item2.id == item.status)
        _style = theme.style16W800Green;
      if (!_first)
        //_statuses.add(_circles());
        _statuses.add(Text("|", style: theme.style14W800,));
      else
        _first = false;
      _statuses.add(Text(getTextByLocale(item2.name, strings.locale), style: _style));
    }

    var _styleName = theme.style13W600Grey;
    var _dataName = theme.style13W400;

    setDataToCalculate(item, null);

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
                  child: (item.customerAvatar.isEmpty) ? CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"), radius: 5,) :
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                          item.customerAvatar,
                          height: 80,
                          fit: BoxFit.cover))),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(item.customer, style: theme.style14W800),
                    SizedBox(width: 10,),
                    Expanded(child: Text(item.id + " ${_mainModel.getDateTimeString(item.time)}", style: _dataName, textAlign: TextAlign.center,)) /// Id
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(children: [
                    SelectableText(strings.get(183) + ":", style: _styleName,), /// "Booking At",
                    SizedBox(width: 10,),
                    Text(item.anyTime ? strings.get(280) : _mainModel.getDateTimeString(item.selectTime), style: _dataName) /// Any time
                  ]),
                  SizedBox(height: 10,),
                  Row(children: [
                    Text(strings.get(178) + ":", style: _styleName), /// "Provider",
                    SizedBox(width: 8,),
                    Expanded(child: Text(getTextByLocale(item.provider, strings.locale), style: _dataName, maxLines: 3,
                      overflow: TextOverflow.ellipsis,)),
                  ],),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text(strings.get(159) + ":", style: _styleName), /// "Service",
                      SizedBox(width: 8,),
                      Expanded(child: Text(getTextByLocale(item.service, strings.locale)
                          + getTextByLocale(item.priceName, strings.locale), style: _dataName, maxLines: 3,
                        overflow: TextOverflow.ellipsis,)),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(children: [
                    Text(strings.get(97) + ":", style: _styleName,), /// "Address",
                    SizedBox(width: 8,),
                    Expanded(child: Text(item.address, style: _dataName, maxLines: 4)),
                  ],),
                  SizedBox(height: 10,),
                  Row(children: [
                    Text(strings.get(284) + ":", style: _styleName,), /// "Payment method",
                    SizedBox(width: 8,),
                    Expanded(child: Text(item.paymentMethod, style: _dataName, maxLines: 1)),
                  ],),
                  SizedBox(height: 10,),
                  Row(children: [
                    Text(strings.get(180) + ":", style: _styleName), /// "Comment"
                    SizedBox(width: 8,),
                    Expanded(child: Text(item.comment, style: _dataName,)),
                  ],),
                ],
              )),
              Expanded(child: pricingTable(
                      (String code){
                    if (code == "addons") return strings.get(347);  /// "Addons",
                    if (code == "direction") return strings.direction;
                    if (code == "locale") return strings.locale;
                    if (code == "pricing") return strings.get(410);  /// "Pricing",
                    if (code == "quantity") return strings.get(411);  /// "Quantity",
                    if (code == "taxAmount") return strings.get(412);  /// "Tax amount",
                    if (code == "total") return strings.get(177);  /// "Total",
                    if (code == "subtotal") return strings.get(413);  /// "Subtotal",
                    if (code == "discount") return strings.get(164);  /// "Discount"
                    return "";
                  }
              )),
            ],
          ),
          SizedBox(height: 10,),
          Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,),
          SizedBox(height: 10,),

          Row(
            children: [
              Expanded(child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  runSpacing: 20.0,
                  spacing: 20, children: _statuses
              )),

              SizedBox(width: 40),
              button2c(item == _mainModel.booking.current ? strings.get(184) : strings.get(68), /// "Close", "Edit",
                   theme.mainColor, (){_edit(item);}),
            ],
          ),

          if (item == _mainModel.booking.current)
            Column(
              children: [
                SizedBox(height: 30,),
                Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(child: textElement2(strings.get(97) + ":", "", _controllerAddress, (String val){
                      item.address = val;
                      _redraw();
                    })), // "Address",
                    SizedBox(width: 20,),
                    Expanded(child: textElement2(strings.get(180) + ":", "", _controllerComments, (String val){
                      item.comment = val;
                      _redraw();
                    })), // "Comment",
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    SelectableText(strings.get(182), style: theme.style14W400,), /// "Status",
                    Expanded(child: Container(
                        child: Combo(inRow: true, text: "",
                          data: _mainModel.statusesCombo,
                          value: item.status,
                          onChange: (String value){
                            item.status = value;
                            _mainModel.booking.setStatus(item);
                            _redraw();
                          },))),
                    SizedBox(width: 30,),
                    SelectableText(strings.get(183), style: theme.style14W400,), /// "Booking At",
                    SizedBox(width: 10,),
                    Expanded(child: Container(
                      //width: 150,
                      child: ElementSelectDateTime(
                      getText: (){
                        return _mainModel.getDateTimeString(item.selectTime);
                      },
                        setDateTime: (DateTime val) {
                          item.selectTime = val;
                          item.anyTime = false;
                          setState(() {
                          });
                        },),
                    )),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(child: button2c(strings.get(62), /// "Delete",
                        dashboardErrorColor, (){_openDialogDelete(item);})),
                    Expanded(child: Container(
                        alignment: Alignment.centerRight,
                        child: button2c(strings.get(9), theme.mainColor, _save) /// "Save",
                      )
                    ),
                  ],
                )

              ],
            ),

        ],
      ),
    );
  }

  _save() async {
    var ret = await saveBooking(_mainModel.booking.current);
    if (ret == null)
      messageOk(context, strings.get(81)); /// "Data saved",
    else
      messageError(context, ret);
    _redraw();
  }

  _edit(OrderData item){
    if (item == _mainModel.booking.current)
      _mainModel.booking.clearSelect();
    else {
      _mainModel.booking.select(item);
      _controllerAddress.text = item.address;
      _controllerComments.text = item.comment;
    }
    _redraw();
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

  _openDialogDelete(OrderData value){
    openDialogDelete(() async {
      Navigator.pop(context); // close dialog
      var ret = await bookingDelete(value);
      if (ret == null) {
        messageOk(context, strings.get(69)); // "Data deleted",
        if (value.id == _mainModel.booking.current.id)
          _mainModel.booking.current = OrderData.createEmpty();
      }else
        messageError(context, ret);
      setState(() {});
    }, context);
  }

  _copy(){
    _mainModel.booking.copy();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.booking.csv(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "booking.csv"
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
  //         //SizedBox(width: 30,),
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

  _sortBy1(){
    return Row(
      children: [
        Text(strings.get(253) + ":", style: theme.style14W800,), /// "Sort by",
        SizedBox(width: 10,),
        Text(strings.get(96) + ":", style: theme.style14W400,), /// "Providers",
        if (_mainModel.provider.providersComboValue.isNotEmpty)
          Expanded(child: Container(
              child: Combo(inRow: true, text: "",
                data: _mainModel.provider.providersCombo,
                value: _mainModel.provider.providersComboValue,
                onChange: (String value){
                  _mainModel.provider.providersComboValue = value;
                  _redraw();
                },))),
      ],
    );
  }

  _sortBy1a(){
    return Row(
      children: [
        Text(strings.get(159) + ":", style: theme.style14W400,), /// "Service",
        if (_mainModel.provider.providersComboValue.isNotEmpty)
          Expanded(child: Container(
              child: Combo(inRow: true, text: "",
                data: _mainModel.service.serviceData,
                value: _mainModel.service.serviceSelected,
                onChange: (String value){
                  _mainModel.service.serviceSelected = value;
                  _redraw();
                },))),
      ]
    );
  }

  _sortBy2(){
    return Row(
      children: [
        Text(strings.get(179) + ":", style: theme.style14W400,), /// "User",
        if (_mainModel.provider.providersComboValue.isNotEmpty)
          Expanded(child: Container(
              child: Combo(inRow: true, text: "",
                data: _mainModel.notifyModel.userData,
                value: _mainModel.notifyModel.userSelected,
                onChange: (String value){
                  _mainModel.notifyModel.userSelected = value;
                  _redraw();
                },))),
      ],
    );
  }

  _sortBy2a() {
    return Row(
        children: [
          Text(strings.get(182) + ":", style: theme.style14W400,), /// "Status",
          if (_mainModel.statusesCombo.isNotEmpty)
            Expanded(child: Container(
                child: Combo(inRow: true, text: "",
                  data: _mainModel.statusesComboForBookingSearch,
                  value: _mainModel.statusesComboValueBookingSearch,
                  onChange: (String value){
                    _mainModel.statusesComboValueBookingSearch = value;
                    _redraw();
                  },))),
        ]
    );
  }

}
