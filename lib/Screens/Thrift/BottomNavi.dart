import 'package:flutter/material.dart';

import 'package:thrift/Instances/Notifiers/fragmentID.dart';
import 'package:thrift/Instances/Notifiers/backdropOpen.dart';

class BottomNavi extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: fragmentIDNotifier,
      builder: (context, value, child){
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: value,
          fixedColor: Colors.deepPurpleAccent,
          items: const <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: const Icon(Icons.event_note),
              title: const Text("Agenda"),
            ),
            const BottomNavigationBarItem(
              icon: const Icon(Icons.donut_large),
              title: const Text("Chart"),
            ),
            const BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
            ),
            const BottomNavigationBarItem(
              icon: const Icon(Icons.receipt),
              title: const Text("History"),
            ),
          ],
          onTap: (index){
            fragmentIDNotifier.value=index;
            backdropOpenNotifier.value=true;
          },
        );
      },
    );
  }
}