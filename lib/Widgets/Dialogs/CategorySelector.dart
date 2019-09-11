import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

import 'package:thrift/Widgets/Category.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';

class CategorySelector extends StatelessWidget{
  final ValueNotifier<TransactionCategory> categoryNotifier;
  final List<TransactionCategory> categories;
  CategorySelector({@required this.categoryNotifier, @required this.categories});

  @override
  Widget build(BuildContext context) {
    List<Category> expenseChildren = [];
    List<Category> incomeChildren = [];
    categories.forEach((trc){
      double sum = 0;
      currentDataPickNotifier.value.transactions.forEach((trn){
        if(trn.trcID == trc.trcID){sum+=trn.value;}
      });
      Category category = Category(
        sum: sum,
        trc: trc,
        onTap: (){categoryNotifier.value=trc; Navigator.pop(context);},
        overrideCost: trc.drawableID == -1 ? 0 : null,
        overrideLabel: trc.drawableID == -1 ? trc.trcID<12? "Expense" : "Income" : null,
      );
      if(trc.trcID<12){
        expenseChildren.add(category);
      } else {
        incomeChildren.add(category);
      }
    });
    incomeChildren.sort((Category catA, Category catB) => catA.trc.drawableID == -1? 1 : catB.trc.drawableID == -1 ? -1 : catA.sum!=catB.sum?(catB.sum - catA.sum).toInt():catB.trc.trcID-catA.trc.trcID);
    expenseChildren.sort((Category catA, Category catB) => catA.trc.drawableID == -1? 1 : catB.trc.drawableID == -1 ? -1 : catA.sum!=catB.sum?(catB.sum - catA.sum).toInt():catB.trc.trcID-catA.trc.trcID);
    List<Widget> slivers = [];
    if(expenseChildren.isNotEmpty){
      slivers.add(SliverList(delegate: SliverChildListDelegate([
        const Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Text("Expense categories", style: const TextStyle(color: secondaryText, fontSize: 16),),
        ),
      ])));
      slivers.add(SliverGrid.count(
        childAspectRatio: 80/80,
        mainAxisSpacing: 8,
        crossAxisCount: 3,
        children: expenseChildren,
      ));
    }
    if(incomeChildren.isNotEmpty){
      slivers.add(SliverList(delegate: SliverChildListDelegate([
        const Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Text("Income categories", style: const TextStyle(color: secondaryText, fontSize: 16),),
        ),
      ])));
      slivers.add(SliverGrid.count(
        childAspectRatio: 80/80,
        mainAxisSpacing: 8,
        crossAxisCount: 3,
        children: incomeChildren,
      ));
    }
    return MaterialDialog(
      headerText: "Select category",
      confirmButtonCallback: () => Navigator.pop(context),
      confirmButtonText: "Cancel",
      child: Container(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: slivers,
          ),
        ),
      ),
    );
  }
}