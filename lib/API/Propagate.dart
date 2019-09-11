import 'package:flutter/material.dart';

import 'package:thrift/Instances/Routes.dart';

import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/Widgets/Reusable UI components/ExceptionStatement.dart';

/*
class Propagate extends StatelessWidget{
  final Widget child;
  Propagate({@required this.child});
  @override
  Widget build(BuildContext context) {
    return
    return ValueListenableBuilder<bool>(
      valueListenable: subscribedNotifier,
      builder: (context, subscribed, child){
        if(subscribed!=null){
          if(subscribed){
            return ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: authDataNotifier,
              builder: (context, authData, child) {
                if(authData!=null){
                  return child;
                } else {
                  return ExceptionStatement(
                    errorMessage: "Connect to the Thrift Cloud",
                    description: "You are not authenticated. Please log in to the Cloud or register a new account.",
                    solution: MaterialButton(
                      color: colorPrimary,
                      textColor: white,
                      shape: const StadiumBorder(),
                      onPressed: (){
                        Navigator.pushNamed(context, route_Login);
                      },
                      child: const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text("Let me log in", style: const TextStyle(fontSize: 16),),
                      ),
                    ),
                    iconData: Icons.message,
                  );
                }
              },
            );
          } else {
            return ExceptionStatement(
              errorMessage: "You are not subscribed",
              description: "Become a Premium user to unlock all the features of Thrift",
              solution: MaterialButton(
                color: colorPrimary,
                textColor: white,
                shape: const StadiumBorder(),
                onPressed: (){
                  Navigator.pushNamed(context, route_Subscribe);
                },
                child: const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text("What's this about?", style: const TextStyle(fontSize: 16),),
                ),
              ),
              iconData: Icons.message,
            );
          }
        } else {
          return ExceptionStatement(
            errorMessage: "No connection to Store",
            description: "Check your internet connection and VPN settings",
            iconData: Icons.announcement,
          );
        }
      },
    );
  }
} */