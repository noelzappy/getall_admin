import 'package:abg_utils/abg_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../ui/strings.dart';
import '../ui/theme.dart';
import '../utils.dart';
import 'initData/statuses.dart';
import 'model.dart';

class MainDataModelSettings {

  final MainModel parent;

  MainDataModelSettings({required this.parent});

  int _lastBookingNewCount = -1;

  Future<String?> settings(BuildContext context, Function()? _redrawMenu) async {

    parent.statusesCombo = [];
    parent.statusesComboForBookingSearch = [];
    parent.statusesComboForBookingSearch.add(ComboData(strings.get(254), "-1"));  // "All"
    parent.callback(strings.get(203)); /// "Loading settings ...",

    loadSettings(() async {
      //_lastBookingNewCount = appSettings.bookingCountUnread;
      parent.langEditDataComboValue = appSettings.defaultServiceAppLanguage;
      if (appSettings.statusesFound){
        parent.statusesCombo = [];
        for (var item in appSettings.statuses){
          parent.statusesCombo.add(ComboData(getTextByLocale(item.name, strings.locale), item.id));
          parent.statusesComboForBookingSearch.add(ComboData(getTextByLocale(item.name, strings.locale), item.id));
        }
      }else{
        await uploadStatusImages(parent.callback);
        await saveStatuses();
      }
      statusesGetCompleted();
      theme = AppTheme(appSettings.adminDarkMode);
      if (_redrawMenu != null)
        _redrawMenu();

      if (_lastBookingNewCount == 0)
        if (_lastBookingNewCount != appSettings.bookingCountUnread){
          _lastBookingNewCount = appSettings.bookingCountUnread;
          parent.playSound();
        }
      if (_lastBookingNewCount == -1)
        _lastBookingNewCount = 0;

      // return listenerCounts(_redrawMenu);
    });
  }

  Future<String?> saveElementsList() async{
    try{
      var _data = {
        "customerAppElements": appSettings.customerAppElements,
        "customerAppElementsDisabled" : appSettings.customerAppElementsDisabled,
      };
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return "saveElementsList " + ex.toString();
    }
    return null;
  }

  Future<String?> saveProviderAreaMap() async{
    try{
      var _data = {
        "providerAreaMapZoom": appSettings.providerAreaMapZoom,
        "providerAreaMapLat" : appSettings.providerAreaMapLat,
        "providerAreaMapLng" : appSettings.providerAreaMapLng,
      };
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return "saveProviderAreaMap " + ex.toString();
    }
    return null;
  }

  Future<String?> saveDarkMode() async{
    try{
      var _data = {
        "adminDarkMode": theme.darkMode,
      };
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return "saveDarkMode " + ex.toString();
    }
    return null;
  }

  statusesGetCompleted(){
    appSettings.statuses.sort((a, b) => a.position.compareTo(b.position));
    parent.completeStatus = "";
    // List<StringData> name = [];
    for (var item in appSettings.statuses)
      if (!item.cancel) {
        parent.completeStatus = item.id;
        // name = item.name;
      }
    // print("statusesGetCompleted ${parent.completeStatus} $name" );
  }

  // Future<String?> listenerCounts(Function()? _redrawMenu) async{
  //   if (_redrawMenu == null)
  //     return null;
  //   try{
  //     FirebaseFirestore.instance.collection("settings")
  //         .doc("main").snapshots().listen((querySnapshot) {
  //       if (querySnapshot.data() != null) {
  //         var data = querySnapshot.data()!;
  //         // print("listenerCounts $data");
  //         appSettings.providerRequestCount = data["provider_request_count"] ?? 0;
  //         appSettings.providerNewRequestCount = data["provider_new_request_count"] ?? 0;
  //         appSettings.serviceCount = data["service_count"] ?? 0;
  //         appSettings.providerCount = data["provider_count"] ?? 0;
  //         appSettings.blogCount = data["blog_count"] ?? 0;
  //         appSettings.categoryCount = data["category_count"] ?? 0;
  //         appSettings.bookingCount = data["booking_count"] ?? 0;
  //         appSettings.bookingCountUnread = data["booking_count_unread"] ?? 0;
  //         if (_lastBookingNewCount != appSettings.bookingCountUnread){
  //           _lastBookingNewCount = appSettings.bookingCountUnread;
  //           parent.playSound();
  //         }
  //         _redrawMenu();
  //       }
  //     });
  //   }catch(ex){
  //     return "listenerCounts " + ex.toString();
  //   }
  //   return null;
  // }

  Future<String?> saveSettingsGeneral(String name, String mapApi, String messageKey,
      String _comission) async{
    // demo mode
    // if (appSettings.demo)
    //   return strings.get(65); /// "This is Demo Mode. You can't modify this section",
    // appSettings.appname = name;
    appSettings.googleMapApiKey = mapApi;
    appSettings.cloudKey = messageKey;
    appSettings.defaultAdminComission = toInt(_comission);
    var _data = {
      // "appname": appSettings.appname,
      "google_map_apikey" : appSettings.googleMapApiKey,
      "cloud_key" : messageKey,
      "distance_unit" : appSettings.distanceUnit,
      "time_format" : appSettings.timeFormat,
      "date_format" : appSettings.dateFormat,
      "def_admin_comission" : appSettings.defaultAdminComission,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return "saveSettingsGeneral " + ex.toString();
    }
    return null;
  }

  Future<String?> saveSettingsCurrency(String _code, String _symbol) async{
    appSettings.code = _code;
    appSettings.symbol = _symbol;
    var _data = {
      "code": _code,
      "symbol" : _symbol,
      "right_symbol" : appSettings.rightSymbol,
      "digits_after_comma" : appSettings.digitsAfterComma,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
      appSettings.setPriceStringDataForUtils();
    }catch(ex){
      return "saveSettingsCurrency " + ex.toString();
    }
    return null;
  }

  Future<String?> saveSettingsPayments(String _stripeKey, String _stripeSecretKey, String _paypalSecretKey,
      String _paypalClientId, String _razorpayName, String _razorpayKey,
      String _payStackKey, String _flutterWaveEncryptionKey, String _flutterWavePublicKey,
      String _mercadoPagoAccessToken, String _mercadoPagoPublicKey,
      String _payMobApiKey, String _payMobFrame, String _payMobIntegrationId,
      String _instamojoToken, String _instamojoApiKey,
      String _payUApiKey, String _payUMerchantId
      ) async{
    if (appSettings.demo)
      return strings.get(65); /// "This is Demo Mode. You can't modify this section",
    appSettings.stripeKey = _stripeKey;
    appSettings.stripeSecretKey = _stripeSecretKey;
    appSettings.paypalSecretKey = _paypalSecretKey;
    appSettings.paypalClientId = _paypalClientId;
    appSettings.razorpayName = _razorpayName;
    appSettings.razorpayKey = _razorpayKey;
    // payStack
    appSettings.payStackKey = _payStackKey;
    // FlutterWave
    appSettings.flutterWaveEncryptionKey = _flutterWaveEncryptionKey;
    appSettings.flutterWavePublicKey = _flutterWavePublicKey;
    // MercadoPago
    appSettings.mercadoPagoAccessToken = _mercadoPagoAccessToken;
    appSettings.mercadoPagoPublicKey = _mercadoPagoPublicKey;
    // PayMob
    appSettings.payMobApiKey = _payMobApiKey;
    appSettings.payMobFrame = _payMobFrame;
    appSettings.payMobIntegrationId = _payMobIntegrationId;
    // Instamojo
    appSettings.instamojoToken = _instamojoToken;
    appSettings.instamojoApiKey = _instamojoApiKey;
    // PayU
    appSettings.payUApiKey = _payUApiKey;
    appSettings.payUMerchantId = _payUMerchantId;

    var _data = {
      "stripe_enable": appSettings.stripeEnable,
      "stripe_key": appSettings.stripeKey,
      "stripe_secret_key": appSettings.stripeSecretKey,
      "paypal_enable": appSettings.paypalEnable,
      "paypalSandBox": appSettings.paypalSandBox,
      "paypal_secret_key": appSettings.paypalSecretKey,
      "paypal_client_id": appSettings.paypalClientId,
      "razorpay_enable": appSettings.razorpayEnable,
      "razorpay_name": appSettings.razorpayName,
      "razorpay_key": appSettings.razorpayKey,
      // paystack
      "payStack_enable": appSettings.payStackEnable,
      'payStackKey': appSettings.payStackKey,
      // FlutterWave
      'flutterWaveEnable':  appSettings.flutterWaveEnable,
      'flutterWaveEncryptionKey': appSettings.flutterWaveEncryptionKey,
      'flutterWavePublicKey': appSettings.flutterWavePublicKey,
      // MercadoPago
      'mercadoPagoEnable' : appSettings.mercadoPagoEnable,
      'mercadoPagoAccessToken' : appSettings.mercadoPagoAccessToken,
      'mercadoPagoPublicKey' : appSettings.mercadoPagoPublicKey,
      // PayMob
      'payMobEnable' : appSettings.payMobEnable,
      'payMobApiKey' : appSettings.payMobApiKey,
      'payMobFrame' : appSettings.payMobFrame,
      'payMobIntegrationId' : appSettings.payMobIntegrationId,
      // Instamojo
      'instamojoEnable' : appSettings.instamojoEnable,
      'instamojoToken' : appSettings.instamojoToken,
      'instamojoApiKey' : appSettings.instamojoApiKey,
      'instamojoSandBoxMode' : appSettings.instamojoSandBoxMode,
      // payU
      'payUEnable': appSettings.payUEnable,
      'payUApiKey': appSettings.payUApiKey,
      'payUMerchantId': appSettings.payUMerchantId,
      'payUSandBoxMode': appSettings.payUSandBoxMode,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    return null;
  }

  Future<String?> saveSettingsOTP(String _otpPrefix, String _otpNumber,
      String _twilioAccountSID, String _twilioAuthToken, String _twilioServiceId,
      _nexmoFrom, _nexmoText, _nexmoApiKey, _nexmoApiSecret, _sMSToFrom,
      _sMSToText, _sMSToApiKey) async{

    if (appSettings.demo)
      return strings.get(65); /// "This is Demo Mode. You can't modify this section",

    appSettings.otpPrefix = _otpPrefix;
    appSettings.otpNumber = int.parse(_otpNumber);
    appSettings.twilioAccountSID = _twilioAccountSID;
    appSettings.twilioAuthToken = _twilioAuthToken;
    appSettings.twilioServiceId = _twilioServiceId;
    // nexmo
    appSettings.nexmoFrom = _nexmoFrom;
    appSettings.nexmoText = _nexmoText;
    appSettings.nexmoApiKey = _nexmoApiKey;
    appSettings.nexmoApiSecret = _nexmoApiSecret;
    // sms.to
    appSettings.smsToFrom = _sMSToFrom;
    appSettings.smsToText = _sMSToText;
    appSettings.smsToApiKey = _sMSToApiKey;
    var _data = {
      "otpEnable": appSettings.otpEnable,
      "otpPrefix": appSettings.otpPrefix,
      "otpNumber": appSettings.otpNumber,
      "otpTwilioEnable": appSettings.otpTwilioEnable,
      "twilioAccountSID": appSettings.twilioAccountSID,
      "twilioAuthToken": appSettings.twilioAuthToken,
      "twilioServiceId": appSettings.twilioServiceId,
      // nexmo
      "otpNexmoEnable" : appSettings.otpNexmoEnable,
      "nexmoFrom" : appSettings.nexmoFrom,
      "nexmoText" : appSettings.nexmoText,
      "nexmoApiKey" : appSettings.nexmoApiKey,
      "nexmoApiSecret" : appSettings.nexmoApiSecret,
      // sms.to
      "otpSMSToEnable" : appSettings.otpSMSToEnable,
      "smsToFrom" : appSettings.smsToFrom,
      "smsToText" : appSettings.smsToText,
      "smsToApiKey" : appSettings.smsToApiKey,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    return null;
  }

  Future<String?> saveSettingsShare(String _googlePlayLink, String _appStoreLink) async{
    appSettings.googlePlayLink = _googlePlayLink;
    appSettings.appStoreLink = _appStoreLink;
    var _data = {
      "googlePlayLink": appSettings.googlePlayLink,
      "appStoreLink": appSettings.appStoreLink,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    return null;
  }

  Future<String?> saveSettingsDocuments(String _copyright, String _about, String _policy, String _terms) async{
    appSettings.copyright = _copyright;
    appSettings.about = _about;
    appSettings.policy = _policy;
    appSettings.terms = _terms;
    var _data = {
      "copyright": appSettings.copyright,
      "about": appSettings.about,
      "policy": appSettings.policy,
      "terms": appSettings.terms,
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    return null;
  }

  moveUp(StatusData item){
    StatusData? _last;
    for (var item2 in appSettings.statuses){
      if (item2.id == item.id){
        if (_last == null)
          return;
        var _position = item.position;
        item.position = _last.position;
        _last.position = _position;
        appSettings.statuses.sort((a, b) => a.position.compareTo(b.position));
        return parent.notify();
      }
      _last = item2;
    }
  }

  delete(StatusData item, BuildContext context, Function() _redraw){
    openDialogDelete(() {
      Navigator.pop(context); // close dialog
      // demo mode
      if (appSettings.demo)
        return messageError(context, strings.get(65)); /// "This is Demo Mode. You can't modify this section",
      appSettings.statuses.remove(item);
      appSettings.statuses.sort((a, b) => a.position.compareTo(b.position));
      _redraw();
    }, context);
  }

  moveDown(StatusData item){
    bool searched = false;
    for (var item2 in appSettings.statuses){
      if (item2.id == item.id){
        searched = true;
        continue;
      }
      if (searched) {
        var _position = item2.position;
        item2.position = item.position;
        item.position = _position;
        appSettings.statuses.sort((a, b) => a.position.compareTo(b.position));
        return parent.notify();
      }
    }
  }

  select(StatusData select){
    parent.currentStatus = select;
    parent.notify();
  }

  setName(String val){
    for (var item in parent.currentStatus.name)
      if (parent.langEditDataComboValue == item.code) {
        item.text = val;
        return;
      }
    parent.currentStatus.name.add(StringData(code: parent.langEditDataComboValue, text: val));
  }

  create(){
    var pos = 0;
    for (var item in appSettings.statuses)
      if (item.position >= pos)
        pos = item.position + 1;

    parent.currentStatus.position = pos;
    parent.currentStatus.id = UniqueKey().toString();
    appSettings.statuses.add(parent.currentStatus);
    appSettings.statuses.sort((a, b) => a.position.compareTo(b.position));
  }

  Future<String?> saveStatuses() async{
    statusesGetCompleted();
    var _data = {
      "statuses": appSettings.statuses.map((i) => i.toJson()).toList(),
    };
    try{
      await FirebaseFirestore.instance.collection("settings").doc("main").set(_data, SetOptions(merge:true));
    }catch(ex){
      return ex.toString();
    }
    return null;
  }
}

