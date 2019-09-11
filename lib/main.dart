import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thrift/Functions/Fetch.dart';
import 'package:thrift/API/Transmit.dart';

import 'package:thrift/Models/Arguments.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/SharedPreferences.dart';
import 'package:thrift/Instances/Device.dart';
import 'package:thrift/Instances/PolicyAccepted.dart';
import 'package:thrift/Instances/Routes.dart';

import 'package:thrift/Instances/Notifiers/Snackbar.dart';
import 'package:thrift/Instances/Notifiers/fragmentID.dart';

import 'package:thrift/Screens/Thrift/Thrift.dart';
import 'package:thrift/Screens/Disclosure.dart';

import 'package:thrift/FullscreenDialogs/Managers/EntryManager.dart';
import 'package:thrift/FullscreenDialogs/Managers/TransactionManager.dart';
import 'package:thrift/FullscreenDialogs/Managers/CategoryManager.dart';
import 'package:thrift/FullscreenDialogs/Managers/AccountManager.dart';
import 'package:thrift/FullscreenDialogs/HelpCenter.dart';
import 'package:thrift/FullscreenDialogs/Licences.dart';
import 'package:thrift/FullscreenDialogs/Privacy Policy.dart';
import 'package:thrift/FullscreenDialogs/Terms and Conditions.dart';
import 'package:thrift/FullscreenDialogs/Cloud.dart';
import 'package:thrift/FullscreenDialogs/Subscribe.dart';
import 'package:thrift/FullscreenDialogs/Login.dart';


void main() async {
  await initSharedPreferences();
  await fetch();
  authDataNotifier = ValueNotifier(await AuthData.fromMemory());
  setLayout();
  fragmentIDNotifier.addListener(() => snackbarNotifier.value = null);
  policyAccepted = sharedPreferences.getBool("disclosureAccepted")??false;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: colorPrimary,
  ));
  runApp(ThriftApp());
}

class ThriftApp extends StatefulWidget{
  ThriftAppState createState() => ThriftAppState();
}

class NoGlowingOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ThriftAppState extends State<ThriftApp>{

  @override
  void initState() {
    if(device.screen == Device.device_PHONE) {SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp,]);}
    checkSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowingOverscrollBehavior(),
      child: MaterialApp(
        title: "Thrift",
        theme: ThemeData(
          primaryColor: colorPrimary,
          primaryColorDark: colorPrimaryDark,
          accentColor: colorPrimary,
        ),
        home: Thrift(),
        onGenerateRoute: (settings){
          Arguments arguments = settings.arguments;
          switch(settings.name){

            case route_Disclosure:
              return MaterialPageRoute(builder: (context) => Disclosure());

              //Managers
            case route_CategoryManager:
              return MaterialPageRoute(builder: (context) => CategoryManager(category: arguments.transactionCategory,), fullscreenDialog: true);
            case route_TransactionManager:
              return MaterialPageRoute(builder: (context) => TransactionManager(category: arguments.transactionCategory, transaction: arguments.transaction, entry: arguments.entry,), fullscreenDialog: true);
            case route_EntryManager:
              return MaterialPageRoute(builder: (context) => EntryManager(entry: arguments!=null?arguments.entry:null,), fullscreenDialog: true);
            case route_AccountManager:
              return MaterialPageRoute(builder: (context) => AccountManager(), fullscreenDialog: true);

              //Dialogs
            case route_HelpCenter:
              return MaterialPageRoute(builder: (context) => HelpCenter(), fullscreenDialog: true);
            case route_Licences:
              return MaterialPageRoute(builder: (context) => Licenses(), fullscreenDialog: true);
            case route_PrivacyPolicy:
              return MaterialPageRoute(builder: (context) => PrivacyPolicy(), fullscreenDialog: true);
            case route_TermsAndConditions:
              return MaterialPageRoute(builder: (context) => TermsAndConditions(), fullscreenDialog: true);
            case route_Cloud:
              return MaterialPageRoute(builder: (context) => authDataNotifier.value.subscribed!=null && authDataNotifier.value.subscribed? authDataNotifier.value.signature != null? Cloud():Login() :Subscribe(), fullscreenDialog: true);
            case route_Subscribe:
              return MaterialPageRoute(builder: (context) => Subscribe(), fullscreenDialog: true);
            case route_Login:
              return MaterialPageRoute(builder: (context) => Login(), fullscreenDialog: true);

            default:
              return null;

          }
        },
      ),
    );
  }
}