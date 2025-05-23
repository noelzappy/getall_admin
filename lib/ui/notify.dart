import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/widgets/combo.dart';
import 'package:provider/provider.dart';
import '../model/responsive.dart';
import 'strings.dart';
import 'theme.dart';

class NotifyScreen extends StatefulWidget {
  final Function(bool) waits;
  const NotifyScreen({required this.waits});

  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerTitle = TextEditingController();
  final _controllerText = TextEditingController();

  late MainModel _mainModel;

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

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerText.dispose();
    super.dispose();
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
      ) ,
      child: ListView(
        children: _getList(),
      ),
    );
  }

  _getList() {
    List<Widget> list = [];

    list.add(SizedBox(height: 10,));
    list.add(Row(
      children: [
        Expanded(child: SelectableText(strings.get(13), style: theme.style25W800)), /// "Send Notification"
        // button2small(strings.get(21), (){}) /// "View all messages"
      ],
    ));
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));

    if (isMobile()) {
      list.add(Combo(text: strings.get(15), /// "Select user:"
        data: _mainModel.notifyModel.userDataWithProviders,
        value: _mainModel.notifyModel.userSelectedWithProviders,
        onChange: (String value){
          _mainModel.notifyModel.userSelectedWithProviders = value; setState(() {});
        },));
      list.add(textElement(strings.get(16), strings.get(19), _controllerTitle)); /// "Message Title:" - "Title of message";
    }else
      list.add(Row(
        children: [
          Expanded(child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            SelectableText(strings.get(15), style: theme.style14W400), /// "Select user:"
            SizedBox(height: 5,),
            popupWidget(windowWidth, _mainModel.notifyModel.userDataWithProviders,
            _mainModel.notifyModel.userSelectedWithProviders,
              (String value){
                _mainModel.notifyModel.userSelectedWithProviders = value; setState(() {});
            },),
          ],))),
          SizedBox(width: 20,),
          Expanded(child: textElement(strings.get(16), strings.get(19), _controllerTitle)) // "Message Title:" "Title of message";
        ]
      ));

    list.add(textElement(strings.get(18), strings.get(20), _controllerText)); // "Message Text:" - "Text of message",

    list.add(SizedBox(height: 40,));
    list.add(Center(child: button2small(strings.get(17), _send))); // "Send"
    list.add(SizedBox(height: 100,));

    return list;
  }

  _send() async {
    if (_controllerTitle.text.isEmpty)
      return messageError(context, strings.get(222)); /// "Please enter Title"
    if (_controllerText.text.isEmpty)
      return messageError(context, strings.get(223)); /// "Please enter Message Text"

    var _select = _mainModel.notifyModel.userSelectedWithProviders;
    if (_select != "-1") {
      /// one user
      for (var item in _mainModel.notifyModel.users)
        if (item.id == _select){
          var ret = await sendMessage(_controllerTitle.text,
              _controllerText.text, item.id, true, appSettings.cloudKey);
          if (ret == null)
            messageOk(context, strings.get(224)); /// "Message send",
          else
            messageError(context, ret);
        }
    }else{
      /// all users
      for (var item in _mainModel.notifyModel.users){
        if (item.id != "-1")
          continue;
        var ret = await sendMessage(_controllerTitle.text,
            _controllerText.text, item.id, true, appSettings.cloudKey);//item.fcb, item.id);
        if (ret != null)
          return messageError(context, ret);
      }
      messageOk(context, strings.get(224)); /// "Message send",
    }
  }
}


