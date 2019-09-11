import 'package:flutter/material.dart';
import 'package:thrift/Instances/Theme.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Color color;
  const EmptyAppBar({this.color = colorPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(color: color,);
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);

}