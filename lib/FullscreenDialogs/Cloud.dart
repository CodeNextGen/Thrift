import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';


class Cloud extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: const Text("Thrift Cloud", style: const TextStyle(color: primaryText),),
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryText,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: const Text("WIP")),
    );
  }
}