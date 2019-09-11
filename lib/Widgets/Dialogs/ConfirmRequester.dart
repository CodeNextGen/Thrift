import 'package:flutter/material.dart';

import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';

class ConfirmRequester extends StatelessWidget{
  final String question;
  final String confirmButtonText;
  final String cancelButtonText;
  final GestureTapCallback onConfirm;
  ConfirmRequester({@required this.question, @required this.confirmButtonText, @required this.cancelButtonText, @required this.onConfirm});
  @override
  Widget build(BuildContext context) {
    return MaterialDialog(
      headerText: question,
      confirmButtonText: confirmButtonText,
      confirmButtonCallback: onConfirm,
      cancelButtonCallback: () => Navigator.pop(context),
      cancelButtonText: cancelButtonText,
    );
  }
}
