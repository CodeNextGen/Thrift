import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';

class ExceptionStatement extends StatelessWidget{
  final String errorMessage;
  final String description;
  final Widget solution;
  final IconData iconData;
  final Color iconColor;
  const ExceptionStatement({@required this.errorMessage, @required this.description, this.solution, @required this.iconData, this.iconColor = dividerColor});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 32, bottom: 44, right: 32),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(iconData, size: 96, color: iconColor,),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(errorMessage, style: const TextStyle(fontSize: 20, color: primaryText),),
            ),
            Text(description, style: const TextStyle(fontSize: 16, color: secondaryText), textAlign: TextAlign.center,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: solution??Container(),
            ),
          ],
        ),
      ),
    );
  }
}