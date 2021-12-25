import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class ElementSelectDateTime extends StatefulWidget {

  final Function(DateTime) setDateTime;
  final Function() getText;

  const ElementSelectDateTime({Key? key, required this.setDateTime, required this.getText}) : super(key: key);

  @override
  _ElementSelectDateTimeState createState() => _ElementSelectDateTimeState();
}

class _ElementSelectDateTimeState extends State<ElementSelectDateTime> {

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
          _selectDateTime();
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 100,),
            child: Container(
                height: 35,
                padding: EdgeInsets.only(top: 3, left: 7, right: 7, bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(widget.getText(), style: theme.style16W800White), ))
        ));
  }

  _selectDateTime(){
    var _widget = CupertinoDatePicker(
      initialDateTime: DateTime.now(),
      onDateTimeChanged: (DateTime picked) {
        widget.setDateTime(picked);
        // setState(() {
        //   _text6 = DateFormat('yyyy.MM.dd').format(DateTime(picked.year, picked.month, picked.day));
        // });
      },
      use24hFormat: true,
      mode: CupertinoDatePickerMode.dateAndTime,
    );

    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return _widget;
        });
  }
}
