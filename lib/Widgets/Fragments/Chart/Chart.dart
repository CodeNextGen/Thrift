import 'package:flutter/material.dart';

import 'package:thrift/Functions/generateSumString.dart';

import 'package:thrift/Widgets/Category.dart';
import 'package:thrift/Widgets/Fragments/Chart/Diagram.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

import 'package:thrift/Instances/DataPick.dart';
import 'package:thrift/Instances/Theme.dart';

class Chart extends StatefulWidget{
  ChartState createState() => ChartState();
}

class ChartState extends State<Chart> with SingleTickerProviderStateMixin{
  TabController controller;

  ValueNotifier<bool> isExpenseNotifier;
  @override
  void initState(){
    controller = TabController(length: 2, vsync: this);
    isExpenseNotifier = ValueNotifier(true);
    super.initState();
  }

  @override
  void dispose(){
    controller.dispose();
    isExpenseNotifier.dispose();
    super.dispose();
  }

  int get sum{
    double sum = 0;
    currentDataPickNotifier.value.transactions.forEach((trn){
      if((trn.trcID<12)==isExpenseNotifier.value){
        sum+=trn.value;
      }
    });
    return sum.toInt();
  }

  @override
  Widget build(BuildContext context) {
    //todo precache
    /*
    currentDataPickNotifier.value.categories.forEach((trc){
      precacheImage(AssetImage(drawables[trc.drawableID]), context);
    });
    */
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constrains){
          return ValueListenableBuilder<bool>(
            valueListenable: isExpenseNotifier,
            builder: (context, isExpense, child){
              return ValueListenableBuilder<CurrentDataPick>(
                valueListenable: currentDataPickNotifier,
                builder: (context, currentDataPick, child){
                  List<TransactionCategory> interestedCategories = currentDataPick.categories.where((trc) {
                    return (trc.trcID<12 && isExpense) || (trc.trcID>=12 && !isExpense);
                  }).toList();
                  int idBuf = isExpense?0:12;
                  List<double> sums = List(12);
                  for(int i=0; i<12; i++){
                    sums[i] = 0;
                  }
                  currentDataPick.transactions.forEach((trn){
                    if(trn.trcID<12 == isExpense) {
                      sums[trn.trcID - idBuf] += trn.value;
                    }
                  });
                  double verticalSize = constrains.maxHeight>520?92:(constrains.maxHeight>420?86:(constrains.maxHeight-24)/4);
                  Size categorySize = Size(constrains.maxWidth/4, verticalSize);
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: categorySize.width,
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CategoryBuilder(4+idBuf, sums[4], size: categorySize,),
                            CategoryBuilder(5+idBuf, sums[5], size: categorySize,),
                            CategoryBuilder(6+idBuf, sums[6], size: categorySize,),
                            CategoryBuilder(7+idBuf, sums[7], size: categorySize,),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: categorySize.width*2,
                              height: categorySize.height,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CategoryBuilder(2+idBuf, sums[2], size: categorySize,),
                                  CategoryBuilder(3+idBuf, sums[3], size: categorySize,),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: GestureDetector(
                                      onTap: ()=>isExpenseNotifier.value=!isExpenseNotifier.value,
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                            top: 0, bottom: 0, right: 0, left: 0,
                                            child: CustomPaint(
                                              painter: Diagram(
                                                transactionCategories: interestedCategories,
                                                sums: sums,
                                                idBuf: idBuf,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Flex(
                                              direction: Axis.vertical,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 2),
                                                  child: Text(isExpense?"Expenses":"Incomes", style: const TextStyle(color: primaryText, fontSize: 16),),
                                                ),
                                                Text(generateSumString(sum, false), style: const TextStyle(color: secondaryText, fontSize: 14),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: categorySize.height,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  CategoryBuilder(8+idBuf, sums[8], size: categorySize,),
                                  CategoryBuilder(9+idBuf, sums[9], size: categorySize,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: categorySize.width,
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CategoryBuilder(1+idBuf, sums[1], size: categorySize,),
                            CategoryBuilder(idBuf, sums[0], size: categorySize,),
                            CategoryBuilder(11+idBuf, sums[11], size: categorySize,),
                            CategoryBuilder(10+idBuf, sums[10], size: categorySize,),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryBuilder extends StatelessWidget{
  final int trcID; final bool isExpense; final Size size;
  final double sum;
  CategoryBuilder(this.trcID, this.sum, {this.size}):this.isExpense=trcID<12;
  @override
  Widget build(BuildContext context) {
    TransactionCategory category = currentDataPickNotifier.value.categories.firstWhere((trc) => trc.trcID == trcID, orElse: () => null);
    return Category(
      sum: sum,
      trc: category??TransactionCategory(accUUID: currentDataPickNotifier.value.account.uuid, trcID: trcID, drawableID: -1, colorID: -1, label: isExpense?"Expense":"Income"),
      givenSize: size,
    );
  }
}