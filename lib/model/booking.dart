import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../ui/strings.dart';
import 'model.dart';
import 'package:csv/csv.dart';

class MainDataBooking with DiagnosticableTreeMixin {
  final MainModel parent;

  MainDataBooking({required this.parent});

  OrderData current = OrderData.createEmpty();

  double _countM1 = 0;
  double _countM2 = 0;
  double _countM3 = 0;
  double _countM4 = 0;
  double _countM5 = 0;
  double _countM6 = 0;

  List<TotalData> chartCount = [];

  double _totalM1 = 0;
  double _totalM2 = 0;
  double _totalM3 = 0;
  double _totalM4 = 0;
  double _totalM5 = 0;
  double _totalM6 = 0;

  List<EarningData> data2 = [];

  getStat(){
    _countM1 = 0;
    _countM2 = 0;
    _countM3 = 0;
    _countM4 = 0;
    _countM5 = 0;
    _countM6 = 0;
    _totalM1 = 0;
    _totalM2 = 0;
    _totalM3 = 0;
    _totalM4 = 0;
    _totalM5 = 0;
    _totalM6 = 0;
    // print("main model booking - getStat <---------------------");
    for (var item in bookings){
      // print("item.finished=${item.finished} item.time=${item.time}");
      // if (!item.finished)
      //   continue;
      var _day = DateTime.now();
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM1++;
        _totalM1+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM1=$_countM1 id=${item.id}");
      }
      _day = _day.subtract(Duration(days: _day.day+1));
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM2++;
        _totalM2+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM2=$_countM2");
      }
      _day = _day.subtract(Duration(days: _day.day+1));
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM3++;
        _totalM3+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM3=$_countM3");
      }
      _day = _day.subtract(Duration(days: _day.day+1));
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM4++;
        _totalM4+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM4=$_countM4");
      }
      _day = _day.subtract(Duration(days: _day.day+1));
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM5++;
        _totalM5+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM5=$_countM5");
      }
      _day = _day.subtract(Duration(days: _day.day+1));
      if (_day.month == item.time.month && _day.year == item.time.year) {
        _countM6++;
        _totalM6+=item.total;
        // print("_day=$_day && item.time=${item.time} _countM6=$_countM6");
      }
    }
    // print("<---------------------");
    var _day = DateTime.now();
    initializeDateFormatting();
    chartCount = [
      TotalData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 5, 1)), _countM6, Colors.red),
      TotalData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 4, 1)), _countM5, Colors.red),
      TotalData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 3, 1)), _countM4, Colors.red),
      TotalData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 2, 1)), _countM3, Colors.red),
      TotalData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 1, 1)), _countM2, Colors.red),
      TotalData(DateFormat.MMM(strings.locale).format(_day), _countM1, Colors.red),
    ];

    data2 = [
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 5, 1)), _totalM6),
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 4, 1)), _totalM5),
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 3, 1)), _totalM4),
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 2, 1)), _totalM3),
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month - 1, 1)), _totalM2),
      EarningData(DateFormat.MMM(strings.locale).format(DateTime(_day.year, _day.month, 1)), _totalM1),
    ];
  }

  clearSelect(){
    current = OrderData.createEmpty();
    parent.notify();
  }

  select(OrderData item){
    current = item;
    parent.notify();
  }

  copy(){
    var text = "";
    for (var item in bookings){
      var statusName = "";
      for (var status in appSettings.statuses)
        if (item.status == status.id)
          statusName = parent.getTextByLocale(status.name);
      var price = item.discPrice != 0 ? item.discPrice : item.price;
      text = "$text${item.id}\t$statusName\t${item.customer}\t${parent.getTextByLocale(item.provider)}"
          "\t${parent.getTextByLocale(item.service)}\t${parent.getTextByLocale(item.priceName)}\t$price"
          "\t${item.priceUnit}\t${item.count}\t${item.tax}\t${item.total}\t${item.paymentMethod}\t${item.comment}"
          "\t${item.address}\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csv(){
    List<List> t2 = [];
    t2.add([strings.get(114), // "Id",
      strings.get(182), // "Status",
      strings.get(281), // "Customer",
      strings.get(178), // "Provider",
      strings.get(282), // "Service",
      strings.get(144), // "Price",
      strings.get(151), // "Price Unit",
      strings.get(283), // "Count"
      strings.get(130), // "Tax",
      strings.get(177), // "Total",
      strings.get(284), // "Payment Method"
      strings.get(180), // "Comment",
      strings.get(97), // "Address",
      ]);
    for (var item in bookings){
      var statusName = "";
      for (var status in appSettings.statuses)
        if (item.status == status.id)
          statusName = parent.getTextByLocale(status.name);
      var price = item.discPrice != 0 ? item.discPrice : item.price;
      t2.add([item.id, statusName, item.customer, parent.getTextByLocale(item.provider),
        parent.getTextByLocale(item.service) + " " + parent.getTextByLocale(item.priceName), price,
        item.priceUnit, item.count, item.tax, item.total,  item.paymentMethod, item.comment, item.address
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  setStatus(OrderData item){
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return;
    item.ver2 = true;
    item.history.add(StatusHistory(
        statusId: item.status,
        time: DateTime.now().toUtc(),
        byAdmin: true,
        activateUserId : user.uid
    ));

    String statusName = "";
    for (var st in appSettings.statuses)
      if (st.id == item.status)
        statusName = getTextByLocale(st.name, strings.locale);

    if (item.status == parent.completeStatus)
      item.finished = true;
    else
      item.finished = false;

    sendMessage(strings.get(416),  /// "Booking status was changed",
        "${strings.get(415)} $statusName\n" /// "Now status:",
            "${strings.get(114)}: ${item.id}",  /// "Id",
        item.customerId, true, appSettings.cloudKey);
  }

}

class TotalData {
  TotalData(this.year, this.sales, this.color);
  final String year;
  final double sales;
  final Color color;
}


class EarningData {
  EarningData(this.year, this.sales);

  final String year;
  final double sales;
}



