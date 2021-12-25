import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../strings.dart';
import '../theme.dart';


documentBlock(String text1, TextEditingController _controller, String hint, Function() _redraw){
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.blue.withAlpha(10),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(text1, style: theme.style14W400,),
        SizedBox(height: 5,),
        Edit41web(controller: _controller,
          multiline: true,
          hint: hint,
          onChange: (String _){_redraw();},
        ),
        SizedBox(height: 5,),
        SelectableText(strings.get(25), style: theme.style14W400,),// "Preview",
        Html(
          data: _controller.text,
            style: {
            "body": Style(
            backgroundColor: (theme.darkMode) ? Colors.black : Colors.transparent,
            color: (theme.darkMode) ? Colors.transparent : Colors.black
            ),
            }
        )
      ],
    ),
  );
}
