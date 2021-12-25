// import 'dart:async';
// import 'package:abg_utils/abg_utils.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import '../ui/strings.dart';
// import 'model.dart';
//
// class MainDataChat with DiagnosticableTreeMixin {
//
//   final MainModel parent;
//
//   MainDataChat({required this.parent});
//
//   List<UserData> customersChat = [];
//
//   //
//   // Future<String?> getChatMessages(Function() _redraw, BuildContext context) async {
//   //   var _unread = 0;
//   //   try{
//   //     _createChatUsersList(context);
//   //     var user = FirebaseAuth.instance.currentUser;
//   //     if (user == null)
//   //       return "user == null";
//   //     for (var item in customersChat) {
//   //       var data = await FirebaseFirestore.instance.collection("chatRoom").doc(getChatRoomId(item.id, user.uid)).get();
//   //
//   //       if (data.data() != null) {
//   //         var _data = data.data()!;
//   //         item.all = (_data['all'] != null) ? _data['all'] : 0;
//   //         item.unread = (_data['unread_${user.uid}'] != null) ? _data['unread_${user.uid}'] : 0;
//   //         item.lastMessage = (_data['last_message'] != null) ? _data['last_message'] : "";
//   //         item.lastMessageTime = (_data['last_message_time'] != null) ? _data['last_message_time'].toDate().toLocal() : DateTime.now();
//   //         _unread += item.unread;
//   //       }
//   //       //
//   //       item.listen = FirebaseFirestore.instance.collection("chatRoom")
//   //           .doc(getChatRoomId(item.id, user.uid)).snapshots().listen((querySnapshot) async {
//   //         if (querySnapshot.data() != null) {
//   //           var _data = querySnapshot.data()!;
//   //           parent.stat.addStat("chat listen", _data.length);
//   //           item.all = (_data['all'] != null) ? _data['all'] : 0;
//   //           item.unread = (_data['unread_${user.uid}'] != null) ? _data['unread_${user.uid}'] : 0;
//   //           item.lastMessage = (_data['last_message'] != null) ? _data['last_message'] : "";
//   //           item.lastMessageTime = (_data['last_message_time'] != null) ? _data['last_message_time'].toDate().toLocal() : DateTime.now();
//   //           if (chatId == item.id) {
//   //             if (item.unread != 0) {
//   //               await FirebaseFirestore.instance.collection("chatRoom").doc(getChatRoomId(item.id, user.uid)).set({
//   //                 "unread_${user.uid}": 0,}, SetOptions(merge: true));
//   //               await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
//   //                 "unread_chat": FieldValue.increment(-item.unread),
//   //               }, SetOptions(merge: true));
//   //             }
//   //           }
//   //           customersChat.sort((a, b) => a.compareToAll(b));
//   //           customersChat.sort((a, b) => a.compareToUnread(b));
//   //           parent.notify();
//   //         }
//   //       });
//   //     }
//   //     customersChat.sort((a, b) => a.compareToAll(b));
//   //     customersChat.sort((a, b) => a.compareToUnread(b));
//   //     if (_unread != chatCount){
//   //       chatCount = _unread;
//   //       await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
//   //         "unread_chat": _unread,
//   //       }, SetOptions(merge: true));
//   //       parent.notify();
//   //     }
//   //   }catch(ex){
//   //     return "model getChatMessages " + ex.toString();
//   //   }
//   //   return null;
//   // }
//
//   // String chatName = "";
//   // int unread = 0;
//   // String chatLogo = "";
//   // String chatId = "";
//
//   // setChatData(String _title, int _unread, String _logo, String _chatId){
//   //   chatName = _title;
//   //   unread = _unread;
//   //   chatLogo = _logo;
//   //   chatId = _chatId;
//   // }
//
//   // String chatRoomId = "";
//   // Stream<QuerySnapshot>? chats;
//
//   // Future<String?> initChat() async {
//   //   try{
//   //     User? user = FirebaseAuth.instance.currentUser;
//   //     List<String> users = [user!.uid, chatId];
//   //
//   //     chatRoomId = getChatRoomId(user.uid, chatId);
//   //     Map<String, dynamic> chatRoom = {
//   //       "users": users,
//   //       "chatRoomId" : chatRoomId,
//   //     };
//   //     chats = null;
//   //     await FirebaseFirestore.instance
//   //         .collection("chatRoom")
//   //         .doc(chatRoomId)
//   //         .set(chatRoom, SetOptions(merge:true));
//   //   }catch(ex){
//   //     return "initChat " + ex.toString();
//   //   }
//   //   return _getChats();
//   // }
//
//   // Future<String?> _getChats() async {
//   //   try{
//   //     chats = FirebaseFirestore.instance
//   //         .collection("chatRoom")
//   //         .doc(chatRoomId)
//   //         .collection("chats")
//   //         .orderBy('time')
//   //         .snapshots();
//   //     User? user = FirebaseAuth.instance.currentUser;
//   //     FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).set({
//   //       "unread_${user!.uid}" : 0,
//   //     }, SetOptions(merge:true));
//   //     await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
//   //       "unread_chat": FieldValue.increment(-unread),
//   //     }, SetOptions(merge: true));
//   //   }catch(ex){
//   //     return "_getChats " + ex.toString();
//   //   }
//   //   return null;
//   // }
//   //
//   // Future<String?> addMessage(String text) async{
//   //   User? user = FirebaseAuth.instance.currentUser;
//   //   if (user == null)
//   //     return "User == null";
//   //
//   //   try{
//   //     Map<String, dynamic> chatMessageMap = {
//   //       "sendBy": user.uid,
//   //       'read': false,
//   //       "message": text,
//   //       'time': FieldValue.serverTimestamp(),
//   //     };
//   //
//   //     await FirebaseFirestore.instance.collection("chatRoom")
//   //         .doc(chatRoomId)
//   //         .collection("chats")
//   //         .add(chatMessageMap);
//   //
//   //     await FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).set({
//   //       "all": FieldValue.increment(1),
//   //       "unread_$chatId": FieldValue.increment(1),
//   //       "last_message": text,
//   //       "last_message_time": FieldValue.serverTimestamp(),
//   //       "last_message_from": user.uid,
//   //     }, SetOptions(merge: true));
//   //
//   //     await FirebaseFirestore.instance.collection("listusers").doc(chatId).set({
//   //       "unread_chat": FieldValue.increment(1),
//   //     }, SetOptions(merge: true));
//   //
//   //     var ret = await sendMessage(text, strings.get(252), chatId, false, appSettings.cloudKey); /// "Chat message"
//   //     if (ret != null)
//   //       print("error: chat addMessage $ret");
//   //
//   //   }catch(ex){
//   //     return ex.toString();
//   //   }
//   //   return null;
//   // }
//
//
//
//   // ignore: cancel_subscriptions
//   // StreamSubscription<DocumentSnapshot>? _listen;
//   //
//   // int chatCount = 0;
//   //
//   // disposeChatNotify(){
//   //   if (_listen != null)
//   //     _listen!.cancel();
//   // }
//
//   // listenChat(User? user){
//   //   _listen = FirebaseFirestore.instance.collection("listusers")
//   //       .doc(user!.uid).snapshots().listen((querySnapshot) {
//   //     if (querySnapshot.data() != null) {
//   //       var _data = querySnapshot.data()!;
//   //       //dprint(_data["unread_chat"]);
//   //       // var _chatCount = _data["unread_chat"] != null ? toInt(_data["unread_chat"].toString()) : 0;
//   //       var _chatCount = _data["unread_chat"] ?? 0;
//   //       if (_chatCount != chatCount) {
//   //         chatCount = _chatCount;
//   //         // sound
//   //         parent.playSound();
//   //         //
//   //       }
//   //       if (chatCount < 0) {
//   //         chatCount = 0;
//   //         FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
//   //           "unread_chat": chatCount,
//   //         }, SetOptions(merge: true));
//   //       }
//   //       parent.notify();
//   //     }
//   //   });
//   // }
// }
//
//
