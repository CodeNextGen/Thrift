import 'package:flutter/material.dart';
import 'package:thrift/API/Transmit.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/Routes.dart';
import 'package:thrift/Instances/Notifiers/backdropOpen.dart';
import 'package:thrift/Instances/DataPick.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget{

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight);
  }

  static const double elevation = 0;
  static const bool softWrap = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrentDataPick>(
      valueListenable: currentDataPickNotifier,
      builder: (context, currentDataPick, child){
        return AppBar(
          elevation: elevation,
          leading: IconButton(
            splashColor: colorPrimary,
            highlightColor: colorPrimary,
            icon: const Icon(Icons.menu, color: white),
            onPressed: (){
              backdropOpenNotifier.value=!backdropOpenNotifier.value;
            },
          ),
          title: Text(currentDataPick.account.name, overflow: TextOverflow.ellipsis, softWrap: softWrap,),
          actions: <Widget>[
            ValueListenableBuilder<AuthData>(
              valueListenable: authDataNotifier,
              builder: (context, authData, child){
                return ValueListenableBuilder<int>(
                  valueListenable: syncNotifier,
                  builder: (context, sync, child){
                    return IconButton(
                      splashColor: colorPrimary,
                      highlightColor: colorPrimary,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          authData.subscribed != null && authData.subscribed && authData.signature != null ? sync == sync_synchronized ? Icons.cloud_done : Icons.cloud_upload : Icons.cloud,
                          key: ValueKey<int>(authData.subscribed != null && authData.subscribed && authData.signature != null ? 0 : sync),
                          color: white,
                        ),
                      ),
                      onPressed: () => Navigator.pushNamed(context, route_Cloud),
                    );
                  },
                );
              },
            ),
            IconButton(
              splashColor: colorPrimary,
              highlightColor: colorPrimary,
              onPressed: () => Navigator.pushNamed(context, route_AccountManager),
              icon: const Icon(Icons.account_balance, color: white),
            ),
          ],
        );
      },
    );
  }
}