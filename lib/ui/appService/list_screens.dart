import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import '../theme.dart';

class ListScreens extends StatefulWidget {
  @override
  _ListScreensState createState() => _ListScreensState();
}

class _ListScreensState extends State<ListScreens> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;

  final _controllerName = TextEditingController();
  final _controllerDesc = TextEditingController();
  final _controllerAddress = TextEditingController();

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
    _controllerAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    return Stack(
      children: [
        Container(
            width: (windowWidth/2 < 600) ? 600 : windowWidth/2,
            decoration: BoxDecoration(
              color: (theme.darkMode) ? theme.blackColorTitleBkg : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _horizontal(),
        ),
      ],
    );
  }

  _horizontal(){
    List<Widget> list = [];

    for (var item in _mainModel.serviceApp.screens){
      list.add(InkWell(
        onTap: (){
          Provider.of<MainModel>(context,listen:false).serviceApp.selectScreen(item);
          setState(() {
          });
        },
        child: Container(
            width: 100,
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Image.asset(item.image,
                        fit: BoxFit.contain
                    ),
                    if (item == _mainModel.serviceApp.select)
                      Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(50),
                          ))
                  ],),
                SizedBox(height: 5,),
                Text(item.name, style: theme.style12W800,),
              ],
            )
        ),
      ));
      list.add(SizedBox(width: 10,));
    }
    list.add(SizedBox(width: 200,));
    return Container(
      height: 250,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }
}