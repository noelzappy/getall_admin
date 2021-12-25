import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/ui/elements/header.dart';
import 'package:ondemand_admin/ui/strings.dart';
import '../../model/model.dart';
import 'package:ondemand_admin/ui/elements/text.dart';
import 'package:provider/provider.dart';

class DocumentsScreen extends StatefulWidget {
  final Function(bool) waits;
  const DocumentsScreen({required this.waits});

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerCopyright = TextEditingController();
  final _controllerPrivacy = TextEditingController();
  final _controllerAbout = TextEditingController();
  final _controllerTerms = TextEditingController();

  @override
  void initState() {
    _controllerCopyright.text = appSettings.copyright;
    _controllerPrivacy.text = appSettings.policy;
    _controllerAbout.text = appSettings.about;
    _controllerTerms.text = appSettings.terms;
    super.initState();
  }

  @override
  void dispose() {
    _controllerCopyright.dispose();
    _controllerPrivacy.dispose();
    _controllerAbout.dispose();
    _controllerTerms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return body(strings.get(22), "assets/dashboard2/dashboard6.png", _getList()); /// "Settings | Documents",
  }

  _getList() {
    List<Widget> list = [];

    list.add(textElement(strings.get(23), "", _controllerCopyright)); // "Copyright text:",
    list.add(SizedBox(height: 20,));
    list.add(documentBlock(strings.get(24) + ":" + strings.get(200), _controllerAbout, "", (){setState(() {});})); // "About Us:",  "You can use HTML tags (<p>, <br>, <h1> and other)"
    list.add(SizedBox(height: 20,));
    list.add(documentBlock(strings.get(26) + ":" + strings.get(200), _controllerPrivacy, "", (){setState(() {});})); // "Privacy Policy:",
    list.add(SizedBox(height: 20,));
    list.add(documentBlock(strings.get(27) + ":" + strings.get(200), _controllerTerms, "", (){setState(() {});})); // "Terms & Conditions",

    list.add(SizedBox(height: 20,));
    list.add(Center(child: button2small(strings.get(9), _save))); // "Save"

    list.add(SizedBox(height: 100,));

    return list;
  }

  _save() async {
    // demo mode
    if (appSettings.demo)
      return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
    widget.waits(true);
    var ret = await Provider.of<MainModel>(context,listen:false).
        saveSettingsDocuments(_controllerCopyright.text, _controllerAbout.text,
        _controllerPrivacy.text, _controllerTerms.text
    );
    if (ret == null)
      messageOk(context, strings.get(81)); /// "Data saved",
    else
      messageError(context, ret);
    widget.waits(false);
  }
}


