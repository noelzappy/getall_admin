import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import 'package:provider/provider.dart';
import 'package:ondemand_admin/ui/elements/color.dart';
import '../strings.dart';
import '../theme.dart';

class EditInCategory extends StatefulWidget {
  @override
  _EditInCategoryState createState() => _EditInCategoryState();
}

class _EditInCategoryState extends State<EditInCategory> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerName = TextEditingController();
  final _controllerDesc = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerDesc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    _listener();

    List<Widget> list = [];

    // language
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
                setState(() {});
              },))),
      ],
    ));
    list.add(SizedBox(height: 10,));
    //
    // visible and Show Category Details in Main Screen",
    //
    list.add(Row(
      children: [
        Expanded(child: checkBox1a(context, strings.get(70), // "Visible",
            theme.mainColor, theme.style14W400, _mainModel.category.current.visible,
                (val) {
              if (val == null) return;
              _mainModel.category.setVisible(val);
              _noReceive = true;
            })),
        SizedBox(width: 10,),
        Expanded(child: checkBox1a(context, strings.get(71), // "Show Category Details in Main Screen",
            theme.mainColor, theme.style14W400, _mainModel.category.current.visibleCategoryDetails,
                (val) {
              if (val == null) return;
              _mainModel.category.setVisibleCategoryDetails(val);
              _noReceive = true;
            }))
      ],
    ));
    //
    list.add(SizedBox(height: 10,));
    //
    // name
    //
    list.add(textElement2(strings.get(54), "", _controllerName, (String val){
      _mainModel.category.setName(val);
      _noReceive = true;
    })); // "Name",
    list.add(SizedBox(height: 10,));
    //
    // color & description
    //
    _setColor(Color color) => _mainModel.category.setColor(color);
    if (isMobile()){
      list.add(Row(
          children: [
          SelectableText(strings.get(72), style: theme.style14W400,), // "Select color",
          SizedBox(width: 10,),
          Container(
          width: 150,
          child: ElementSelectColor(getColor: (){return _mainModel.category.current.color;}, setColor: _setColor,),
        ),])
      );
      list.add(SizedBox(height: 10));
      list.add(textElement2(strings.get(73), "", _controllerDesc, (String val){ // Description
        _mainModel.category.setDesc(val);
        _noReceive = true;
      }));
    }else
      list.add(Row(
        children: [
          SelectableText(strings.get(72), style: theme.style14W400,), // "Select color",
          SizedBox(width: 10,),
          Container(
            width: 150,
            child: ElementSelectColor(getColor: (){return _mainModel.category.current.color;}, setColor: _setColor,),
          ),
          SizedBox(width: 10,),
          Expanded(child:textElement2(strings.get(73), "", _controllerDesc, (String val){ // Description
            _mainModel.category.setDesc(val);
            _noReceive = true;
          }))
        ],
      ));
    //
    // parent category
    // and
    // image
    //
    list.add(SizedBox(height: 10,));
    if (isMobile()){
      list.add(Combo(inRow: true, text: strings.get(74), /// "Select parent category",
        data: _mainModel.category.parentsData,
        value: _mainModel.category.current.parent,
        onChange: (String value){
          _mainModel.category.setParent(value);
        },));
      list.add(SizedBox(height: 20,));
      list.add(button2small(strings.get(75), _selectImage)); /// "Select image",
    }else
      list.add(Row(
        children: [
          Expanded(child: Combo(inRow: true, text: strings.get(74), /// "Select parent category",
            data: _mainModel.category.parentsData,
            value: _mainModel.category.current.parent,
            onChange: (String value){
              _mainModel.category.setParent(value);
            },)),
          SizedBox(width: 20,),
          button2small(strings.get(75), _selectImage) /// "Select image",
        ],
      ));
    //
    // save
    //
    list.add(SizedBox(height: 20,));
    if (_mainModel.category.current.id.isEmpty)
      list.add(button2small(strings.get(77), () async {        /// "Create new category",
        var ret = await _mainModel.category.create();
        if (ret == null)
          messageOk(context, strings.get(81)); /// "Data saved",
        else
          messageError(context, ret);
      }));
    else
      list.add(Row(
        children: [
          Expanded(child: button2small(strings.get(76), () async {
            var ret = await _mainModel.category.save();
            if (ret == null)
              messageOk(context, strings.get(81)); /// "Data saved",
            else
              messageError(context, ret);
          })), /// "Save current category",
          button2small(strings.get(57), (){                 /// "Add New Category",
            _mainModel.category.emptyCurrent();
          })
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
            ],
            )
        ),
        if (_wait)
          Positioned.fill(
            child: Center(child: Container(child: Loader7(color: theme.mainColor,)))),
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

  _selectImage() async {
    XFile? pickedFile;
    try{
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      return messageError(context, e.toString());
    }
    if (pickedFile != null){
      _waits(true);
      var ret = await _mainModel.category.setImageData(await pickedFile.readAsBytes());
      if (ret == null)
        messageOk(context, strings.get(363)); /// "Image saved",
      else
        messageError(context, ret);
      _waits(false);
    }
  }

  _listener(){
    var selectInEmulator = context.watch<MainModel>().category.current;

    if (_noReceive){
      _noReceive = false;
      return;
    }
    _nowEdit(selectInEmulator);
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

  _nowEdit(CategoryData data){
    _controllerName.text = _mainModel.getTextByLocale(data.name);
    textFieldToEnd(_controllerName);
    _controllerDesc.text = _mainModel.getTextByLocale(data.desc);
    textFieldToEnd(_controllerDesc);
  }
}