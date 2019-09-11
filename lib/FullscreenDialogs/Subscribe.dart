import 'package:flutter/material.dart';
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:thrift/Instances/Device.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/API/Transmit.dart';

import 'package:thrift/Widgets/Reusable UI components/ExceptionStatement.dart';

class Subscribe extends StatefulWidget{
  SubscribeState createState() => SubscribeState();
}

class SubscribeState extends State<Subscribe>{
  StreamSubscription<List<PurchaseDetails>> storefrontStream;
  ValueNotifier<ProductDetails> subscriptionDetailsNotifier;

  @override
  void initState() {
    storefrontStream = InAppPurchaseConnection.instance.purchaseUpdatedStream.listen((List<PurchaseDetails> purchases) {
      purchases.forEach((PurchaseDetails details){
        if(details.productID == product_ID && details.status == PurchaseStatus.purchased){
          if(device.platform == Device.platform_IOS) {
            InAppPurchaseConnection.instance.completePurchase(details);
          }
          checkSubscription();
        }
      });
    });
    subscriptionDetailsNotifier = ValueNotifier(null);
    super.initState();
  }

  @override
  void dispose(){
    storefrontStream.cancel();
    subscriptionDetailsNotifier.dispose();
    super.dispose();
  }

  Future<void> getSubscriptionDetails() async {
    final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(<String>[product_ID].toSet());
    if(response.notFoundIDs.isEmpty){
      response.productDetails.forEach((ProductDetails details){
        if(details.id == product_ID){
          subscriptionDetailsNotifier.value = details;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(subscriptionDetailsNotifier.value == null){
      getSubscriptionDetails();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: const Text("Thrift Premium", style: const TextStyle(color: primaryText),),
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryText,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: authDataNotifier,
        builder: (context, authData, child){
          if(authData.subscribed!=null){
            if(authData.subscribed){
              return ExceptionStatement(
                errorMessage: "Subscribed to Premium",
                description: "You have successfully subscribed to Thrift Premium! Enjoy all the unlocked features!",
                iconData: Icons.business_center,
                iconColor: colorPrimary,
                solution: MaterialButton(
                  color: colorPrimary,
                  textColor: white,
                  shape: StadiumBorder(),
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("Straight to business!", style: const TextStyle(fontSize: 16),),
                  ),
                ),
              );
            } else {
              return Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        FeatureItem(
                          iconData: Icons.donut_large,
                          label: "Thrift Premium",
                          description: "Get used to ultimate Thrift experience with all features enabled",
                        ),
                        FeatureItem(
                          iconData: Icons.multiline_chart,
                          label: "Infographics",
                          description: "Try new ways to analyze your budget and review your budget history",
                        ),
                        FeatureItem(
                          iconData: Icons.cloud_upload,
                          label: "Cloud storage",
                          description: "Save your data to our servers and access it from any of your devices",
                        ),
                        FeatureItem(
                          iconData: Icons.supervisor_account,
                          label: "Household budget",
                          description: "Sync with all the devices in your family. Note, hovewer, that every family member using a household account must be subscribed to Thrift Premium",
                        ),
                        FeatureItem(
                          iconData: Icons.fingerprint,
                          label: "Security",
                          description: "Advanced data encrypion, passcode and fingerprint protection",
                        ),
                        FeatureItem(
                          iconData: Icons.loyalty,
                          label: "Trial",
                          description: "Try for free with 3-days trial period, and get a discount for the first month",
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<ProductDetails>(
                    valueListenable: subscriptionDetailsNotifier,
                    builder: (context, details, child){
                      return Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          divider,
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: RawMaterialButton(
                              fillColor: colorPrimary,
                              child: Container(
                                width: 280,
                                height: 48,
                                child: Center(
                                  child: Text("Subscribe now", style: const TextStyle(fontSize: 18, color: white),),
                                ),
                              ),
                              splashColor: colorPrimary,
                              onPressed: details!=null?() async {
                                InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: details));
                              }:null,
                            ),
                          ),
                          details != null
                              ?
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            child: Text("Price after introductory: ${details.price}", style: const TextStyle(fontSize: 16, color: secondaryText), ),
                          )
                              :
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }
          } else {
            return Stack(
              children: <Widget>[
                Positioned(
                  bottom: 16,
                  left: 0, right: 0,
                  child: Center(
                    child: FutureBuilder(
                      future: checkSubscription(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                          return Container();
                        } else {
                          return Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Trying again..", style: const TextStyle(color: secondaryText, fontSize: 16),),
                              CircularProgressIndicator(),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                ExceptionStatement(
                  errorMessage: "No connection to Store",
                  description: "Check your internet connection and VPN settings",
                  iconData: Icons.announcement,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class FeatureItem extends StatelessWidget{
  final IconData iconData;
  final String label;
  final String description;
  FeatureItem({@required this.iconData, @required this.label, @required this.description});
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(iconData, color: colorPrimary, size: 40,),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, right: 24),
            child: Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: const TextStyle(fontSize: 16, color: primaryText), maxLines: 1, overflow: TextOverflow.ellipsis,),
                Text(description, style: const TextStyle(fontSize: 16, color: secondaryText)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}