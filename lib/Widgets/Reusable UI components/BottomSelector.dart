import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';

class BottomSelector extends StatelessWidget{

  final String errorMsg;
  final String cancel;
  final String confirm;
  final GestureTapCallback onCancel;
  final GestureTapCallback onConfirm;
  static const String defaultCancelText = "Cancel";
  static const String defaultConfirmText = "Confirm";
  BottomSelector({@required this.onCancel, @required this.onConfirm, String cancel, String confirm, this.errorMsg}) : this.cancel = cancel ?? defaultCancelText, this.confirm = confirm ?? defaultConfirmText;

  static const double buttonRadius = 8;
  static const double buttonSize = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(color: dividerColor, height: 1,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(errorMsg == null? 1: 0),
                height: buttonSize,
                child: errorMsg == null ? Flex(
                  direction: Axis.horizontal,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: OutlineButton(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        onPressed: onCancel,
                        splashColor: white,
                        disabledTextColor: dividerColor,
                        disabledBorderColor: white,
                        textColor: onCancel!=null?buttonText:dividerColor,
                        borderSide: const BorderSide(color: white),
                        shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.all(const Radius.circular(buttonRadius)),),
                        child: Text(cancel, style: const TextStyle(color: buttonText, fontSize: 14),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: OutlineButton(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        onPressed: onConfirm,
                        disabledTextColor: dividerColor,
                        disabledBorderColor: dividerColor,
                        textColor: onConfirm!=null?buttonText:dividerColor,
                        borderSide: const BorderSide(color: dividerColor),
                        shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.all(const Radius.circular(buttonRadius)),),
                        splashColor: white,
                        child: Text(confirm, style: const TextStyle(color: buttonText, fontSize: 14),),
                      ),
                    ),
                  ],
                ) : Center(
                  child: Text(errorMsg, style: const TextStyle(fontSize: 16, color: secondaryText),),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}