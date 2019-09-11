import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences sharedPreferences;

Future<void> initSharedPreferences() async {
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e){
    print("SharedPrefrences could not be initialized.");
  }
}

const String preference_disclosure = "disclosureAccepted";