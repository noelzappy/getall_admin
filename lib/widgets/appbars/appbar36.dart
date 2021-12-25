import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/model.dart';
import 'package:ondemand_admin/model/responsive.dart';
import '../../ui/theme.dart';

appbar36(
    Color bkgColor,
    Color color,
    String text,
    IconData icon,
    String avatar,
    String icon2,
    TextStyle style2,
    MainModel _mainModel,
    BuildContext context,
    Function(int) callback,
    Widget widget,
    Function() _redraw,
    Function() callbackChat) {
  _chatIcon() {
    return Container(
        height: 40,
        width: 40,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.center,
                child: Container(
                    child: Icon(
                  Icons.chat,
                  color: (theme.darkMode) ? Colors.white : Colors.black,
                  size: 25,
                ))),
            if (chatCount != 0)
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        chatCount.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ))),
            Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.grey[400],
                      onTap: () {
                        callbackChat();
                      }, // needed
                    ))),
          ],
        ));
  }

  _language() {
    return Container(
        padding: EdgeInsets.only(top: 3, bottom: 3),
        width: 250,
        child: Combo(
          inRow: true,
          text: "",
          data: _mainModel.adminDataCombo,
          value: appSettings.currentAdminLanguage,
          onChange: (String value) async {
            await _mainModel.langs.setAdminLang(value, context);
            _redraw();
          },
        ));
  }

  _avatar() {
    return Container(
        width: 40,
        height: 40,
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(5),
              child: avatar.isEmpty
                  ? CircleAvatar(
                      backgroundImage: AssetImage("assets/user5.png"),
                      radius: 50,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(avatar)),

              // ClipRRect(
              //   borderRadius: BorderRadius.circular(50.0),
              //   child: Container(
              //         alignment: Alignment.center,
              //           height: 30,
              //           width: 30,
              //           child: Image.asset(icon1,
              //               fit: BoxFit.contain
              //       ))),
            ),
            Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.grey[400],
                    onTap: () {
                      callback(1);
                    }, // needed
                  )),
            )
          ],
        ));
  }

  _userText() {
    return Container(
        alignment: Alignment.center,
        height: 40,
        child: Stack(
          children: <Widget>[
            Container(
              child: isMobile()
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          icon2,
                          style: style2,
                        ),
                        Text(
                          "MENU",
                          style: theme.style10W600Grey,
                        )
                      ],
                    )
                  : Text(
                      icon2,
                      style: style2,
                    ),
            ),
            Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  // shape: CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.grey[400],
                    onTap: () {
                      callback(2);
                    }, // needed
                  )),
            )
          ],
        ));
  }

  _menuIcon() {
    return Container(
      width: 40,
      height: 40,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: color,
                )),
          ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.grey[400],
                  onTap: () {
                    callback(0);
                  }, // needed
                )),
          )
        ],
      ),
    );
  }

  if (isMobile())
    return Container(
        height: 40 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: bkgColor,
        child: Column(
          children: [
            Row(
              children: [
                _menuIcon(),

                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color),
                    textAlign: TextAlign.center,
                  ),
                ),

                // user icon (avatar)
                _avatar(),

                // user text
                _userText(),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            Row(
              children: [
                // language
                // _language(),

                // dark mode
                // widget,
              ],
            )
          ],
        ));

  return Container(
      height: 40 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: bkgColor,
      child: Row(
        children: [
          _menuIcon(),

          Expanded(
            child: Text(
              "GetAll",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color),
              textAlign: TextAlign.center,
            ),
          ),

          //
          // Chat Icon
          //
          _chatIcon(),

          // language
          _language(),

          // dark mode
          widget,

          // user icon (avatar)
          _avatar(),

          // user text
          _userText(),

          SizedBox(
            width: 10,
          ),
        ],
      ));
}
