import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/strings.dart';
import 'package:ondemand_admin/ui/theme.dart';
import 'package:ondemand_admin/widgets/buttons/button168.dart';
import '../../../utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

import '../model/responsive.dart';

class ReviewScreen extends StatefulWidget {
  final Function(bool) waits;
  const ReviewScreen({required this.waits});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

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
      var ret = await initReviews();
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
        Expanded(child: SelectableText(strings.get(261), /// Service Reviews list
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

    for (var item in reviews){
      if (!item.userName.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !item.text.toUpperCase().contains(_searchedValue.toUpperCase()) &&
          !item.serviceName.toUpperCase().contains(_searchedValue.toUpperCase())
      ) continue;

      dprint("review ${item.time} ${item.timeModify}");

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

  _item(ReviewsData item){
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
                  child: (item.userAvatar.isEmpty) ? CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"), radius: 50,) :
                  ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                          item.userAvatar,
                          height: 80,
                          fit: BoxFit.cover))),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    SelectableText(strings.get(262) + ":", style: theme.style14W600Grey,), /// "User name",
                    SizedBox(width: 10,),
                    Expanded(child: Text(item.userName, style: theme.style14W800),)
                  ]),
                  SizedBox(height: 10,),
                  Row(children: [
                    SelectableText(strings.get(159) + ":", style: theme.style14W600Grey,), /// "Service",
                    SizedBox(width: 10,),
                    Expanded(child: Text(item.serviceName, style: theme.style14W800),)
                  ]),
                  SizedBox(height: 10,),
                  Row(children: [
                    if (item.rating >= 1)
                      Icon(Icons.star, color: Colors.orange, size: 16,),
                    if (item.rating < 1)
                      Icon(Icons.star_border, color: Colors.orange, size: 16,),
                    if (item.rating >= 2)
                      Icon(Icons.star, color: Colors.orange, size: 16,),
                    if (item.rating < 2)
                      Icon(Icons.star_border, color: Colors.orange, size: 16,),
                    if (item.rating >= 3)
                      Icon(Icons.star, color: Colors.orange, size: 16,),
                    if (item.rating < 3)
                      Icon(Icons.star_border, color: Colors.orange, size: 16,),
                    if (item.rating >= 4)
                      Icon(Icons.star, color: Colors.orange, size: 16,),
                    if (item.rating < 4)
                      Icon(Icons.star_border, color: Colors.orange, size: 16,),
                    if (item.rating >= 5)
                      Icon(Icons.star, color: Colors.orange, size: 16,),
                    if (item.rating < 5)
                      Icon(Icons.star_border, color: Colors.orange, size: 16,),
                    SizedBox(width: 10,),
                    SelectableText(item.rating.toString(), style: theme.style14W600Grey,),
                    SizedBox(width: 20,),
                    Text(_mainModel.getDateTimeString(item.time), style: theme.style12W400)
                  ]),
                  SizedBox(height: 10,),
                  Text(item.text, style: theme.style12W400),

                  if (item.images.isNotEmpty)
                    Row(children: [
                      Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 10,
                              runSpacing: 10,
                              children: item.images.map((e){
                                return InkWell(
                                  onTap: (){
                                    openGalleryScreen(item.images, e);
                                  },
                                  child: Container(
                                      width: 100,
                                      height: 100,
                                      child: Image.network(e.serverPath,
                                          fit: BoxFit.contain
                                      )),
                                );
                              }).toList(),
                            ),
                          )
                      )
                    ],)

                ],
              )),
              SizedBox(width: 10,),
              button2c(strings.get(62), Colors.red, /// "Delete",
                  (){_delete(item);}),
              SizedBox(width: 10,),
            ],
          ),

        ],
      ),
    );
  }

  _delete(ReviewsData item){
      openDialogDelete(() async {
        Navigator.pop(context); // close dialog
        var ret = await deleteReview(item);
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
    _mainModel.copyReviews();
    messageOk(context, strings.get(53)); /// "Data copied to clipboard"
  }

  _csv(){
    html.AnchorElement()
      ..href = '${Uri.dataFromString(_mainModel.csvReviews(), mimeType: 'text/plain', encoding: utf8)}'
      ..download = "reviews.csv"
      ..style.display = 'none'
      ..click();
  }

  String _searchedValue = "";
  _onSearch(String value){
    _searchedValue = value;
   _redraw();
  }
}
