import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/PolicyAccepted.dart';
import 'package:thrift/Instances/Routes.dart';
import 'package:thrift/Instances/Notifiers/Snackbar.dart';
import 'package:thrift/Functions/setStatusBarColor.dart';

import 'package:thrift/Screens/Thrift/BottomNavi.dart';
import 'package:thrift/Screens/Thrift/TopBar.dart';
import 'package:thrift/Screens/Thrift/Body.dart';

class Thrift extends StatefulWidget {
  ThriftState createState() => ThriftState();
}

class ThriftState extends State<Thrift>{

  @override
  void initState() {
    if(!policyAccepted){
      WidgetsBinding.instance.addPostFrameCallback((_){
        Navigator.pushNamed(context, route_Disclosure);
      });
    }
    //setStatusBarColor(colorPrimary); //TODO CHECK
    snackbarNotifier.addListener(showSnackbar);
    super.initState();
  }

  @override
  void dispose() {
    snackbarNotifier.removeListener(showSnackbar);
    super.dispose();
  }

  void showSnackbar(){
    if(snackbarNotifier.value!=null) {
      scaffoldKey.currentState.hideCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(snackbarNotifier.value);
      snackbarNotifier.value = null;
    }
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: TopBar(),
      body: Body(),
      bottomNavigationBar: BottomNavi(),
    );
  }
}