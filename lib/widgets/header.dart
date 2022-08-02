import 'package:flutter/material.dart';








AppBar header(context,{bool isAppTitle = false, String titleText, removeBackButton = true, Function function}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton? false : true   ,
    title: Text(
      isAppTitle ?  'COMMUNITY AID': titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'BodoniModa' : "",
        fontSize: isAppTitle ? 30 : 22,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
    elevation: 5,

  );
}
