import 'package:flutter/material.dart';

import 'package:thrift/Instances/Routes.dart';
import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/Functions/generateSumString.dart';

import 'package:thrift/Models/Arguments.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

class Category extends StatelessWidget{
  final double sum;
  final TransactionCategory trc;
  final GestureTapCallback onTap;
  final Size givenSize;
  final String overrideLabel;
  final double overrideCost;

  Category({@required this.sum, @required this.trc, this.onTap, Size givenSize, this.overrideCost, this.overrideLabel}):
      this.givenSize = givenSize ?? defaultGivenSize;

  static const Size defaultGivenSize = Size(86, 80);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? (){
        if(trc.drawableID!=-1) {
          Navigator.pushNamed(context, route_TransactionManager, arguments: Arguments(transactionCategory: trc));
        } else {
          Navigator.pushNamed(context, route_CategoryManager, arguments: Arguments(transactionCategory: trc));
        }
      },
      onLongPress: onTap ?? () => Navigator.pushNamed(context, route_CategoryManager, arguments: Arguments(transactionCategory: trc)),
      child: SizedBox.fromSize(
        size: givenSize,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(overrideLabel??(trc.drawableID!=-1?trc.label:""), style: const TextStyle(color: primaryText, fontSize: 14), overflow: TextOverflow.ellipsis, softWrap: false),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constrains){
                    return CategoryIconWithHalo(
                      haloSize: constrains.maxWidth,
                      drawableID: trc.drawableID,
                      colorID: trc.colorID,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(overrideCost!=null? generateSumString(overrideCost.toInt(), true) : trc.drawableID!=-1?generateSumString(sum.toInt(), true) : "", style: const TextStyle(color: secondaryText, fontSize: 14), overflow: TextOverflow.ellipsis, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryIconWithHalo extends StatelessWidget{
  static const Color addIconColor = Color(0xffeceff1);
  static const double iconRatio = 0.44;

  final int drawableID;
  final int colorID;
  final double haloSize;

  CategoryIconWithHalo({@required this.drawableID, @required this.colorID, @required this.haloSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: haloSize,
      height: haloSize,
      child: Center(
        child: CategoryIcon(drawableID: drawableID, iconSize: haloSize*iconRatio),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorID!=-1?halos.elementAt(colorID):addIconColor,
      ),
    );
  }

  static const List<Color> halos = const <Color>[
    //Material colors 400-800 of: (12)
    //Red, pink, purple, blue, cyan, teal,
    //Green, lime, amber, orange, brown, grey.

    //400
    const Color(0xFFef5350),
    const Color(0xFFec407a),
    const Color(0xFFab47bc),
    const Color(0xFF42a5f5),
    const Color(0xFF26c6da),
    const Color(0xFF26a69a),
    const Color(0xFF66bb6a),
    const Color(0xFFd4e157),
    const Color(0xFFffca28),
    const Color(0xFFffa726),
    const Color(0xFF8d6e63),
    const Color(0xFFbdbdbd),
    //500
    const Color(0xFFf44336),
    const Color(0xFFe91e63),
    const Color(0xFF9c27b0),
    const Color(0xFF2196f3),
    const Color(0xFF00bcd4),
    const Color(0xFF009688),
    const Color(0xFF4caf50),
    const Color(0xFFcddc39),
    const Color(0xFFffc107),
    const Color(0xFFff9800),
    const Color(0xFF795548),
    const Color(0xFF9e9e9e),
    //600
    const Color(0xFFe53935),
    const Color(0xFFd81b60),
    const Color(0xFF8e24aa),
    const Color(0xFF1e88e5),
    const Color(0xFF00acc1),
    const Color(0xFF00897b),
    const Color(0xFF43a047),
    const Color(0xFFc0ca33),
    const Color(0xFFffb300),
    const Color(0xFFfb8c00),
    const Color(0xFF6d4c41),
    const Color(0xFF757575),
    //700
    const Color(0xFFd32f2f),
    const Color(0xFFc2185b),
    const Color(0xFF7b1fa2),
    const Color(0xFF1976d2),
    const Color(0xFF0097a7),
    const Color(0xFF00796b),
    const Color(0xFF388e3c),
    const Color(0xFFafb42b),
    const Color(0xFFffa000),
    const Color(0xFFf57c00),
    const Color(0xFF5d4037),
    const Color(0xFF616161),
    //800
    const Color(0xFFc62828),
    const Color(0xFFad1457),
    const Color(0xFF6a1b9a),
    const Color(0xFF1565c0),
    const Color(0xFF00838f),
    const Color(0xFF00695c),
    const Color(0xFF2e7d32),
    const Color(0xFF9e9d24),
    const Color(0xFFff8f00),
    const Color(0xFFef6c00),
    const Color(0xFF4e342e),
    const Color(0xFF424242),
  ];
}

class CategoryIcon extends StatelessWidget{
  final int drawableID;
  final double iconSize;

  CategoryIcon({@required this.drawableID, @required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Icon(drawableID!=-1? drawables[drawableID]: Icons.add, size: iconSize, color: white,);
  }

  static const String trcIconsFamily = "trc-icons";
  static const List<IconData> drawables = const <IconData>[
    const IconData(0xe81b, fontFamily: trcIconsFamily), //kin, 0
    const IconData(0xe806, fontFamily: trcIconsFamily), //restaurant, 1
    const IconData(0xe80e, fontFamily: trcIconsFamily), //apparel, 2
    const IconData(0xe81c, fontFamily: trcIconsFamily), //leisure, 3
    const IconData(0xe80c, fontFamily: trcIconsFamily), //transport, 4
    const IconData(0xe817, fontFamily: trcIconsFamily), //groceries, 5
    const IconData(0xe818, fontFamily: trcIconsFamily), //health, 6
    const IconData(0xe809, fontFamily: trcIconsFamily), //seldom, 7
    const IconData(0xe811, fontFamily: trcIconsFamily), //bill, 8
    const IconData(0xe81d, fontFamily: trcIconsFamily), //major, 9
    const IconData(0xe808, fontFamily: trcIconsFamily), //salary, 10
    const IconData(0xe80a, fontFamily: trcIconsFamily), //seldom2, 11
    const IconData(0xe805, fontFamily: trcIconsFamily), //rental, 12
    const IconData(0xe814, fontFamily: trcIconsFamily), //dividend, 13
    const IconData(0xe800, fontFamily: trcIconsFamily), //marketing, 14
    const IconData(0xe813, fontFamily: trcIconsFamily), //contracts, 15
    const IconData(0xe80d, fontFamily: trcIconsFamily), //utilities, 16
    const IconData(0xe810, fontFamily: trcIconsFamily), //benefits, 17
    const IconData(0xe81a, fontFamily: trcIconsFamily), //insurance, 18
    const IconData(0xe816, fontFamily: trcIconsFamily), //gains, 19
    const IconData(0xe807, fontFamily: trcIconsFamily), //revenue, 20
    const IconData(0xe812, fontFamily: trcIconsFamily), //boat, 21
    const IconData(0xe804, fontFamily: trcIconsFamily), //plane, 22
    const IconData(0xe80b, fontFamily: trcIconsFamily), //store, 23
    const IconData(0xe803, fontFamily: trcIconsFamily), //pizza, 24
    const IconData(0xe802, fontFamily: trcIconsFamily), //pie chart, 25
    const IconData(0xe801, fontFamily: trcIconsFamily), //pharmacy, 26
    const IconData(0xe819, fontFamily: trcIconsFamily), //hotel, 27
    const IconData(0xe815, fontFamily: trcIconsFamily), //dumbbell, 28,
    const IconData(0xe80f, fontFamily: trcIconsFamily), //baby stroller, 29
  ];
}