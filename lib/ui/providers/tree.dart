import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:provider/provider.dart';
import '../theme.dart';

class TreeInProvider extends StatefulWidget {

  const TreeInProvider({Key? key}) : super(key: key);
  @override
  _TreeInProviderState createState() => _TreeInProviderState();
}

class _TreeInProviderState extends State<TreeInProvider> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final ScrollController _controllerTree = ScrollController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

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

    List<Widget> list2 = [];
    getListTree(list2, "", 30,);

    return treeWindow(list2);
  }

  String selectId = "";

  treeWindow(List<Widget> list2){
    return Container(
      decoration: BoxDecoration(
        color: (theme.darkMode) ? dashboardColorCardDark : dashboardColorCardGrey,
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }

  getListTree(List<Widget> list2, String parent, double align){
    List<CategoryData> _category = context.watch<MainModel>().category.category;

    for (var item in _category){
      if (item.parent == parent) {
        Widget _image = (item.serverPath.isNotEmpty) ? Image.network(item.serverPath, fit: BoxFit.contain) : Container();
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
                  Expanded(child: Text(_mainModel.getTextByLocale(item.name), style: theme.style14W400,)),
                ],)),
            Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.grey[400],
                    onTap: (){
                      //Provider.of<ProviderModel>(context,listen:false).setSelectedId(item);
                    },
                  )),
            ),
            Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(left: 40, right: 40),
                  alignment: Alignment.centerRight,
                 child: checkBox0(theme.mainColor, item.select, (val) {
                   item.select = val!;
                   //Provider.of<MainDataModel>(context,listen:false).provider.changeCategory();
                   setState(() {});
                 })
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
