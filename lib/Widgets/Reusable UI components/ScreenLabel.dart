import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';

class ScreenLabel extends StatelessWidget{
  final String label;
  ScreenLabel({@required this.label});
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24,),
          child: Text(label, textAlign: TextAlign.start, style: TextStyle(color: secondaryText, fontSize: 16),),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Divider(
            height: 1,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
}