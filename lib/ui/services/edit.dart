import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:ondemand_admin/ui/services/tree_category.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/widgets/buttons/button2.dart';
import '../strings.dart';
import '../theme.dart';
import 'list_providers.dart';

class EditInServices extends StatefulWidget {
  @override
  _EditInServicesState createState() => _EditInServicesState();
}

class _EditInServicesState extends State<EditInServices> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  int _currentPriceLevel = 0;

  final _controllerName = TextEditingController();
  final _controllerDescTitle = TextEditingController();
  final _controllerDesc = TextEditingController();
  final _controllerTax = TextEditingController();
  final _controllerTaxAdmin = TextEditingController();
  final _controllerDuration = TextEditingController();
  //
  final List<TextEditingController> _controllerPrice = [];
  final List<TextEditingController> _controllerDiscPrice = [];
  final List<TextEditingController> _controllerNamePrice = [];
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    for (var i = 0; i < 10; i++){
      _controllerPrice.add(TextEditingController());
      _controllerDiscPrice.add(TextEditingController());
      _controllerNamePrice.add(TextEditingController());
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var i = 0; i < 10; i++){
      _controllerPrice[i].dispose();
      _controllerDiscPrice[i].dispose();
      _controllerNamePrice[i].dispose();
    }
    _controllerDescTitle.dispose();
    _controllerName.dispose();
    _controllerDesc.dispose();
    _controllerTax.dispose();
    _controllerTaxAdmin.dispose();
    _controllerDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    _listener();

    // print("context.read<MainDataModel>().langEditDataComboValue = ${_mainModel.langEditDataComboValue}");
    // print("context.read<MainDataModel>().langDataCombo = ${_mainModel.langDataCombo}");
    List<Widget> list = [];
    //
    // visible and language
    //
    if (isMobile()){
      list.add(checkBox1a(context, strings.get(70), /// "Visible",
          theme.mainColor, theme.style14W400, _mainModel.service.current.visible,
              (val) {
            if (val == null) return;
            _mainModel.service.setVisible(val);
            _noReceive = true;
          }));
      list.add(SizedBox(height: 10,));
      list.add(Row(
        children: [
          Text(strings.get(108), style: theme.style14W400,), /// "Select language",
          Expanded(child: Container(
              width: 120,
              child: Combo(inRow: true, text: "",
                data: _mainModel.langDataCombo,
                value: _mainModel.langEditDataComboValue,
                onChange: (String value){
                  _mainModel.langEditDataComboValue = value;
                  _redraw();
                },))),
        ],
      ));
    }else
      list.add(Row(
        children: [
          Expanded(child: checkBox1a(context, strings.get(70), /// "Visible",
              theme.mainColor, theme.style14W400, _mainModel.service.current.visible,
                  (val) {
                if (val == null) return;
                _mainModel.service.setVisible(val);
                _noReceive = true;
              })),
          Expanded(child: SizedBox(width: 10,)),
          Text(strings.get(108), style: theme.style14W400,), /// "Select language",
          Expanded(child: Container(
                width: 120,
                child: Combo(inRow: true, text: "",
                  data: _mainModel.langDataCombo,
                  value: _mainModel.langEditDataComboValue,
                  onChange: (String value){
                    _mainModel.langEditDataComboValue = value;
                    _redraw();
                  },))),
          ],
      ));
    //
    list.add(SizedBox(height: 10,));
    //
    // name
    //
    list.add(Row(
      children: [
        Expanded(child: textElement2(strings.get(54), "", _controllerName, (String val){         /// "Name",
          _mainModel.service.setName(val);
          _noReceive = true;
        })),
      ],
    )
    );
    list.add(SizedBox(height: 10,));
    //
    if (isMobile()){
      list.add(numberElement2Percentage(strings.get(130), "", _controllerTax, (String val){         /// "Tax",
        _mainModel.service.setTax(val);
        _noReceive = true;
      }));
      list.add(SizedBox(height: 10,));
      list.add(numberElement2Percentage(strings.get(266), "", _controllerTaxAdmin, (String val){         /// "Tax for administration",
        _mainModel.service.setTaxAdmin(val);
        _noReceive = true;
      }));
    }else
    list.add(Row(
      children: [
        Expanded(child: numberElement2Percentage(strings.get(130), "", _controllerTax, (String val){         /// "Tax",
          _mainModel.service.setTax(val);
          _noReceive = true;
        })),
        SizedBox(width: 10,),
        Expanded(child: numberElement2Percentage(strings.get(266), "", _controllerTaxAdmin, (String val){         /// "Tax for administration",
          _mainModel.service.setTaxAdmin(val);
          _noReceive = true;
        })),
      ],
    )
    );
    list.add(SizedBox(height: 10,));
    //
    // description title
    //
    list.add(textElement2(strings.get(120), "", _controllerDescTitle, (String val){           /// Description Title
      _mainModel.service.setDescTitle(val);
      _noReceive = true;
    }));
    list.add(SizedBox(height: 10,));
    //
    // description
    //
    list.add(textElement2(strings.get(73), "", _controllerDesc, (String val){           /// Description
      _mainModel.service.setDesc(val);
      _noReceive = true;
    }));
    list.add(SizedBox(height: 10,));

    //
    // price
    //
    Color _color = Colors.green.withAlpha(20);
    for (var i = 0; i <= _currentPriceLevel; i++) {
      list.add(_price(i, _color));
      if (_color == Colors.green.withAlpha(20))
        _color = Colors.blue.withAlpha(20);
      else
        _color = Colors.green.withAlpha(20);
    }

    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));

    list.add(Row(
      children: [
        Expanded(child: Text(strings.get(347), style: theme.style14W400,), ), /// "Addons",
        SizedBox(width: 10,),
        button2small(strings.get(348), (){  /// "Add addon",
          _mainModel.showDialogAddVariants!();
        })
      ],
    ));
    list.add(SizedBox(height: 10,));
    list.add(_listAddons());

    //
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));
    //
    // Gallery
    //
    list.add(Text(strings.get(128), style: theme.style16W800));                 /// Gallery
    list.add(SizedBox(height: 10,));
    if (_mainModel.service.current.gallery.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mainModel.service.current.gallery.map((e){
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
                              child: Image.network(e.serverPath, fit: BoxFit.cover)
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              alignment: Alignment.topRight,
                              child: IconButton(icon: Icon(Icons.cancel, color: Colors.red,),
                                onPressed: () async {
                                  _noReceive = true;
                                  var ret = await _mainModel.service.deleteImage(e);
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
    //
    list.add(SizedBox(height: 10,));
    list.add(button2small(strings.get(129), (){        /// "Add image to gallery",
      _noReceive = true;
      _selectImageToGallery();
    }));
    //
    list.add(SizedBox(height: 10,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));
    //
    list.add(SizedBox(height: 10,));
    list.add(
      Row(
        children: [
          Expanded(child: Text(strings.get(220) + ":", style: theme.style16W800, overflow: TextOverflow.ellipsis,)), /// "Service duration",
          SizedBox(height: 10,),
          numberElement2("", "10", strings.get(346), _controllerDuration, (String val){  /// "min",
            _noReceive = true;
            _mainModel.service.current.duration = Duration(minutes: int.parse(val));
            _mainModel.serviceApp.needRedraw();
            _redraw();
          })
        ],
      )
        // Theme(
        // data: Theme.of(context).copyWith(
        //     unselectedWidgetColor: Colors.grey,
        //     disabledColor: Colors.grey
        // ),
        // child: DurationPicker(
        //   duration: _mainModel.service.current.duration,
        //   onChange: (val) {
        //     _noReceive = true;
        //     _mainModel.service.current.duration = val;
        //     _mainModel.serviceApp.needRedraw();
        //     setState(() {
        //     });
        //   },
        //   snapToMins: 5.0,
        // ))
    );
    list.add(SizedBox(height: 10,));
    list.add(Column(
          children: [
            Text(strings.get(56), style: theme.style14W800,), /// "Categories",
            SizedBox(height: 5,),
            TreeCategory2()
          ],
    ));
    list.add(SizedBox(height: 10,));
    list.add(Column(
      children: [
        Text(strings.get(96), style: theme.style14W800,), /// "Providers",
        SizedBox(height: 5,),
        ListProvides()
      ],
    ));
    //
    list.add(SizedBox(height: 20,));
    list.add(Divider(thickness: 0.2, color: (theme.darkMode) ? Colors.white : Colors.black,));
    list.add(SizedBox(height: 10,));
    //
    // save
    //
    list.add(SizedBox(height: 20,));
    if (_mainModel.service.current.id.isEmpty)
      list.add(button2small(strings.get(146), () async {        /// "Create new service",
        _noReceive = true;
        var ret = await _mainModel.service.create();
        if (ret == null)
          messageOk(context, strings.get(81)); /// "Data saved",
        else
          messageError(context, ret);
      }));
    else
      list.add(Row(
        children: [
          Expanded(child: button2small(strings.get(147), () async {
            _noReceive = true;
            var ret = await _mainModel.service.save();
            if (ret == null)
              messageOk(context, strings.get(81)); /// "Data saved",
            else
              messageError(context, ret);
          })), /// "Save current service",
          button2small(strings.get(148), _mainModel.service.emptyCurrent)                /// "Add New Service",
        ],
      ));
    return Stack(
      children: [
        Container(
            width: _mainModel.getEditWorkspaceWidth(), //(windowWidth/2 < 600) ? 600 : windowWidth/2,
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
      var ret = await _mainModel.service.addImageToGallery(await pickedFile.readAsBytes());
      if (ret != null)
        messageError(context, ret);
      _waits(false);
    }
  }

  _listener(){
    if (_noReceive){
      _noReceive = false;
      return;
    }
    // print("_listener");
    _nowEdit(context.watch<MainModel>().service.current);
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

  _price(int level, Color _color){
    if (level > 9)
      return Container();
    if (isMobile())
      return Container(
          color: _color,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              numberElement2Price(strings.get(144), /// Price
                  "123", appSettings.symbol, _controllerPrice[level], (String val){
                    _mainModel.service.setPrice(val, level);
                    if (_currentPriceLevel == level) _currentPriceLevel++;
                    _noReceive = true;
                  }, appSettings.digitsAfterComma),
              SizedBox(height: 10,),
              numberElement2Price(strings.get(145), /// Discount price
                  "123", appSettings.symbol, _controllerDiscPrice[level], (String val){
                    _mainModel.service.setDiscPrice(val, level);
                    if (_currentPriceLevel == level) _currentPriceLevel++;
                    _noReceive = true;
                  }, appSettings.digitsAfterComma),
              SizedBox(height: 5,),
              Row(children: [
                Expanded(child: Combo(inRow: true, text: strings.get(151), /// Price Unit
                  data: _mainModel.service.priceUnitCombo,
                  value: _mainModel.service.getPriceUnitCombo(level),
                  onChange: (String value){
                    _mainModel.service.setPriceUnitCombo(value, level);
                    _noReceive = true;
                    _redraw();
                  },)),
              ],),

              SizedBox(height: 5,),

              textElement2(strings.get(54), "", _controllerNamePrice[level], (String val){         /// "Name",
                _mainModel.service.setNamePrice(val, level);
                if (_currentPriceLevel == level) _currentPriceLevel++;
                _noReceive = true;
              }),
              SizedBox(height: 10,),
              button2small(strings.get(75), (){_selectImageForPrice(level);}), /// "Select image",
            ],
          )
      );

    return Container(
        color: _color,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            Row(
              children: [
                numberElement2Price(strings.get(144), /// Price
                    "123", appSettings.symbol, _controllerPrice[level], (String val){
                      _mainModel.service.setPrice(val, level);
                      if (_currentPriceLevel == level) _currentPriceLevel++;
                      _noReceive = true;
                    }, appSettings.digitsAfterComma),
                SizedBox(width: 20,),
                numberElement2Price(strings.get(145), /// Discount price
                    "123", appSettings.symbol, _controllerDiscPrice[level], (String val){
                      _mainModel.service.setDiscPrice(val, level);
                      if (_currentPriceLevel == level) _currentPriceLevel++;
                      _noReceive = true;
                    }, appSettings.digitsAfterComma),

              ],),
            SizedBox(height: 5,),
            Row(children: [
              Expanded(child: Combo(inRow: true, text: strings.get(151), /// Price Unit
                data: _mainModel.service.priceUnitCombo,
                value: _mainModel.service.getPriceUnitCombo(level),
                onChange: (String value){
                  _mainModel.service.setPriceUnitCombo(value, level);
                  _noReceive = true;
                  _redraw();
                },)),
            ],),

            SizedBox(height: 5,),

            Row(
              children: [
                Expanded(child: textElement2(strings.get(54), "", _controllerNamePrice[level], (String val){         /// "Name",
                  _mainModel.service.setNamePrice(val, level);
                  if (_currentPriceLevel == level) _currentPriceLevel++;
                  _noReceive = true;
                })),
                SizedBox(width: 10,),
                button2small(strings.get(75), (){_selectImageForPrice(level);}), /// "Select image",
              ],),

          ],
        )
    );
  }

  _selectImageForPrice(int level) async {
    XFile? pickedFile;
    try{
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      return messageError(context, e.toString());
    }
    if (pickedFile != null){
      _waits(true);
      var ret = await _mainModel.service.setPriceImageData(await pickedFile.readAsBytes(), level);
      if (ret != null)
        messageError(context, ret);
      _waits(false);
    }
  }

  _nowEdit(ProductData select){
    for (var i = 0; i < 10; i++){
      _controllerPrice[i].text = "";
      _controllerDiscPrice[i].text = "";
      _controllerNamePrice[i].text = "";
    }

    var index = 0;
    for (var item in _mainModel.service.current.price){
      _controllerPrice[index].text = item.price.toString();
      textFieldToEnd(_controllerPrice[index]);
      _controllerDiscPrice[index].text = item.discPrice.toString();
      textFieldToEnd(_controllerDiscPrice[index]);
      _controllerNamePrice[index].text = _mainModel.getTextByLocale(item.name);
      textFieldToEnd(_controllerNamePrice[index]);
      index++;
    }
    _currentPriceLevel = index;

    _controllerName.text = _mainModel.getTextByLocale(select.name);
    textFieldToEnd(_controllerName);
    _controllerDescTitle.text = _mainModel.getTextByLocale(select.descTitle);
    textFieldToEnd(_controllerDescTitle);
    _controllerDesc.text = _mainModel.getTextByLocale(select.desc);
    textFieldToEnd(_controllerDesc);
    _controllerTax.text = select.tax.toString();
    textFieldToEnd(_controllerTax);
    _controllerTaxAdmin.text = select.taxAdmin.toString();
    textFieldToEnd(_controllerTaxAdmin);
    _controllerDuration.text = select.duration.inMinutes.toString();
    textFieldToEnd(_controllerDuration);
  }

  _listAddons(){
    List<Widget> list = [];
    for (var item in _mainModel.service.current.addon)
      list.add(Container(
          width: windowWidth*0.2,
          child: Column(
            children: [
              button2ac(_mainModel.getTextByLocale(item.name), theme.style12W600White,
                  "\$${item.price.toStringAsFixed(0)}", theme.style12W600White,
                  theme.mainColor, 10,
                      (){}, true),
            ],
          )));

    return Wrap(
        runSpacing: 10,
        spacing: 10,
        children: list
    );
  }

}