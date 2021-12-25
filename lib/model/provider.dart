import 'package:abg_utils/abg_utils.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../ui/strings.dart';
import 'model.dart';

class MainDataProvider with DiagnosticableTreeMixin {
  final MainModel parent;
  MainDataProvider({required this.parent});

  ProviderData current = ProviderData.createEmpty();
  List<ProviderData> providers = [];
  List<UserData> providersRequest = [];
  String ensureVisible = "";
  UserData? newProvider;
  List<ComboData> providersCombo = [];
  String providersComboValue = "";

  String getProviderName(String id, BuildContext context){
    for (var item in providers)
      if (item.id == id)
        return getTextByLocale(item.name, strings.locale);
    return "";
  }

  Future<String?> load(BuildContext context) async{
    _setCategory();
    if (providers.isNotEmpty)
      return null;
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("provider").get();
      providers = [];
      providersCombo = [];
      providersCombo.add(ComboData(strings.get(254), "1")); /// "All"
      providersComboValue = "1";
      for (var result in querySnapshot.docs) {
        var _data = result.data();
        dprint("Provider $_data");
        var t = ProviderData.fromJson(result.id, _data);
        providers.add(t);
        providersCombo.add(ComboData(getTextByLocale(t.name, strings.locale), result.id));
      }
      addStat("(admin) provider", providers.length);
    }catch(ex){
      return "MainDataProvider load " + ex.toString();
    }
    return null;
  }

  Function(List<gm.LatLng>)? _callbackChangeMap;

  getArea(Function(List<gm.LatLng>) callback){
    _callbackChangeMap = callback;
    List<gm.LatLng> _area = [];

    for (var item in current.route)
      _area.add(gm.LatLng(item.latitude, item.longitude));

    return callback(_area);
  }

  saveArea(List<gm.LatLng> _route){
    current.route = _route;
    // current.route = [];
    // for (var item in _route)
    //   current.route.add(mp.LatLng(item.latitude, item.longitude));
  }

  Future<String?> loadRequest() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").
          where("providerRequest", isEqualTo: true).get();
      providersRequest = [];
      addStat("(admin) provider Request", querySnapshot.docs.length);
      for (var result in querySnapshot.docs) {
        var _data = result.data();
        //print("Provider Request $_data");
        var t = UserData.fromJson(result.id, _data);
        providersRequest.add(t);
      }
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"provider_new_request_count": 0}, SetOptions(merge:true));
    }catch(ex){
      return "MainDataProvider loadRequest " + ex.toString();
    }
    return null;
  }

  Future<String?> deleteRequest(UserData val) async {
    try{
      await FirebaseFirestore.instance.collection("listusers").doc(val.id)
          .set({"providerRequest": false}, SetOptions(merge:true));
      providersRequest.remove(val);
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"provider_request_count": FieldValue.increment(-1)}, SetOptions(merge:true));
    }catch(ex){
      return "MainDataProvider deleteRequest " + ex.toString();
    }
    parent.notify();
    return null;
  }

  _categorySave(){
    current.category = [];
    for (var item in parent.category.category)
      if (item.select)
        current.category.add(item.id);
  }

  _setCategory(){
    for (var item in parent.category.category) {
      item.select = false;
      for (var item2 in current.category)
        if (item2 == item.id)
          item.select = true;
    }
  }

  Future<String?> create() async {
    // demo mode
    if (appSettings.demo)
      return strings.get(65); /// "This is Demo Mode. You can't modify this section",
    if (current.name.isEmpty)
      return strings.get(91); /// "Please Enter Name",
    try{
      _categorySave();
      var _data = current.toJson();
      var t = await FirebaseFirestore.instance.collection("provider").add(_data);
      current.id = t.id;
      providers.add(current);
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"provider_count": FieldValue.increment(1)}, SetOptions(merge:true));
      if (newProvider != null) {
        await FirebaseFirestore.instance.collection("listusers").doc(newProvider!.id)
            .set({"providerRequest": false}, SetOptions(merge: true));
        providersRequest.remove(newProvider);
        newProvider = null;
        await FirebaseFirestore.instance.collection("settings").doc("main")
            .set({"provider_request_count": FieldValue.increment(-1)}, SetOptions(merge:true));
      }
    }catch(ex){
      return "MainDataProvider create " + ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> save() async {
    if (current.name.isEmpty)
      return strings.get(91); /// "Please Enter Name",
    try{
      _categorySave();
      var _data = current.toJson();
      await FirebaseFirestore.instance.collection("provider").doc(current.id).set(_data, SetOptions(merge:true));
    }catch(ex){
      return "MainDataProvider save " + ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> delete(ProviderData val) async {
    try{
      await FirebaseFirestore.instance.collection("provider").doc(val.id).delete();
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"provider_count": FieldValue.increment(-1)}, SetOptions(merge:true));
      if (val.id == current.id)
        current = ProviderData.createEmpty();
      providers.remove(val);
    }catch(ex){
      return "MainDataProvider delete " + ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> deleteImage(ImageData item) async {
    try{
      await FirebaseStorage.instance.refFromURL(item.serverPath).delete();
      current.gallery.remove(item);
    } catch (ex) {
      return "MainDataProvider deleteImage " + ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> addImageToGallery(Uint8List _imageData) async {
    try{
      var f = Uuid().v4();
      var name = "provider/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      current.gallery.add(ImageData(localFile: name, serverPath: await s.ref.getDownloadURL()));
      parent.notify();
    } catch (ex) {
      return "MainDataProvider addImageToGallery " + ex.toString();
    }
    return null;
  }

  Future<String?> setUpperImageData(Uint8List _imageData) async {
    try{
      var f = Uuid().v4();
      var name = "provider/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      current.imageUpperServerPath = await s.ref.getDownloadURL();
      current.imageUpperLocalFile = name;
      parent.notify();
    } catch (ex) {
      return "MainDataProvider setUpperImageData " + ex.toString();
    }
    return null;
  }

  Future<String?> setLogoImageData(Uint8List _imageData) async {
    try{
      var f = Uuid().v4();
      var name = "provider/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      current.logoServerPath = await s.ref.getDownloadURL();
      current.logoLocalFile = name;
      parent.notify();
    } catch (ex) {
      return "MainDataProvider setLogoImageData " + ex.toString();
    }
    return null;
  }

  changeCategory(){
    parent.notify();
  }

  emptyCurrent(){
    current = ProviderData.createEmpty();
    _setCategory();
    parent.notify();
  }

  createNewProvider(UserData val){
    newProvider = val;
    current = ProviderData.createEmpty();
    current.login = val.email;
    current.phone = val.phone;
    current.desc = [StringData(code: parent.langEditDataComboValue, text: val.providerDesc)];
    current.address = val.providerAddress;
    current.route = val.providerWorkArea;
    current.name = [StringData(code: parent.langEditDataComboValue, text: val.providerName)];
    current.logoServerPath = val.providerLogoServerPath;
    current.logoLocalFile = val.providerLogoLocalFile;
    current.category = val.providerCategory;
  }

  select(ProviderData select){
    ensureVisible = select.id;
    current = select;
    _setCategory();
    parent.notify();
    if (_callbackChangeMap != null)
      getArea(_callbackChangeMap!);
  }

  setName(String val){
    for (var item in current.name)
      if (item.code == parent.langEditDataComboValue) {
        item.text = val;
        return parent.notify();
      }
    current.name.add(StringData(code: parent.langEditDataComboValue, text: val));
    parent.notify();
  }

  setEmail(String val){
    current.login = val;
  }

  setDesc(String val){
    for (var item in current.desc)
      if (item.code == parent.langEditDataComboValue) {
        item.text = val;
        return parent.notify();
      }
    current.desc.add(StringData(code: parent.langEditDataComboValue, text: val));
    parent.notify();
  }

  setDescTitle(String val){
    for (var item in current.descTitle)
      if (item.code == parent.langEditDataComboValue) {
        item.text = val;
        return parent.notify();
      }
    current.descTitle.add(StringData(code: parent.langEditDataComboValue, text: val));
    parent.notify();
  }

  setPhone(String val){
    current.phone = val;
    parent.notify();
  }

  setWWW(String val){
    current.www = val;
    parent.notify();
  }

  setInstagram(String val){
    current.instagram = val;
    parent.notify();
  }

  setTelegram(String val){
    current.telegram = val;
    parent.notify();
  }

  setAddress(String val){
    current.address = val;
    parent.notify();
  }

  setVisible(bool val){
    current.visible = val;
    parent.notify();
  }

  setTax(String val){
    current.tax = toDouble(val);
    parent.notify();
  }

  //
  // Open Close Time
  //
  String weekDataComboValue = "1";
  List<ComboData> weekDataCombo = [
    ComboData(strings.get(134), "0"), // "Monday",
    ComboData(strings.get(135), "1"), // "Tuesday",
    ComboData(strings.get(136), "2"), // "Wednesday",
    ComboData(strings.get(137), "3"), // "Thursday",
    ComboData(strings.get(138), "4"), // "Friday",
    ComboData(strings.get(139), "5"), // "Saturday",
    ComboData(strings.get(140), "6"), // "Sunday",
  ];

  _initWeekEnd(){
    if (current.workTime.length != 7){
      current.workTime = [
        WorkTimeData(id: 0),
        WorkTimeData(id: 1),
        WorkTimeData(id: 2),
        WorkTimeData(id: 3),
        WorkTimeData(id: 4),
        WorkTimeData(id: 5),
        WorkTimeData(id: 6),
      ];
    }
  }

  setWeekend(bool val){
    _initWeekEnd();
    for (var item in current.workTime)
      if (item.id.toString() == weekDataComboValue) {
        item.weekend = val;
        // print("setWeekend weekDataComboValue=$weekDataComboValue");
      }
    parent.notify();
  }

  bool getWeekend(){
    _initWeekEnd();
    for (var item in current.workTime)
      if (item.id.toString() == weekDataComboValue) {
        // print("getWeekend weekDataComboValue=$weekDataComboValue item.weekend=${item.weekend}");
        return item.weekend;
      }
    return false;
    // return weekend[int.parse(weekDataComboValue)];
  }

  String getOpenTime(){
    _initWeekEnd();
    var ret = "09:00";
    for (var item in current.workTime)
      if (item.id.toString() == weekDataComboValue)
        ret = item.openTime;
    DateTime _time = DateFormat('HH:mm').parse(ret);
    return DateFormat(parent.getTimeFormat()).format(_time);
  }

  String getCloseTime(){
    _initWeekEnd();
    var ret = "16:00";
    for (var item in current.workTime)
      if (item.id.toString() == weekDataComboValue)
        ret = item.closeTime;
    DateTime _time = DateFormat('HH:mm').parse(ret);
    return DateFormat(parent.getTimeFormat()).format(_time);
  }

  Future<void> selectOpenDate(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: 15),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: appSettings.timeFormat == "24h"), child: child!),    // 24h - 12h
    );
    if (picked != null){
      _initWeekEnd();
      for (var item in current.workTime)
        if (item.id.toString() == weekDataComboValue){
          DateTime _timeClose = DateFormat('HH:mm').parse(item.closeTime);
          var _open = DateTime(0,0,0, picked.hour, picked.minute);
          var _close = DateTime(0,0,0, _timeClose.hour, _timeClose.minute);
          if (_open.isAfter(_close))
            _open = _close;
          item.openTime = DateFormat('HH:mm').format(_open);
        }
      parent.notify();
    }
  }

  Future<void> selectCloseDate(BuildContext context) async {
    var ret = "16:00";
    for (var item in current.workTime)
      if (item.id.toString() == weekDataComboValue)
        ret = item.closeTime;
    DateTime _time = DateFormat('HH:mm').parse(ret);
    //
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: appSettings.timeFormat == "24h"), child: child!),    // 24h - 12h
    );
    if (picked != null){
      _initWeekEnd();
      for (var item in current.workTime)
        if (item.id.toString() == weekDataComboValue){
          DateTime _timeOpen = DateFormat('HH:mm').parse(item.openTime);
          var _open = DateTime(0,0,0, _timeOpen.hour, _timeOpen.minute);
          var _close = DateTime(0,0,0, picked.hour, picked.minute);
          if (_close.isBefore(_open))
            _close = _open;
          item.closeTime = DateFormat('HH:mm').format(_close);
        }
      parent.notify();
    }
  }

  List<EarningData> getEarningData(ProviderData item){
    List<EarningData> items = [];
    EarningData data = EarningData();
    bookings.sort((a, b) => b.time.compareTo(a.time));

    for (var booking in bookings)
      if (booking.finished && booking.providerId == item.id){
        data.count++;
        //
        EarningData item = EarningData();
        item.id = booking.id;
        //
        item.total = booking.getTotal();
        data.total += item.total;
        //
        item.admin = item.total*booking.taxAdmin/100;
        data.admin += item.admin;
        //
        item.provider = item.total - item.admin;
        data.provider += item.provider;
        //
        item.tax = item.total*booking.tax/100;
        data.tax += item.tax;
        // print("booking.id=${booking.id} booking.providerId =${booking.providerId} _total=$_total _toAdmin=$_toAdmin provider=${data.total - _toAdmin} data.total=${data.total} data.count=${data.count}");
        //
        items.add(item);
      }
    data.payout = data.provider;
    for (var item2 in payout)
      if (item2.providerId == item.id)
        data.payout -= item2.total;
    if (data.payout < 0)
      data.payout = 0;

    items.add(data);
    return items;
  }

  Future<String?> createPayout(ProviderData _provider, double total, String text) async {
    try{
      var _data = {
        "providerId": _provider.id,
        "providerName": _provider.name.map((i) => i.toJson()).toList(),
        "total": total,
        "comment": text,
        "time": FieldValue.serverTimestamp()
      };
      var ret = await FirebaseFirestore.instance.collection("payout").add(_data);
      _data["time"] = "";
      payout.add(PayoutData.fromJson(ret.id, _data));
    }catch(ex){
      return "MainDataProvider createPayout " + ex.toString();
    }
    parent.notify();
    return null;
  }

  List<PayoutData> payout = [];

  Future<String?> loadPayout(context) async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("payout").get();
      payout = [];
      for (var result in querySnapshot.docs) {
        var _data = result.data();
        // print("Payout $_data");
        var t = PayoutData.fromJson(result.id, _data);
        payout.add(t);
        payoutsSort("timeDesc", context);
      }
      addStat("(admin) payout", payout.length);
    }catch(ex){
      return "MainDataProvider loadPayout " + ex.toString();
    }
    return null;
  }

  payoutsSort(String sort, context){
    if (sort == "timeDesc")
      payout.sort((a, b) => a.compareToTimeDesc(b));
    if (sort == "timeAsc")
      payout.sort((a, b) => a.compareToTimeAsc(b));
    if (sort == "nameAsc")
      payout.sort((a, b) => a.compareToNameAsc(b, context));
    if (sort == "nameDesc")
      payout.sort((a, b) => a.compareToNameDesc(b, context));
    if (sort == "totalAsc")
      payout.sort((a, b) => a.compareToTotalAsc(b));
    if (sort == "totalDesc")
      payout.sort((a, b) => a.compareToTotalDesc(b));
  }

  copyEarning(){
    var text = "";
    for (var item in providers){
      EarningData _data = EarningData();
      var _items = getEarningData(item);
      if (_items.isNotEmpty)
        _data = _items.last;
      text = "$text${parent.getTextByLocale(item.name)}\t${_data.count}\t${getPriceString(_data.total)}"
          "\t${getPriceString(_data.admin)}\t${getPriceString(_data.provider)}"
          "\t${getPriceString(_data.tax)}\t${getPriceString(_data.payout)}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  copyEarningDetails(ProviderData _detailItem){
    List<EarningData> items = getEarningData(_detailItem);
    var text = "";
    for (var _data in items){
      text = "$text${_data.id}"
          "\t${getPriceString(_data.total)}\t${getPriceString(_data.admin)}"
          "\t${getPriceString(_data.provider)}"
          "\t${getPriceString(_data.tax)}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csvEarningDetails(ProviderData _detailItem){
    List<EarningData> items = getEarningData(_detailItem);
    List<List> t2 = [];
    t2.add([
      strings.get(114), // "Id",
      strings.get(177), // "Total",
      strings.get(268), // "Admin",
      strings.get(178), // "Provider",
      strings.get(130), // "Tax",
    ]);
    for (var _data in items){
      t2.add([_data.id, getPriceString(_data.total),
        getPriceString(_data.admin), getPriceString(_data.provider),
        getPriceString(_data.tax),
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  String csvEarning(){
    List<List> t2 = [];
    t2.add([
      strings.get(178), // "Provider",
      strings.get(264), // "Bookings",
      strings.get(177), // "Total",
      strings.get(268), // "Admin",
      strings.get(178), // "Provider",
      strings.get(130), // "Tax",
      strings.get(269), // "To payout",
    ]);
    for (var item in providers){
      EarningData _data = EarningData();
      var _items = getEarningData(item);
      if (_items.isNotEmpty)
        _data = _items.last;
      t2.add([parent.getTextByLocale(item.name), _data.count, getPriceString(_data.total),
        getPriceString(_data.admin), getPriceString(_data.provider),
        getPriceString(_data.tax), getPriceString(_data.payout)
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  copyPayouts(){
    var text = "";
    for (var item in payout){
      text = "$text${parent.getTextByLocale(item.providerName)}\t${parent.getDateTimeString(item.time)}"
          "\t${getPriceString(item.total)}\t${item.comment}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csvPayouts(){
    List<List> t2 = [];
    t2.add([
      strings.get(178), // "Provider",
      strings.get(273), // "Time",
      strings.get(177), // "Total",
      strings.get(180), // "Comment",
    ]);
    for (var item in payout){
      t2.add([parent.getTextByLocale(item.providerName), parent.getDateTimeString(item.time),
      getPriceString(item.total), item.comment
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  copy(){
    var text = "";
    for (var item in providers){
      text = "$text${item.id}\t${parent.getTextByLocale(item.name)}"
          "\t${item.phone}\t${item.www}\t${item.instagram}\t${item.telegram}"
          "\t${item.address}\t${item.tax}%"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csv(){
    List<List> t2 = [];
    t2.add([
      strings.get(114), // "Id",
      strings.get(54), // "Name",
      strings.get(124), // "Phone",
      strings.get(125), // "Web Page",
      strings.get(127), // "Instagram",
      strings.get(126), // "Telegram",
      strings.get(97), // "Address",
      strings.get(130), // "Tax",
    ]);
    for (var item in providers){
      t2.add([item.id, parent.getTextByLocale(item.name), item.phone,
        item.www, item.instagram, item.telegram, item.address, "${item.tax}%"
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  copyRequest(){
    var text = "";
    for (var item in providersRequest){
      text = "$text${item.name}\t${item.email}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csvRequest(){
    List<List> t2 = [];
    t2.add([
      strings.get(54), // "Name",
      strings.get(86), // "Email",
    ]);
    for (var item in providersRequest){
      t2.add([item.name, item.email,
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  String getProviderAddress(String id){
    String _address = "";
    for (var item in providers)
      if (item.id == id) {
        _address = item.address;
        break;
      }
    return _address;
  }

}

class PayoutData {
  String id;
  String providerId;
  List<StringData> providerName;
  double total;
  String comment;
  DateTime time;
  PayoutData({this.id = "", this.providerId = "", required this.providerName,
    this.total = 0, this.comment = "", required this.time
  });

  factory PayoutData.fromJson(String id, Map<String, dynamic> data){
    var _time = DateTime.now();
    if (data["time"] != null)
      if (data["time"] != "")
        _time = data["time"].toDate().toLocal();
    List<StringData> _provider = [];
    if (data['providerName'] != null)
      for (var element in List.from(data['providerName'])) {
        _provider.add(StringData.fromJson(element));
      }
    return PayoutData(
        id: id,
        providerId: (data["providerId"] != null) ? data["providerId"] : "",
        providerName: _provider,
        total: (data["total"] != null) ? toDouble(data["total"].toString()) : 0,
        comment: (data["comment"] != null) ? data["comment"] : "",
        time: _time
    );
  }

  int compareToTotalDesc(PayoutData b){
    return b.total.compareTo(total);
  }

  int compareToTotalAsc(PayoutData b){
    var t = b.total.compareTo(total);
    if (t == 1) return -1;
    if (t == -1) return 1;
    return 0;
  }

  int compareToNameDesc(PayoutData b, context){
    return getTextByLocale(b.providerName, context).compareTo(getTextByLocale(providerName, context));
  }

  int compareToNameAsc(PayoutData b, context){
    var t = getTextByLocale(b.providerName, context).compareTo(getTextByLocale(providerName, context));
    if (t == 1) return -1;
    if (t == -1) return 1;
    return 0;
  }

  int compareToTimeDesc(PayoutData b){
    return b.time.compareTo(time);
  }

  int compareToTimeAsc(PayoutData b){
    var t = b.time.compareTo(time);
    if (t == 1) return -1;
    if (t == -1) return 1;
    return 0;
  }
}

class EarningData {
  int count = 0;
  String id = "";
  double total = 0;
  double provider = 0;
  double admin = 0;
  double tax = 0;
  double payout = 0;
}

// class ProviderData {
//   String id;
//   List<StringData> name;
//   String phone;
//   String www;
//   String instagram;
//   String telegram;
//   List<StringData> desc;
//   List<StringData> descTitle;
//   String address;
//   //String avatar;
//   bool visible;
//   int unread = 0;
//   int all = 0;
//   String login;
//   double tax;
//   List<gm.LatLng> route;
//
//   String imageUpperServerPath = "";
//   String imageUpperLocalFile = "";
//   String logoServerPath = "";
//   String logoLocalFile = "";
//   List<ImageData> gallery = [];
//   //
//   List<WorkTimeData> workTime = [];
//   List<String> category = [];
//   // ignore: cancel_subscriptions
//   StreamSubscription<DocumentSnapshot>? listen;
//   //
//   bool select = false;
//   final dataKey = new GlobalKey();
//   String assetUpperImage;
//   String assetsLogo;
//   List<String> assetsGallery;
//   List<String> assetsCategory;
//   List<AddonData> addon;
//
//   ProviderData({this.id = "", this.name = const [], this.visible = true, this.address = "", this.desc = const [],
//     this.phone = "", this.www = "", this.instagram = "", this.telegram = "", this.descTitle = const [],
//     this.imageUpperServerPath = "", this.imageUpperLocalFile = "",
//     this.logoServerPath = "", this.logoLocalFile = "", this.gallery = const [], this.workTime = const [],
//     this.category = const [], //this.avatar = ""
//     this.assetUpperImage = "", this.assetsLogo = "", this.assetsGallery = const [], this.assetsCategory = const [],
//     this.login = "", this.tax = 10, required this.route, required this.addon
//   });
//
//   factory ProviderData.createEmpty(){
//     return ProviderData(descTitle: [StringData(code: "en", text: strings.get(73))], route: [], addon: []); // "Description",
//   }
//
//   Map<String, dynamic> toJson() => {
//       'name': name.map((i) => i.toJson()).toList(),
//       'phone': phone,
//       'www': www,
//       'instagram': instagram,
//       'telegram': telegram,
//       'desc': desc.map((i) => i.toJson()).toList(),
//       'descTitle': descTitle.map((i) => i.toJson()).toList(),
//       'address': address,
//       'visible': visible,
//       'imageUpperServerPath': imageUpperServerPath,
//       'imageUpperLocalFile': imageUpperLocalFile,
//       'logoServerPath': logoServerPath,
//       'logoLocalFile': logoLocalFile,
//       'gallery': gallery.map((i) => i.toJson()).toList(),
//       'workTime': workTime.map((i) => i.toJson()).toList(),
//       'category': category,
//       "login" : login,
//       "tax" : tax,
//       "route" : route.map((i){
//         return {'lat': i.latitude, 'lng': i.longitude};
//       }).toList(),
//       'addon': addon.map((i) => i.toJson()).toList(),
//   };
//
//   factory ProviderData.fromJson(String id, Map<String, dynamic> data){
//     List<String> _category = [];
//     if (data['category'] != null)
//       List.from(data['category']).forEach((element){
//         _category.add(element);
//       });
//     List<ImageData> _gallery = [];
//     if (data['gallery'] != null)
//       List.from(data['gallery']).forEach((element){
//         _gallery.add(ImageData(serverPath: element["serverPath"], localFile: element["localFile"]));
//       });
//     //
//     List<WorkTimeData> _workTime = [];
//     if (data['workTime'] != null)
//       List.from(data['workTime']).forEach((element){
//         _workTime.add(WorkTimeData.fromJson(element));
//       });
//     //
//     List<StringData> _name = [];
//     if (data['name'] != null)
//       List.from(data['name']).forEach((element){
//         _name.add(StringData.fromJson(element));
//       });
//     List<StringData> _desc = [];
//     if (data['desc'] != null)
//       List.from(data['desc']).forEach((element){
//         _desc.add(StringData.fromJson(element));
//       });
//     List<StringData> _descTitle = [];
//     if (data['descTitle'] != null)
//       List.from(data['descTitle']).forEach((element){
//         _descTitle.add(StringData.fromJson(element));
//       });
//     List<AddonData> _addon = [];
//     if (data['addon'] != null)
//       List.from(data['addon']).forEach((element){
//         _addon.add(AddonData.fromJson(element));
//       });
//     List<gm.LatLng> _route = [];
//     if (data["route"] != null)
//       List.from(data['route']).forEach((element){
//         if (element['lat'] != null && element['lng'] != null)
//         _route.add(gm.LatLng(
//             element['lat'], element['lng']
//         ));
//       });
//
//     return ProviderData(
//       id: id,
//       name: _name,
//       phone: (data["phone"] != null) ? data["phone"] : "",
//       www: (data["www"] != null) ? data["www"] : "",
//       instagram: (data["instagram"] != null) ? data["instagram"] : "",
//       telegram: (data["telegram"] != null) ? data["telegram"] : "",
//       desc: _desc,
//       descTitle: _descTitle,
//       address: (data["address"] != null) ? data["address"] : "",
//       visible: (data["visible"] != null) ? data["visible"] : true,
//       imageUpperServerPath: (data["imageUpperServerPath"] != null) ? data["imageUpperServerPath"] : "",
//       imageUpperLocalFile: (data["imageUpperLocalFile"] != null) ? data["imageUpperLocalFile"] : "",
//       logoServerPath: (data["logoServerPath"] != null) ? data["logoServerPath"] : "",
//       logoLocalFile: (data["logoLocalFile"] != null) ? data["logoLocalFile"] : "",
//       gallery: _gallery,
//       workTime: _workTime,
//       category: _category,
//       login: (data["login"] != null) ? data["login"] : "",
//       tax: (data["tax"] != null) ? data["tax"] : 10,
//       route : _route,
//       //avatar: (data["avatar"] != null) ? data["avatar"] : "",
//       addon: _addon,
//     );
//   }
// }
//
// class WorkTimeData{
//   int id = 0;
//   bool weekend = false;
//   String openTime = "";
//   String closeTime = "";
//
//   WorkTimeData({this.id = 0, this.openTime = "09:00", this.closeTime = "16:00", this.weekend = false});
//
//   Map<String, dynamic> toJson() => {
//     'index': id,
//     'openTime': openTime,
//     'closeTime': closeTime,
//     'weekend': weekend,
//   };
//
//   factory WorkTimeData.fromJson(Map<String, dynamic> data){
//     return WorkTimeData(
//       id: (data["index"] != null) ? data["index"] : 0,
//       openTime: (data["openTime"] != null) ? data["openTime"] : "9:00",
//       closeTime: (data["closeTime"] != null) ? data["closeTime"] : "16:00",
//       weekend: (data["weekend"] != null) ? data["weekend"] : false,
//     );
//   }
//
//   factory WorkTimeData.createEmpty(){
//     return WorkTimeData();
//   }
// }
//
