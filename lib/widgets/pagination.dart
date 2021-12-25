import 'package:flutter/material.dart';
import 'package:ondemand_admin/model/responsive.dart';

import '../ui/strings.dart';
import '../ui/theme.dart';
import 'buttons/button168.dart';

int _visibleCount = 0;

pagingStart(){
  _visibleCount = 0;
}

pagingIncrement(){
  _visibleCount++;
}

isNotInPagingRange(){
  return _visibleCount-1 < _pStart || _visibleCount-1 >= _pStart+pRange;
}

paginationLine(List<Widget> list, Function() _redraw){
  // pagination
  list.add(SizedBox(height: 10,));
  _paginsCount = _visibleCount ~/pRange;
  // print ("_paginsCount=$_paginsCount _visibleCount=$_visibleCount _visibleCount%_pRange=${_visibleCount%_pRange}");
  if (_visibleCount%pRange > 0)
    _paginsCount++;
  List<Widget> list2 = [];
  if (_paginsCount > 12){
    var _st = _currentPage - 5;
    var _end = _currentPage + 5;
    if (_st < 1)
      _st = 1;
    else
      list2.add(Text("  ...  ", style: theme.style16W800,));
    if (_end > _paginsCount)
      _end = _paginsCount;
    for (var i = _st; i <= _end; i++){
      list2.add(button168("$i", theme.mainColor, 5, (){_pagin(i, _redraw);}, (i == _currentPage) ? false : true));
      list2.add(SizedBox(width: 5,));
    }
    if (_end != _paginsCount)
      list2.add(Text("  ...  ", style: theme.style16W800,));
  }else
    for (var i = 1; i <= _paginsCount; i++){
      list2.add(button168("$i", theme.mainColor, 5, (){_pagin(i, _redraw);}, (i == _currentPage) ? false : true));
      list2.add(SizedBox(width: 5,));
    }
  var t = _pStart+pRange;
  if (t > _visibleCount)
    t = _visibleCount;
  list.add(Row(
    children: [
      if (!isMobile())
        SizedBox(width: 40,),
      Text("${_pStart+1}-$t ${strings.get(88)} $_visibleCount", style: TextStyle(fontSize: 18),), // from
      Expanded(child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list2,))
    ],
  ));
}

var _paginsCount = 0;
var _pStart = 0;
var pRange = 10;
var _currentPage = 1;
_pagin(int i, Function() _redraw){
  _pStart = (i-1) * pRange;
  // print("_pagin _pStart =$_pStart i=$i");
  _currentPage = i;
  _redraw();
}