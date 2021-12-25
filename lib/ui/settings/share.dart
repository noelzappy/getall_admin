import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/ui/elements/header.dart';
import 'package:ondemand_admin/ui/strings.dart';
import '../../model/model.dart';
import 'package:provider/provider.dart';
import 'package:abg_utils/abg_utils.dart';

class ShareScreen extends StatefulWidget {
  final Function(bool) waits;
  const ShareScreen({required this.waits});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerGooglePlayLink = TextEditingController();
  final _controllerAppStoreLink = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _controllerGooglePlayLink.text = appSettings.googlePlayLink;
    _controllerAppStoreLink.text = appSettings.appStoreLink;
    super.initState();
  }

  @override
  void dispose() {
    _controllerGooglePlayLink.dispose();
    _controllerAppStoreLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return body(strings.get(42), "assets/dashboard2/dashboard5.png", _getList()); /// "Settings | Share This App Menu",
  }

  _getList() {
    List<Widget> list = [];

    list.add(SizedBox(height: 20,));
    list.add(textElement(strings.get(43), "", _controllerGooglePlayLink)); // Google Play Link
    list.add(SizedBox(height: 20,));
    list.add(textElement(strings.get(44), "", _controllerAppStoreLink)); // AppStore Link

    list.add(SizedBox(height: 50,));
    list.add(Center(child: button2small(strings.get(9), _save))); // "Save"

    list.add(SizedBox(height: 100,));

    return list;
  }

  _save() async {
    // demo mode
    if (appSettings.demo)
      return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
    widget.waits(true);
    var ret = await _mainModel.settings.saveSettingsShare(_controllerGooglePlayLink.text, _controllerAppStoreLink.text);
    if (ret == null)
      messageOk(context, strings.get(81)); /// "Data saved",
    else
      messageError(context, ret);
    widget.waits(false);
  }
}


