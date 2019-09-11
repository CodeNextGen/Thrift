import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thrift/Instances/Notifiers/backdropOpen.dart';
import 'package:thrift/Instances/Notifiers/fragmentID.dart';
import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/Routes.dart';

import 'package:thrift/Widgets/Reusable UI components/Backdrop.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';
import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';

import 'package:thrift/Widgets/Fragments/Chart/Chart.dart';
import 'package:thrift/Widgets/Fragments/History.dart';
import 'package:thrift/Widgets/Fragments/Dashboard/Dashboard.dart';
import 'package:thrift/Widgets/Fragments/Agenda.dart';

const double backdropHeaderSize = 48;

class Body extends StatelessWidget {

  String get fragmentName{
    switch(fragmentIDNotifier.value){
      case 0:
        return "Pending transactions";
      case 1:
        return "Caregories chart";
      case 2:
        return "Dashboard";
      case 3:
        return "Transaction history";
      default:
        return "Error";
    }
  }

  Widget get fragmentWidget{
    switch(fragmentIDNotifier.value){
      case 0:
        return Agenda();
      case 1:
        return Chart();
      case 2:
        return Dashboard();
      case 3:
        return History();
      default:
        return const Center(child: const Padding(
          padding: const EdgeInsets.all(24),
          child: const Text("Please screenshot and contact support", style: const TextStyle(fontSize: 16, color: secondaryText),),
        ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: fragmentIDNotifier,
      builder: (context, fragmentID, child){
        return Container(
          color: colorPrimary,
          child: Backdrop(
            headerSize: backdropHeaderSize,
            header: BackdropHeader(fragmentName: fragmentName),
            backLayer: BackLayer(),
            frontLayer: FrontLayer(valueKey: ValueKey<int>(fragmentID), fragment: fragmentWidget,),
          ),
        );
      },
    );
  }
}

class BackLayer extends StatelessWidget{
  static const bool shrinkWrap = false;

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorPrimary,
      child: ListView(
        shrinkWrap: shrinkWrap,
        padding: const EdgeInsets.only(bottom: backdropHeaderSize,),
        children: <Widget>[
          TopBarButton(
            padding: buttonPadding,
            iconData: Icons.live_help,
            text: "Help center",
            onPressed: () => Navigator.pushNamed(context, route_HelpCenter),
          ),
          TopBarButton(
            padding: buttonPadding,
            iconData: Icons.loyalty,
            text: "Contact us & feedback",
            onPressed: () => showDialog(
              context: context,
              builder: (context) => MaterialDialog(
                useMaterialButtonDesign: false,
                headerText: "Contact us",
                confirmButtonCallback: () => Navigator.pop(context),
                confirmButtonText: "Close",
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: const Text("We will respond as soon as possible to every message recieved by any of these feedback channels:", style: const TextStyle(color: secondaryText, fontSize: 16), ),
                    ),
                    RawMaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Text("E-mail", style: const TextStyle(fontSize: 16, color: secondaryText),),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.mail, color: colorPrimary,),
                          )
                        ],
                      ),
                      onPressed: () async {
                        var url = 'mailto:darkandjeweled@gmail.com?subject=Thrift';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                    RawMaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Text("Twitter", style: const TextStyle(fontSize: 16, color: secondaryText),),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.category, color: colorPrimary,),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var url = 'https://twitter.com/DarkAndJeweled';
                        if (await canLaunch(url)) {
                          launch(url);
                        }
                      },
                    ),
                    RawMaterialButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            const Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: const Text("Store page", style: const TextStyle(fontSize: 16, color: secondaryText),),
                            ),
                            const Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.pages, color: colorPrimary,),
                            ),
                          ],
                        ),
                        onPressed: () => LaunchReview.launch()
                    ),
                  ],
                ),
              ),
            ),
          ),
          TopBarButton(
            padding: buttonPadding,
            iconData: Icons.info,
            text: "Legal information",
            onPressed: () => showDialog(
              context: context,
              builder: (context) => MaterialDialog(
                useMaterialButtonDesign: false,
                headerText: "Thrift application",
                confirmButtonCallback: () => Navigator.pop(context),
                confirmButtonText: "Close",
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: const Text("Dark and Jeweled built Thrift as Commercial app. Do not hesitate to contact us if you have any questions about our Privacy Policy.", style: const TextStyle(color: secondaryText, fontSize: 16), ),
                    ),
                    RawMaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Text("Licenses", style: const TextStyle(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 16),),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.receipt, color: colorPrimary,),
                          )
                        ],
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pushNamed(context, route_Licences);
                      },
                    ),
                    RawMaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Text("Terms & conditions", style: const TextStyle(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 16),),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.library_books, color: colorPrimary,),
                          )
                        ],
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pushNamed(context, route_TermsAndConditions);
                      },
                    ),
                    RawMaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Text("Privacy policy", style: const TextStyle(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 16),),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.bookmark, color: colorPrimary,),
                          )
                        ],
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pushNamed(context, route_PrivacyPolicy);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackdropHeader extends StatelessWidget  {
  final String fragmentName;
  BackdropHeader({@required this.fragmentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: backdropHeaderSize,
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: const Radius.circular(panelRadius)),
        color: white,
      ),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 24,),
            child: Center(
              child: Text(fragmentName, style: const TextStyle(color: secondaryText, fontSize: 16),),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: backdropOpenNotifier,
            builder: (context, value, child){
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 24,),
                child: value?const Icon(Icons.keyboard_arrow_down, color: chipIconColor,):const Icon(Icons.keyboard_arrow_up, color: chipIconColor,),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FrontLayer extends StatelessWidget{
  static const Duration crossFadeDuration = Duration(milliseconds: 150);

  final ValueKey<int> valueKey;
  final Widget fragment;
  FrontLayer({@required this.valueKey, @required this.fragment});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: crossFadeDuration,
      child: Container(
        key: valueKey,
        color: white,
        child: fragment
      ),
    );
  }
}