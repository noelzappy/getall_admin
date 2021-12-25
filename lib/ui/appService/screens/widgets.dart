import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/ui/appService/screens/strings.dart';
import 'package:ondemand_admin/ui/appService/screens/theme.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/service.dart';
import 'package:provider/provider.dart';


getPriceText(PriceData item, List<Widget> list2, BuildContext context){
  if (item.discPrice == 0)
    list2.add(Column(
      children: [
        Text(getPriceString(item.price), style: theme.style20W800Green),
        Text((item.priceUnit == "fixed") ? strings.get(130) : strings.get(131), style: theme.style12W800), /// "fixed", - "hourly",
      ],));
  else{
    list2.add(Column(
      children: [
        Text(getPriceString(item.discPrice), style: theme.style20W800Red),
        Text((item.priceUnit == "fixed") ? strings.get(130) : strings.get(131), style: theme.style12W800), /// "fixed", - "hourly",
      ],
    ));
    list2.add(SizedBox(width: 5,));
    list2.add(Text(getPriceString(item.price), style: theme.style16W400U),);
  }
}

pricingTable(BuildContext context){
  return Container(
      padding: EdgeInsets.all(20),
      color: (darkMode) ? Colors.black : Colors.white,
      child: Column(
        children: [
          Text(strings.get(74), // "Pricing",
              style: theme.style16W800),
          Divider(color: (darkMode) ? Colors.white : Colors.black),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(child: Text(getTextByLocale(currentTestService.price[0].name,
                  Provider.of<MainModel>(context,listen:false).currentEmulatorLanguage),
                  style: theme.style14W400)),
              Text(getPriceString(currentTestService.price[0].getPrice()), style: theme.style16W800,)
            ],
          ),
          SizedBox(height: 5,),
          Divider(color: (darkMode) ? Colors.white : Colors.black),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(child: Text(strings.get(75), // "Quantity",
                style: theme.style14W400,)),
              Text(currentTestService.count.toString(), style: theme.style16W800,)
            ],
          ),
          SizedBox(height: 5,),
          Divider(color: (darkMode) ? Colors.white : Colors.black),
          SizedBox(height: 5,),

          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(child: Text(strings.get(167), /// "Coupon",
                style: theme.style14W400,)),
              Text(strings.get(168)) /// no
            ],
          ),
          Divider(color: (darkMode) ? Colors.white : Colors.black),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(child: Text(strings.get(76), // "Tax amount",
                  style: theme.style14W400)),
              Text("(${currentTestService.tax}%) "
                  "10", style: theme.style16W800,)
            ],
          ),
          SizedBox(height: 5,),
          Divider(color: (darkMode) ? Colors.white : Colors.black),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(child: Text(strings.get(77), // "Total",
                  style: theme.style14W400)),
              Text("20", style: theme.style16W800Orange,)
            ],
          ),
        ],
      )
  );
}