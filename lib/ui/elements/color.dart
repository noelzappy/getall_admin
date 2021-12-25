import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ElementSelectColor extends StatefulWidget {

  final Function(Color) setColor;
  final Function() getColor;

  const ElementSelectColor({Key? key, required this.setColor, required this.getColor}) : super(key: key);

  @override
  _ElementSelectColorState createState() => _ElementSelectColorState();
}

class _ElementSelectColorState extends State<ElementSelectColor> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return InkWell(
        onTap: () {
          _selectColor();
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 100,),
            child: Container(
                height: 35,
                padding: EdgeInsets.only(top: 3, left: 7, right: 7, bottom: 3),
                decoration: BoxDecoration(
                  color: widget.getColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text("0x${widget.getColor().value.toRadixString(16).padLeft(8, '0')}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), ))
        ));
  }

  _selectColor(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: widget.getColor(),
              onColorChanged: (Color color) => setState(() => widget.setColor(color)),
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2.0),
                topRight: Radius.circular(2.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
