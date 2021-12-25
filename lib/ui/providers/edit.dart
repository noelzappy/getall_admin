import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/providers/tree.dart';
import '../strings.dart';
import '../theme.dart';
import 'map.dart';

class EditInProvider extends StatefulWidget {
  @override
  _EditInProviderState createState() => _EditInProviderState();
}

class _EditInProviderState extends State<EditInProvider> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;

  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerDesc = TextEditingController();
  final _controllerAddress = TextEditingController();
  final _controllerDescTitle = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerWww = TextEditingController();
  final _controllerTelegram = TextEditingController();
  final _controllerInstagram = TextEditingController();
  final _controllerTax = TextEditingController();
  final dataKey = GlobalKey();
  late MainModel _mainModel;

  @override
  void dispose() {
    _controllerTelegram.dispose();
    _controllerInstagram.dispose();
    _controllerEmail.dispose();
    _controllerPhone.dispose();
    _controllerWww.dispose();
    _controllerDescTitle.dispose();
    _controllerName.dispose();
    _controllerDesc.dispose();
    _controllerAddress.dispose();
    _controllerTax.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (Provider.of<MainModel>(context,listen:false).provider.newProvider != null){
        var currentContext = dataKey.currentContext;
        if (currentContext != null)
          Scrollable.ensureVisible(currentContext, duration: Duration(seconds: 1));
        _controllerEmail.text = Provider.of<MainModel>(context,listen:false).provider.current.login;
        _controllerName.text = getTextByLocale(_mainModel.provider.current.name, strings.locale);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    _listener();

    List<Widget> list = [];
    //
    // visible and language
    //
    if (isMobile()){
      list.add(checkBox1a(context, strings.get(70), // "Visible",
          theme.mainColor, theme.style14W400, _mainModel.provider.current.visible,
              (val) {
            if (val == null) return;
            Provider.of<MainModel>(context,listen:false).provider.setVisible(val);
            _noReceive = true;
          }));
      list.add(SizedBox(height: 10));
      list.add(Row(
        children: [
          Text(strings.get(108), style: theme.style14W400,), /// "Select language",
          Expanded(child: Container(
              width: 120,
              child: Combo(
                inRow: true, text: "",
                data: _mainModel.langDataCombo,
                value: _mainModel.langEditDataComboValue,
                onChange: (String value){
                  Provider.of<MainModel>(context,listen:false).langEditDataComboValue = value;
                  setState(() {});
                },))),
        ],
      ));
    }else
      list.add(Row(
        children: [
          Expanded(child: checkBox1a(context, strings.get(70), // "Visible",
              theme.mainColor, theme.style14W400, _mainModel.provider.current.visible,
                  (val) {
                if (val == null) return;
                Provider.of<MainModel>(context,listen:false).provider.setVisible(val);
                _noReceive = true;
              })),
          Expanded(child: SizedBox(width: 10,)),
          Text(strings.get(108), style: theme.style14W400,), /// "Select language",
          Expanded(child: Container(
                width: 120,
                child: Combo(
                  inRow: true, text: "",
                  data: _mainModel.langDataCombo,
                  value: _mainModel.langEditDataComboValue,
                  onChange: (String value){
                    Provider.of<MainModel>(context,listen:false).langEditDataComboValue = value;
                    setState(() {});
                  },))),
          ],
      ));
    //
    list.add(SizedBox(height: 10,));
    if (Provider.of<MainModel>(context,listen:false).provider.newProvider != null){
      list.add(Center(child: Text(strings.get(249), style: theme.style16W800Red, textAlign: TextAlign.center,))); /// For assign new provider set needed fields...
      list.add(SizedBox(height: 10,));
    }
    //
    // name
    //
    if (isMobile()){
      list.add(textElement2(strings.get(54), "", _controllerName, (String val){         /// "Name",
        _mainModel.provider.setName(val);
        _noReceive = true;
      }));
      list.add(SizedBox(height: 10,));
      list.add(textElement2(strings.get(248), "", _controllerEmail, (String val){         /// "Login Email",
        _mainModel.provider.setEmail(val);
        _noReceive = true;
      }));
    }else
      list.add(Row(
        children: [
          Expanded(child: textElement2(strings.get(54), "", _controllerName, (String val){         /// "Name",
            _mainModel.provider.setName(val);
            _noReceive = true;
          })),
          SizedBox(width: 10,),
          Expanded(child: textElement2(strings.get(248), "", _controllerEmail, (String val){         /// "Login Email",
            _mainModel.provider.setEmail(val);
            _noReceive = true;
          })),
        ],
      ));

    list.add(SizedBox(
      key: dataKey,
      height: 10,));
    //
    // description title
    //
    list.add(numberElement2Percentage(strings.get(265), "", _controllerTax, (String val){         /// "Default Tax for provider (administration payment)",
      _mainModel.provider.setTax(val);
      _noReceive = true;
    }));
    list.add(SizedBox(height: 10,));
    list.add(textElement2(strings.get(120), "", _controllerDescTitle, (String val){           /// Description Title
      _mainModel.provider.setDescTitle(val);
      _noReceive = true;
    }));

    list.add(SizedBox(height: 10,));
    //
    // description
    //
    list.add(textElement2(strings.get(73), "", _controllerDesc, (String val){           /// Description
      _mainModel.provider.setDesc(val);
      _noReceive = true;
    }));
    list.add(SizedBox(height: 10,));
    //
    // address
    //
    list.add(textElement2(strings.get(97), "", _controllerAddress, (String val){           /// Address
      _mainModel.provider.setAddress(val);
      _noReceive = true;
    }));
    list.add(SizedBox(height: 10,));
    list.add(MapWithRegionCreation());
    list.add(Divider());
    //
    // Up Image and logo
    //
    list.add(Row(
      children: [
        Text(strings.get(118), style: theme.style14W400,),                                /// Upper image
        SizedBox(width: 15,),
        button2small(strings.get(75), _selectUpperImage), /// "Select image",
      ],
    ));
    list.add(SizedBox(height: 10,));
    list.add(Row(
      children: [
        Text(strings.get(119), style: theme.style14W400,),                                ///  Logo image
        SizedBox(width: 15,),
        button2small(strings.get(75), _selectLogoImage) /// "Select image",
      ],
    ));
    list.add(SizedBox(height: 10,));
    //
    // category
    //
    list.add(TreeInProvider());
    list.add(SizedBox(height: 10,));
    //
    // phone + web page
    //
    list.add(Row(
      children: [
        Expanded(child: textElement2(strings.get(124), "", _controllerPhone, (String val){         /// "Phone",
          _mainModel.provider.setPhone(val);
          _noReceive = true;
        })),
        SizedBox(width: 10,),
        Expanded(child: textElement2(strings.get(125), "", _controllerWww, (String val){         /// "Web Page",
          _mainModel.provider.setWWW(val);
          _noReceive = true;
        })),
      ],
    ));
    list.add(SizedBox(height: 10,));
    //
    // telegram + instagram
    //
    list.add(Row(
      children: [
        Expanded(child: textElement2(strings.get(126), "", _controllerTelegram, (String val){         /// "Telegram",
          _mainModel.provider.setTelegram(val);
          _noReceive = true;
        })),
        SizedBox(width: 10,),
        Expanded(child: textElement2(strings.get(127), "", _controllerInstagram, (String val){         /// "Instagram",
          _mainModel.provider.setInstagram(val);
          _noReceive = true;
        })),
      ],
    ));
    list.add(SizedBox(height: 10,));
    //
    // Gallery
    //
    list.add(Text(strings.get(128), style: theme.style16W800)); /// Gallery
    list.add(SizedBox(height: 10,));
    if (_mainModel.provider.current.gallery.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mainModel.provider.current.gallery.map((e){
            var _tag = UniqueKey().toString();
            return InkWell(
                onTap: (){
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => GalleryScreen(item: e, gallery: images, tag: _tag),
                  //     )
                  // );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  child: Hero(
                    tag: _tag,
                    child: Stack(
                          children: [
                            Container(
                              child:  Image.network(e.serverPath, fit: BoxFit.cover,)
                              // (e.name != null) ?
                              // Image.asset(e.name!, fit: BoxFit.cover) :
                              // Image.memory(e.image!, fit: BoxFit.cover)
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              alignment: Alignment.topRight,
                              child: IconButton(icon: Icon(Icons.cancel, color: Colors.red,),
                                onPressed: () async {
                                  _noReceive = true;
                                  var ret = await context.read<MainModel>().provider.deleteImage(e);
                                  if (ret == null)
                                    messageOk(context, strings.get(219)); /// "Image deleted",
                                  else
                                    messageError(context, ret);
                                },),
                            )
                    ],
              )))
            );
          }).toList(),
        ),
      ));
    list.add(SizedBox(height: 10,));
    list.add(button2small(strings.get(129), _selectImageToGallery));        /// "Add image to gallery",
    //
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    list.add(Text(strings.get(133), style: theme.style16W800,));                /// "Working time",
    list.add(SizedBox(height: 10,));
    if (isMobile()){
      list.add(_time1());
      list.add(SizedBox(height: 10,));
      list.add(_time2());
    }else
      list.add(Row(
        children: [
              Expanded(child: _time1()),
              SizedBox(width: 10,),
              Expanded(child: _time2())
              ],
            )
        );

    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));
    //
    // save
    //
    list.add(SizedBox(height: 20,));
    if (context.read<MainModel>().provider.current.id.isEmpty)
      list.add(button2small(strings.get(121), () async {        /// "Create new provider",
        _noReceive = true;
        var ret = await _mainModel.provider.create();
        if (ret == null)
          messageOk(context, strings.get(81)); /// "Data saved",
        else
          messageError(context, ret);
      }));
    else
      list.add(Row(
        children: [
          Expanded(child: button2small(strings.get(122), () async {  /// "Save current provider",
            _noReceive = true;
            var ret = await _mainModel.provider.save();
            if (ret == null)
              messageOk(context, strings.get(81)); /// "Data saved",
            else
              messageError(context, ret);
          })),
          button2small(strings.get(123), _mainModel.provider.emptyCurrent)                /// "Add New Provider",
        ],
      ));

    return Stack(
      children: [
        Container(
            width: (windowWidth/2 < 600) ? 600 : windowWidth/2,
            decoration: BoxDecoration(
              color: (theme.darkMode) ? theme.blackColorTitleBkg : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
            children: [
              Positioned.fill(child: AnimatedContainer(
                  decoration: BoxDecoration(
                    color: (_select) ? Colors.grey.withAlpha(100) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: Duration(seconds: 1))),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                children: list,
              )),
              if (_wait)
                Positioned.fill(
                  child: Center(child: Container(child: Loader7(color: theme.mainColor,))),
                ),
            ],
            )
        ),
      ],
    );
  }

  _time1(){
    return Row(
      children: [
        Expanded(child: Combo(inRow: true, text: "",
              data: _mainModel.provider.weekDataCombo,
              value: _mainModel.provider.weekDataComboValue,
              onChange: (String value){
                _mainModel.provider.weekDataComboValue = value;
                setState(() {});
                _noReceive = true;
              },)),
        SizedBox(width: 10,),
        Expanded(child: checkBox1a(context, strings.get(141), /// "Weekend",
            theme.mainColor, theme.style14W400, _mainModel.provider.getWeekend(),
                (val) {
              if (val == null) return;
              _noReceive = true;
              _mainModel.provider.setWeekend(val);
              setState(() {});
            })),
      ],
    );
  }

  _time2(){
    return Row(
        children: [
          InkWell(
              onTap: () async {
                await _mainModel.provider.selectOpenDate(context);
                setState(() {});
                _noReceive = true;
              },
              child: Container(
                  width: 100,
                  height: 40,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: dashboardColorForEdit,
                      width: 1.0,
                    ),
                  ),
                  child: Center(child: Text(_mainModel.provider.getOpenTime(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),))
              )),
          SizedBox(width: 20,),
          SelectableText(" - ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
          SizedBox(width: 5,),
          InkWell(
              onTap: () async {
                await _mainModel.provider.selectCloseDate(context);
                setState(() {});
                _noReceive = true;
              },
              child: Container(
                  width: 100,
                  height: 40,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: dashboardColorForEdit,
                      width: 1.0,
                    ),
                  ),
                  child: Center(child: Text(Provider.of<MainModel>(context,listen:false).provider.getCloseTime(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),))
              )

          )
        ]
    );
  }

  bool _wait = false;
  _waits(bool value){
    _wait = value;
    _redraw();
  }
  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _selectImageToGallery() async {
    XFile? pickedFile;
    try{
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      return messageError(context, e.toString());
    }
    if (pickedFile != null){
      _waits(true);
      var ret = await Provider.of<MainModel>(context,listen:false).provider.addImageToGallery(await pickedFile.readAsBytes());
      if (ret != null)
        messageError(context, ret);
      else
        messageOk(context, strings.get(363)); /// "Image saved",
      _waits(false);
    }
  }

  Future<String?> _selectLogoImage() async {
    XFile? pickedFile;
    try{
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      return messageError(context, e.toString());
    }
    if (pickedFile != null){
      _waits(true);
      var ret = await Provider.of<MainModel>(context,listen:false).provider.setLogoImageData(await pickedFile.readAsBytes());
      if (ret != null)
      //   messageOk(context, "${strings.get(81)}"); /// "Data saved",
      // else
        messageError(context, ret);
      _waits(false);
    }
  }

  _selectUpperImage() async {
    XFile? pickedFile;
    try{
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      return messageError(context, e.toString());
    }
    if (pickedFile != null){
      _waits(true);
      var ret = await Provider.of<MainModel>(context,listen:false).provider.setUpperImageData(await pickedFile.readAsBytes());
      if (ret != null)
      //   messageOk(context, "${strings.get(81)}"); /// "Data saved",
      // else
        messageError(context, ret);
      _waits(false);
    }
  }

  _listener(){
    if (_noReceive){
      _noReceive = false;
      return;
    }
    _nowEdit();
    if (_initListen){
      _initListen = false;
      return;
    }
    _select = true;
    _initListen = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      _select = false;
      setState(() {
      });
    });

  }

  bool _initListen = false;
  bool _select = false;
  bool _noReceive = false;

  _nowEdit(){
    ProviderData _selectInEmulator = _mainModel.provider.current;
    if (_selectInEmulator.id.isEmpty)
      _controllerTax.text = appSettings.defaultAdminComission.toString();
    else
      _controllerTax.text = _selectInEmulator.tax.toString();
    _controllerName.text = _mainModel.getTextByLocale(_selectInEmulator.name);
    textFieldToEnd(_controllerName);
    _controllerPhone.text = _selectInEmulator.phone;
    textFieldToEnd(_controllerPhone);
    _controllerEmail.text = _selectInEmulator.login;
    textFieldToEnd(_controllerEmail);
    _controllerDesc.text = _mainModel.getTextByLocale(_selectInEmulator.desc);
    textFieldToEnd(_controllerDesc);
    _controllerDescTitle.text = _mainModel.getTextByLocale(_selectInEmulator.descTitle);
    textFieldToEnd(_controllerDescTitle);
    _controllerTelegram.text = _selectInEmulator.telegram;
    textFieldToEnd(_controllerTelegram);
    _controllerInstagram.text = _selectInEmulator.instagram;
    textFieldToEnd(_controllerInstagram);
    _controllerAddress.text = _selectInEmulator.address;
    textFieldToEnd(_controllerAddress);
    _controllerWww.text = _selectInEmulator.www;
    textFieldToEnd(_controllerWww);
  }

}