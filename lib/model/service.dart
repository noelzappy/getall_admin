import 'package:abg_utils/abg_utils.dart';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../ui/strings.dart';
import 'model.dart';

class MainDataService {

  final MainModel parent;

  MainDataService({required this.parent});

  ProductData current = ProductData.createEmpty();
  List<ProductData> services = [];
  String ensureVisible = "";

  //
  // CATEGORY
  //
  changeCategory(){
    current.category = [];
    for (var item in parent.category.category)
      if (item.select)
        current.category.add(item.id);
  }

  //
  // PROVIDERS
  //
  changeProvider(){
    current.providers = [];
    for (var item in parent.provider.providers)
      if (item.select)
        current.providers.add(item.id);
  }

  String serviceSelected = "-1";
  List<ComboData> serviceData = [];

  Future<String?> load(BuildContext context) async{
    serviceData = [];
    serviceData.add(ComboData(strings.get(254), "-1"));  // "All"
    _setCategoryAndProvider();
    if (services.isNotEmpty)
      return null;
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("service").get();
      for (var result in querySnapshot.docs) {
        var _data = result.data();
        // print("Service $_data");
        var t = ProductData.fromJson(result.id, _data);
        services.add(t);
        serviceData.add(ComboData(getTextByLocale(t.name, strings.locale), result.id));
      }
      addStat("(admin) services", services.length);
    }catch(ex){
      return "MainDataService load " + ex.toString();
    }
    return null;
  }

  _setCategoryAndProvider(){
    for (var item in parent.category.category) {
      item.select = false;
      for (var item2 in current.category)
        if (item2 == item.id)
          item.select = true;
    }
    for (var item in parent.provider.providers) {
      item.select = false;
      for (var item2 in current.providers)
        if (item2 == item.id)
          item.select = true;
    }
  }

  //
  // PRICE
  //
  PriceData getPrice(){
    PriceData currentPrice = PriceData.createEmpty();
    double _price = double.maxFinite;
    for (var item in current.price) {
      if (item.discPrice != 0){
        if (item.discPrice < _price) {
          _price = item.discPrice;
          currentPrice = item;
        }
      }else
      if (item.price < _price) {
        _price = item.price;
        currentPrice = item;
      }
    }
    if (_price == double.maxFinite)
      _price = 0;
    return currentPrice;
  }

  List<ComboData> priceUnitCombo = [
    ComboData(strings.get(149), "hourly"),
    ComboData(strings.get(150), "fixed"),
  ];
  String priceUnitComboValue = "hourly";

  setPriceUnitCombo(String val, int level){
    if (level < current.price.length)
      current.price[level].priceUnit = val;
    else
      current.price.add(PriceData([], 0, 0, val, ImageData()));
    parent.notify();
  }

  getPriceUnitCombo(int level){
    if (level < current.price.length)
      return current.price[level].priceUnit;
    return "hourly";
  }

  setPrice(String val, int level){
    double _price = double.parse(val);
    if (level < current.price.length)
      current.price[level].price = _price;
    else
      current.price.add(PriceData([], _price, 0, "hourly", ImageData()));
    parent.notify();
  }

  setDiscPrice(String val, int level){
    double _price = (val.isEmpty) ? 0 : double.parse(val);
    if (level < current.price.length)
      current.price[level].discPrice = _price;
    else
      current.price.add(PriceData([], 0, _price, "hourly", ImageData()));
    parent.notify();
  }

  setNamePrice(String val, int level){
    if (level < current.price.length) {
      for (var item in current.price[level].name)
        if (item.code == parent.langEditDataComboValue) {
          item.text = val;
          return parent.notify();
        }
      current.price[level].name.add(StringData(code: parent.langEditDataComboValue, text: val));
    }else
      current.price.add(PriceData([StringData(code: parent.langEditDataComboValue, text: val)], 0, 0, "hourly", ImageData()));
    parent.notify();
  }

  Future<String?> setPriceImageData(Uint8List _imageData, int level) async{
    try{
      var f = Uuid().v4();
      var name = "service/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      var _img = ImageData(localFile: name, serverPath: await s.ref.getDownloadURL());
      if (level < current.price.length)
        current.price[level].image = _img;
      else
        current.price.add(PriceData([], 0, 0, "hourly", _img));
      parent.notify();
    } catch (ex) {
      return "MainDataService setPriceImageData " + ex.toString();
    }
    return null;
  }

  //
  // END PRICE
  //

  Future<String?> deleteImage(ImageData item) async {
    try{
      await FirebaseStorage.instance.refFromURL(item.serverPath).delete();
      current.gallery.remove(item);
    } catch (ex) {
      return "MainDataService deleteImage " + ex.toString();
    }
    parent.notify();
    return null;
  }

  ImageData getTitleImage(){
    if (current.gallery.isNotEmpty)
      return current.gallery[0];
    return ImageData();
  }

  Future<String?> addImageToGallery(Uint8List _imageData) async {
    try{
      var f = Uuid().v4();
      var name = "service/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      current.gallery.add(ImageData(localFile: name, serverPath: await s.ref.getDownloadURL()));
      parent.notify();
    } catch (ex) {
      return "MainDataService addImageToGallery " + ex.toString();
    }
    return null;
  }

  _checkProvider() {
    for (var item in parent.provider.providers)
      if (item.select)
        return true;
    return false;
  }

  Future<String?> create() async{
    if (current.name.isEmpty)
      return strings.get(91); /// "Please Enter Name",
    if (current.price.isEmpty)
      return strings.get(342); /// "Please enter price",
    if (!_checkProvider())
      return strings.get(221); /// Please select provider
    try{
      var _data = current.toJson();
      var t = await FirebaseFirestore.instance.collection("service").add(_data);
      current.id = t.id;
      services.add(current);
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"service_count": FieldValue.increment(1)}, SetOptions(merge:true));
    }catch(ex){
      return "MainDataService create " + ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> save() async {
    if (current.name.isEmpty)
      return strings.get(91); /// "Please Enter Name",
    if (current.price.isEmpty)
      return strings.get(342); /// "Please enter price",
    if (!_checkProvider())
      return strings.get(221); /// Please select provider
    if (current.category.isEmpty)
      return strings.get(343); /// "Please enter category",
    try{
      var _data = current.toJson();
      // print("save service: $_data");
      await FirebaseFirestore.instance.collection("service").doc(current.id).set(_data, SetOptions(merge:true));
    }catch(ex){
      return "MainDataService save " + ex.toString();
    }
    parent.notify();
    return null;
  }

  emptyCurrent(){
    current = ProductData.createEmpty();
    _setCategoryAndProvider();
    parent.notify();
  }

  setList(List<ProductData> _data){
    services = _data;
    //  notifyListeners();
  }

  select(ProductData select){
    ensureVisible = select.id;
    current = select;
    _setCategoryAndProvider();
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

  setTax(String val){
    current.tax = toDouble(val);
    parent.notify();
  }

  setTaxAdmin(String val){
    current.taxAdmin = toDouble(val);
    parent.notify();
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

  setDesc(String val){
    for (var item in current.desc)
      if (item.code == parent.langEditDataComboValue) {
        item.text = val;
        return parent.notify();
      }
    current.desc.add(StringData(code: parent.langEditDataComboValue, text: val));
    parent.notify();
  }

  setVisible(bool val){
    current.visible = val;
    parent.notify();
  }

  copy(){
    var text = "";
    for (var item in services){
      text = "$text${item.id}\t${parent.getTextByLocale(item.name)}"
          "\t${parent.getTextByLocale(item.desc)}"
          "\t${getPriceString(item.tax)}\t${getPriceString(item.taxAdmin)}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csv(){
    List<List> t2 = [];
    t2.add([
      strings.get(114), /// "Id",
      strings.get(54), /// "Name",
      strings.get(73), /// "Description",
      strings.get(130), /// "Tax",
      strings.get(266), /// "Tax for administration",
    ]);
    for (var item in services){
      t2.add([item.id, parent.getTextByLocale(item.name),
      parent.getTextByLocale(item.desc), getPriceString(item.tax),
      getPriceString(item.taxAdmin)
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  String getServiceMinPrice(ProductData item){
    double _price = double.maxFinite;
    for (var item in item.price) {
      if (item.discPrice != 0){
        if (item.discPrice < _price) {
          _price = item.discPrice;
        }
      }else
      if (item.price < _price)
        _price = item.price;
    }
    if (_price == double.maxFinite)
      _price = 0;
    return getPriceString(_price);
  }

  getPriceString(double price){
    if (appSettings.rightSymbol) {
      // dprint("getPriceString $price ${price.toStringAsFixed(2)}");
      // var t = price.toStringAsFixed(2);
      return "${appSettings.symbol}${price.toStringAsFixed(appSettings.digitsAfterComma)}";
    }
    return "${price.toStringAsFixed(appSettings.digitsAfterComma)}${appSettings.symbol}";
  }

  Future<String?> saveInMainScreenServices() async{
    appSettings.inMainScreenServices = [];
    for (var item in services)
      if (item.select)
        appSettings.inMainScreenServices.add(item.id);
    //
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"inMainScreenServices": appSettings.inMainScreenServices}, SetOptions(merge:true));
    }catch(ex){
      return "MainDataService saveInMainScreenServices " + ex.toString();
    }
    parent.notify();
    return null;
  }

  //
  // Addons
  //
  AddonData? editAddon;

  Future<String?> addAddon(String name, double price) async {
    if (name.isEmpty)
      return strings.get(91); /// "Please Enter Name",
    if (price == 0)
      return strings.get(342); /// "Please enter price",
    late AddonData _addon;
    if (editAddon == null){
      _addon = AddonData(Uuid().v4(), [StringData(code: parent.langEditDataComboValue, text: name)], price);
      current.addon.add(_addon);
    }else {
      editAddon!.price = price;
      var _found = false;
      for (var item in editAddon!.name)
        if (item.code == parent.langEditDataComboValue) {
          item.text = name;
          _found = true;
        }
      if (!_found)
        editAddon!.name.add(StringData(code: parent.langEditDataComboValue, text: name));
      _addon = editAddon!;
    }

    if (current.providers.isNotEmpty){
      for (var item in parent.provider.providers)
        if (item.id == current.providers[0]){
          if (editAddon == null)
            item.addon.add(_addon);
          else{
            for (var _add in item.addon)
              if (_add.id == _addon.id) {
                _add.price = _addon.price;
                _add.name = _addon.name;
              }
          }
          try{
            var _data = item.toJson();
            await FirebaseFirestore.instance.collection("provider").doc(item.id).set(_data, SetOptions(merge:true));
          }catch(ex){
            return "MainDataService addAddon " + ex.toString();
          }
        }
    }
    editAddon = null;
    return null;
  }

  selectAddon(AddonData item, bool _select){
    if (_select){
      current.addon.add(item);
    }else{
      for (var addon in current.addon)
        if (addon.id == item.id) {
          current.addon.remove(item);
          break;
        }
    }
  }

  Future<String?> deleteAddon(String id) async {
    for (var service in parent.service.services)
      for (var item in service.addon)
        if (item.id == id) {
          service.addon.remove(item);
          try{
            var _data = service.toJson();
            await FirebaseFirestore.instance.collection("service").doc(service.id).set(_data, SetOptions(merge:true));
          }catch(ex){
            return "MainDataService deleteAddon " + ex.toString();
          }
          break;
        }
    for (var item in parent.provider.providers)
      if (item.id == current.providers[0]){
        for (var _provAddon in item.addon)
          if (_provAddon.id == id){
            item.addon.remove(_provAddon);
            break;
          }
        try{
          var _data = item.toJson();
          await FirebaseFirestore.instance.collection("provider").doc(item.id).set(_data, SetOptions(merge:true));
        }catch(ex){
          return "MainDataService deleteAddon " + ex.toString();
        }
      }
    return null;
  }

  List<AddonData>? getProviderAddons(){
    if (current.providers.isNotEmpty)
      for (var item in parent.provider.providers)
        if (item.id == current.providers[0])
          return item.addon;
    return null;
  }

  //
  // End Addons
  //

}

ProductData currentTestService = ProductData("1",
  [StringData(code: "en", text: "Carpet shampooing")],
  tax: 10,
  descTitle: [StringData(code: "en", text: "Description")],
  desc: [StringData(code: "en", text: "asta la vista ... ")],
  visible: true,
  price: [PriceData([StringData(code: "en", text: "Carpet shampooing Hi")], 20, 10, "fixed", ImageData())],
  gallery: [],
  duration: Duration(minutes: 20),
  category: [],
  providers: [],
  rating1: 0,
  rating2: 0,
  rating3: 4,
  rating4: 3,
  rating5: 3,
  count: 2,
  rating: 4,
  addon: [],
  timeModify: DateTime.now(),
);

