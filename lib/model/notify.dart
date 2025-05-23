import 'package:abg_utils/abg_utils.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../ui/strings.dart';
import 'model.dart';

class MainDataNotify with DiagnosticableTreeMixin {

  final MainModel parent;

  MainDataNotify({required this.parent});

  List<UserData> users = [];
  String userSelectedWithProviders = "-1";
  List<ComboData> userDataWithProviders = [];
  String userSelected = "-1";
  List<ComboData> userData = [];

  Future<String?> loadUsers() async {
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").get();
      users = [];
      userDataWithProviders = [];
      userDataWithProviders.add(ComboData(strings.get(14), "-1", selected: true));  /// "All users"
      userDataWithProviders.add(ComboData("", "", divider: true));
      userData = [];
      userData.add(ComboData(strings.get(254), "-1"));  // "All"
      addStat("(admin) users", querySnapshot.docs.length);
      for (var result in querySnapshot.docs) {
        var data = result.data();
        // print("user: $data");
        var _user = UserData.fromJson(result.id, data);
        users.add(_user);
        if (_user.role.isEmpty) {
          userDataWithProviders.add(ComboData(_user.name, result.id, email: _user.email));
          if (!_user.providerApp)
            userData.add(ComboData(_user.name, result.id));
        }
      }
    }catch(ex){
      return "model loadUsers " + ex.toString();
    }
    return null;
  }

  // Future<String?> sendMessage(String _body, String _title, String _to, String _userUid) async {
  //
  //   var pathFCM = 'https://fcm.googleapis.com/fcm/send';
  //
  //   String _key = appSettings.cloudKey;
  //   Map<String, String> requestHeaders = {
  //     'Content-type': 'application/json',
  //     'Accept': "application/json",
  //     'Authorization': "key=$_key",
  //   };
  //
  //   var body = json.encoder.convert({
  //     'notification': {
  //       'body': "$_body", 'title': "$_title", 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'sound': 'default'
  //     },
  //     'priority': 'high',
  //     'sound': 'default',
  //     'data': {
  //       'body': "$_body", 'title': "$_title", 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'sound': 'default'
  //     },
  //     'to': "$_to",
  //   });
  //
  //   print('body: $body');
  //   var response = await http.post(Uri.parse(pathFCM), headers: requestHeaders, body: body).timeout(const Duration(seconds: 30));
  //
  //   print('Response status: ${response.statusCode}');
  //   print('Response body: ${response.body}');
  //
  //   // if (response.statusCode == 200){
  //   //   var jsonResult = json.decode(response.body);
  //   //   if (jsonResult["success"] == 1){
  //       // write to db
  //       try {
  //         await FirebaseFirestore.instance.collection("messages").add(
  //             {
  //               "time": FieldValue.serverTimestamp(),
  //               "title": "$_title",
  //               "body": "$_body",
  //               "user": _userUid,
  //               "read": false
  //             });
  //       }catch(ex){
  //         return ex.toString();
  //       }
  //       return null;
  //     // }
  //     // return "${jsonResult["results"]}";
  //   // }
  //   // return ("response.statusCode=${response.statusCode}");
  // }

  copyCustomers(){
    var text = "";
    for (var item in users){
      if (item.providerApp)
        continue;
      if (item.role.isNotEmpty)
        continue;
      text = "$text${item.id}\t${item.name}"
          "\t${item.email}\t${item.visible}"
          "\n";
    }
    Clipboard.setData(ClipboardData(text: text));
  }

  String csvCustomers(){
    List<List> t2 = [];
    t2.add([
      strings.get(114), /// "Id",
      strings.get(54), /// "Name",
      strings.get(86), /// "Email",
      strings.get(70), /// "Visible",
    ]);
    for (var item in users){
      if (item.providerApp)
        continue;
      if (item.role.isNotEmpty)
        continue;
      t2.add([item.id, item.name,
        item.email, item.visible.toString()
      ]);
    }
    return ListToCsvConverter().convert(t2);
  }
}
