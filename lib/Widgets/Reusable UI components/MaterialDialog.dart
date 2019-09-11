import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';

class MaterialDialog extends StatelessWidget{
  static const double headerHeight = 64;

  final String headerText;
  final Widget child;
  final Widget headerWidget;

  final bool useMaterialButtonDesign;
  final String cancelButtonText;
  final GestureTapCallback cancelButtonCallback;
  final String confirmButtonText;
  final GestureTapCallback confirmButtonCallback;

  MaterialDialog({this.headerWidget, @required this.headerText, this.child, this.useMaterialButtonDesign, @required this.confirmButtonCallback, @required this.confirmButtonText, this.cancelButtonCallback, this.cancelButtonText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: dialogWidth,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(child: DialogContent(child: child, headerText: headerText, headerWidget: headerWidget,)),
            DialogButtonRow(
              useMaterialButtonDesign: useMaterialButtonDesign,
              leftText: cancelButtonText,
              rightText: confirmButtonText,
              leftAction: cancelButtonCallback,
              rightAction: confirmButtonCallback,
            ),
          ],
        ),
      ),
    );
  }
}

class DialogContent extends StatelessWidget{
  static const double headerHeight = 64;
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets nonHeaderPadding = EdgeInsets.only(left: 24, right: 24, bottom: 28, top: 22);
  static const TextStyle headerStyle = TextStyle(fontSize: 20, color: primaryText);
  static const TextStyle nonHeaderStyle = TextStyle(fontSize: 16, color: secondaryText);

  final String headerText;
  final Widget child;
  final Widget headerWidget;
  DialogContent({@required this.headerWidget, @required this.child, @required this.headerText});

  @override
  Widget build(BuildContext context) {
    if(child!=null){
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: headerHeight,
            child: Padding(
              padding: headerPadding,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(child: Text(headerText, style: headerStyle, overflow: TextOverflow.ellipsis,)),
                  headerWidget??Container(),
                ],
              ),
            ),
          ),
          divider,
          Flexible(child: child),
          divider,
        ],
      );
    } else {
      return Padding(
        padding: nonHeaderPadding,
        child: Text(headerText, style: nonHeaderStyle,),
      );
    }
  }
}

class DialogButtonRow extends StatelessWidget{
  static const double materialRowHeight = 52;
  static const double nonMaterialButtonRadius = 8;

  final bool useMaterialButtonDesign;
  final GestureTapCallback leftAction;
  final GestureTapCallback rightAction;
  final String leftText;
  final String rightText;
  DialogButtonRow({bool useMaterialButtonDesign, this.leftAction, this.leftText, @required this.rightAction, @required this.rightText}):this.useMaterialButtonDesign=useMaterialButtonDesign??true;
  @override
  Widget build(BuildContext context) {
    if(useMaterialButtonDesign) {
      if (leftAction != null && leftText != null) {
        return Container(
          height: materialRowHeight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: leftAction,
                  splashColor: Colors.grey[400],
                  textColor: buttonText,
                  child: Text(leftText, style: const TextStyle(fontSize: 16),),
                ),
                FlatButton(
                  onPressed: rightAction,
                  splashColor: Colors.grey[400],
                  textColor: buttonText,
                  child: Text(rightText, style: const TextStyle(fontSize: 16),),
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          height: materialRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: rightAction,
                  splashColor: Colors.grey[400],
                  textColor: buttonText,
                  child: Text(rightText, style: const TextStyle(fontSize: 16),),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: OutlineButton(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              onPressed: rightAction,
              splashColor: white,
              borderSide: const BorderSide(color: white),
              shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.all(const Radius.circular(nonMaterialButtonRadius),),),
              child: Text(rightText, style: const TextStyle(color: buttonText, fontSize: 14),),
            ),
          ),
        ],
      );
    }
  }
}