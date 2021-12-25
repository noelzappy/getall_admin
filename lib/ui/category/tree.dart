import 'dart:math';

import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';

class TreeInCategory extends StatefulWidget {
  final Function(CategoryData value) deleteDialog;

  const TreeInCategory({Key? key, required this.deleteDialog}) : super(key: key);
  @override
  _TreeInCategoryState createState() => _TreeInCategoryState();
}

class _TreeInCategoryState extends State<TreeInCategory> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final ScrollController _controllerTree = ScrollController();

  @override
  void dispose() {
    _controllerTree.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    _listener();

    List<Widget> list2 = [];
    list2.add(SelectableText(strings.get(232), /// Category tree
      style: theme.style18W800,));
    list2.add(SizedBox(height: 10,));
    getListTree(list2, "", 30,);

    return treeWindow(list2);
  }

  String selectId = "";

  _listener(){
    var selectInEmulator = context.watch<MainModel>().category.current;

    selectId = selectInEmulator.id;
    var currentContext = selectInEmulator.dataKey2.currentContext;
    if (currentContext != null){
      Scrollable.ensureVisible(currentContext, duration: Duration(seconds: 1));
    }
  }

  treeWindow(List<Widget> list2){
    return
      // SingleChildScrollView(
      //   scrollDirection: Axis.horizontal,
      //   child:
    Container(
            decoration: BoxDecoration(
              color: (theme.darkMode) ? dashboardColorCardDark : dashboardColorCardGrey,
              borderRadius: BorderRadius.circular(10),
            ),
           // width: (windowWidth/2 < 600) ? 600 : windowWidth/2,
            height: windowHeight*0.4,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Scrollbar(
              controller: _controllerTree,
              isAlwaysShown: true,
              child: ListView(
                controller: _controllerTree,
                children: list2,
              ),
            )
    // )
    );
  }

  getListTree(List<Widget> list2, String parent, double align){
    List<CategoryData> _category = context.watch<MainModel>().category.category;

    for (var item in _category){
      if (item.parent == parent) {
        Widget _image = (item.serverPath.isNotEmpty) ? Image.network(item.serverPath, fit: BoxFit.contain)
            : Container();
        list2.add(Stack(
          children: [
            Container(
                key: item.dataKey2,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: align, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: (selectId == item.id) ? theme.mainColor.withAlpha(120) : (theme.darkMode) ? Colors.black : dashboardColorCardGreenGrey,
                  borderRadius: BorderRadius.circular(theme.radius),
                ),
                child: Row(children: [
                  Container(
                      width: 40,
                      height: 40,
                      child: _image),
                  SizedBox(width: 20,),
                  Expanded(child: Text(Provider.of<MainModel>(context,listen:false).getTextByLocale(item.name), style: theme.style14W400,)),
                ],)),
            Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.grey[400],
                    onTap: (){
                      Provider.of<MainModel>(context,listen:false).category.select(item);
                    },
                  )),
            ),
            Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerRight,
                  child: button2small(strings.get(62), (){widget.deleteDialog(item);}, color: dashboardErrorColor.withAlpha(150)), // "Delete",
                )
            )
          ],
        )
        );
        getListTree(list2, item.id, align+30);
      }
    }
  }
}
