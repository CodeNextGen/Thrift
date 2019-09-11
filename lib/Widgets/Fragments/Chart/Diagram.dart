import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/Widgets/Category.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

class Diagram extends CustomPainter{
  static const int skipAngle=6;
  static const int fullRotation = 360;

  int fullAngle;
  final List<TransactionCategory> transactionCategories;
  final List<double> sums;
  final int idBuf;
  List<Percentile> percents;
  double startAngle = -3;
  Diagram({@required this.transactionCategories, @required this.sums, @required this.idBuf});

  Paint brush = Paint()
    ..strokeWidth = 0
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size){
    recalculatePercentile();
    percents.forEach((prc) => arc(size, canvas, prc,));

    Paint paint = Paint()..strokeWidth=0..style=PaintingStyle.fill..color=white;
    canvas.drawCircle(Offset(size.width/2, size.height/2,), (size.width/64*55)/2, paint,);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void arc(Size size, Canvas canvas, Percentile prc){
    brush.color=prc.color;
    canvas.drawArc(Rect.fromLTRB(0, 0, size.width, size.height,), radians(startAngle), radians(-prc.angle), true, brush);
    startAngle-=prc.angle+skipAngle;
  }

  void recalculatePercentile(){
    bool allTrcAreZero = true;
    transactionCategories.forEach((trc){
      if(sums[trc.trcID-idBuf]!=0){
        allTrcAreZero=false;
      }
    });
    percents = List<Percentile>();
    int nullTRCS=0;
    transactionCategories.forEach((trc){if(sums[trc.trcID-idBuf]==0){nullTRCS+=1;}});
    int nonNullTRCS = (transactionCategories.length - nullTRCS);
    if(nonNullTRCS==1){
      fullAngle = fullRotation;
    } else {
      fullAngle = fullRotation - (transactionCategories.length - nullTRCS) * skipAngle;
    }
    if(allTrcAreZero){
      int size = transactionCategories.length;
      transactionCategories.forEach((trc) => percents.add(Percentile(angle: (fullAngle-transactionCategories.length*skipAngle)/size, color: CategoryIconWithHalo.halos[trc.colorID],),));
    } else {
      double fullAmount = 0;
      transactionCategories.forEach((trc) => fullAmount += sums[trc.trcID-idBuf]);
      transactionCategories.forEach((trc){
        if(sums[trc.trcID-idBuf]!=0){
          percents.add(Percentile(angle: (sums[trc.trcID-idBuf] / fullAmount) * fullAngle,
            color: CategoryIconWithHalo.halos[trc.colorID],));}});
    }
  }
}

class Percentile{
  final double angle;
  final Color color;
  Percentile({@required this.angle, @required this.color});
}
