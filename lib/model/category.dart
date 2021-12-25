import 'package:abg_utils/abg_utils.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../ui/strings.dart';
import 'model.dart';

class MainDataCategory with DiagnosticableTreeMixin {

  final MainModel parent;

  MainDataCategory({required this.parent});

  CategoryData current = CategoryData.createEmpty();
  List<CategoryData> category = [];
  List<ComboData> parentsData = [];
  String ensureVisible = "";

  String getCategoryName(String id, BuildContext context){
    for (var item in category)
      if (item.id == id)
        return getTextByLocale(item.name, strings.locale);
    return "";
  }

  int compareToCategoryName(ProductData a, ProductData b, BuildContext context){
    if (a.category.isEmpty && b.category.isEmpty)
      return 0;
    return parent.category.getCategoryName(a.category[0], context)
        .compareTo(parent.category.getCategoryName(b.category[0], context));
  }

  int compareToProviderName(ProductData a, ProductData b, BuildContext context){
    if (a.providers.isEmpty && b.providers.isEmpty)
      return 0;
    return parent.provider.getProviderName(a.providers[0], context)
        .compareTo(parent.provider.getProviderName(b.providers[0], context));
  }

  setList(List<CategoryData> _data){
    category = _data;
    _parentListMake();
    parent.notify();
  }

  Future<String?> load() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("category").get();
      category = [];
      for (var result in querySnapshot.docs) {
        var _data = result.data();
        // print("Category $_data");
        var t = CategoryData.fromJson(result.id, _data);
        category.add(t);
      }
      addStat("(admin) category", category.length);
      _parentListMake();
    }catch(ex){
      return ex.toString();
    }
    return null;
  }

  Future<String?> create() async {
    try{
      var _data = current.toJson();
      var t = await FirebaseFirestore.instance.collection("category").add(_data);
      current.id = t.id;
      category.add(current);
      _parentListMake();
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"category_count": FieldValue.increment(1)}, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    parent.notify();
    return null;
  }

  Future<String?> save() async {
    try{
      var _data = current.toJson();
      await FirebaseFirestore.instance.collection("category").doc(current.id).set(_data, SetOptions(merge:true));
      _parentListMake();
    }catch(ex){
      return ex.toString();
    }
    parent.notify();
    return null;
  }

  emptyCurrent(){
    current = CategoryData.createEmpty();
    parent.notify();
  }

  Future<String?> delete(CategoryData val) async {
    try{
      await FirebaseFirestore.instance.collection("category").doc(val.id).delete();
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"category_count": FieldValue.increment(-1)}, SetOptions(merge:true));
      if (val.id == current.id)
        current = CategoryData.createEmpty();
      category.remove(val);
    }catch(ex){
      return ex.toString();
    }
    parent.notify();
    return null;
  }

  select(CategoryData _selectInEmulator){
    ensureVisible = _selectInEmulator.id;
    current = _selectInEmulator;
    _parentListMake();
    parent.notify();
  }

  setParent(String _parent){
    current.parent = _parent;
    parent.notify();
  }

  _parentListMake(){
    // parents category
    parentsData = [];
    parentsData.add(ComboData(strings.get(74), "")); /// Select parent category
    for (var item in category)
      if (item.id != current.id) {
        var found = false;
        for (var item2 in category) {
          if (item2.parent == current.id)
            found = true;
        }
        if (!found)
          parentsData.add(ComboData(parent.getTextByLocale(item.name), item.id));
      }
    //
  }

  setImageData(Uint8List _imageData) async {
    try{
      var f = Uuid().v4();
      var name = "category/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putData(_imageData);
      current.serverPath = await s.ref.getDownloadURL();
      current.localFile = name;
      parent.notify();
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  setColor(Color _color){
    current.color = _color;
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

  setVisibleCategoryDetails(bool val){
    current.visibleCategoryDetails = val;
    parent.notify();
  }

  copy(){
    var text = "";
    for (var item in category){
      text = "$text${item.id}\t${parent.getTextByLocale(item.name)}"
          "\t${parent.getTextByLocale(item.desc)}\t${item.parent}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csv(){
    List<List> t2 = [];
    t2.add([
      strings.get(114), // "Id",
      strings.get(54), // "Name",
      strings.get(73), // "Description",
      strings.get(285), // Parent Id
    ]);
    for (var item in category){
      t2.add([item.id, parent.getTextByLocale(item.name),
        parent.getTextByLocale(item.desc), item.parent
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }

  List<String> getServiceCategories(List<String> val, BuildContext context){
    List<String> ret = [];
    for (var item in val) {
      for (var item2 in category)
        if (item == item2.id) {
          ret.add(getTextByLocale(item2.name, strings.locale));
          break;
        }
    }
    return ret;
  }
}

