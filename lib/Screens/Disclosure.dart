import 'package:flutter/material.dart';

import 'package:thrift/FullscreenDialogs/Privacy Policy.dart';
import 'package:thrift/FullscreenDialogs/Terms and Conditions.dart';
import 'package:thrift/Screens/AppTour.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/PolicyAccepted.dart';
import 'package:thrift/Instances/SharedPreferences.dart';

import 'package:thrift/Widgets/Reusable UI components/BottomSelector.dart';

class Disclosure extends StatefulWidget{
  ProminentDisclosureState createState() => ProminentDisclosureState();
}

class ProminentDisclosureState extends State<Disclosure>{
  static const String label = "Disclosure";

  ValueNotifier<bool> privacyPolicyAccepted;

  @override
  void initState() {
    super.initState();
    privacyPolicyAccepted = ValueNotifier(false);
  }

  @override
  void dispose() {
    privacyPolicyAccepted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => policyAccepted,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          title: const Text(label, style: const TextStyle(color: primaryText),),
          leading: Container(),
        ),
        body: Container(
          color: white,
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.vertical,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const Padding(
                      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                      child: const Text(
                        "Thrift requires you to provide your financial and payment data, which is personally identifiable information. \n\nTo provide you the Service, we may collect and use that information as described in Terms and Conditions and in our Privacy Policy.",
                        style: const TextStyle(color: primaryText, fontSize: 16),
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ValueListenableBuilder<bool>(
                          valueListenable: privacyPolicyAccepted,
                          builder: (context, acceptanceValue, child){
                            return Checkbox(
                              value: acceptanceValue,
                              onChanged: (bool)=>privacyPolicyAccepted.value=bool,
                            );
                          },
                        ),
                        Flexible(
                          child: Flex(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text("I confirm that I am atleast 13 years old and agree to: ", style: const TextStyle(color: secondaryText, fontSize: 14,),),
                              Container(height: 8,),
                              GestureDetector(
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions()));},
                                child: const Text("Terms and Conditions", style: const TextStyle(decoration: TextDecoration.underline, color: secondaryText, fontSize: 14,),),
                              ),
                              Container(height: 8,),
                              GestureDetector(
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy()));},
                                child: const Text("Privacy policy;", style: const TextStyle(decoration: TextDecoration.underline, color: secondaryText, fontSize: 14,),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: privacyPolicyAccepted,
          builder: (context, acceptance, child){
            return BottomSelector(
              cancel: "Skip to app",
              onCancel: acceptance?() async {
                sharedPreferences.setBool(preference_disclosure, true);
                policyAccepted = true;
                Navigator.pop(context);
              }:null,
              confirm: "View app tour",
              onConfirm: acceptance?() async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AppTour(), maintainState: false),);
              }:null,
            );
          },
        ),
      ),
    );
  }
}