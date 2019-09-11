import 'package:flutter/material.dart';
import 'package:thrift/Instances/Theme.dart';

class TopBarButton extends StatelessWidget{

  final GestureTapCallback onPressed;
  final IconData iconData;
  final String text;
  final EdgeInsets padding;
  final Color color;

  TopBarButton({@required this.onPressed, @required this.iconData, @required this.text, this.padding, Color color}) : this.color = color??box;

  static const double borderRadius = 8;
  static const double buttonHeight = 56;
  static const double buttonElevation = 2;
  static const bool softWrap = false;
  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: RawMaterialButton(
        onPressed: onPressed,
        splashColor: colorPrimaryDark,
        fillColor: color,
        elevation: buttonElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: Container(
          height: buttonHeight,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(iconData, color: white,),
              ),
              Expanded(
                child: Text(
                  text, style: const TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w600), maxLines: maxLines, softWrap: softWrap, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}