import 'package:flutter/material.dart';

import 'package:thrift/Functions/KeyboardVisibilityNotification.dart';

import 'package:thrift/Functions/Fetch.dart';
import 'package:thrift/Functions/generateSumString.dart';

import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/Arguments.dart';

import 'package:thrift/Widgets/Category.dart';
import 'package:thrift/Widgets/Reusable UI components/SliverHeader.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';
import 'package:thrift/Instances/Routes.dart';

import 'package:thrift/Widgets/Dialogs/ConfirmRequester.dart';

class History extends StatefulWidget{
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History>{
  ScrollController scrollController;
  KeyboardVisibilityNotification keyboardVisibilityNotification;
  void listener(bool keyboardOpen){
    if(!keyboardOpen){
      if(recommendations!=null){recommendations.remove(); recommendations=null;}
      searchNode.unfocus();
    }
  }

  TextEditingController searchController;
  FocusNode searchNode;

  ValueNotifier<String> labelNotifier;
  ValueNotifier<List<TransactionCategory>> categoriesNotifier;

  OverlayEntry recommendations;
  GlobalKey searchKey = GlobalKey();

  ValueNotifier<List<Transaction>> filteredTransactionsNotifier;

  filterTransactions(){
    if(categoriesNotifier.value.isEmpty && labelNotifier.value==null){
      filteredTransactionsNotifier.value = sortTransactions(currentDataPickNotifier.value.transactions);
    } else {
      List<Transaction> filteredTransactions = currentDataPickNotifier.value.transactions;
      if(labelNotifier.value!=null){
        filteredTransactions = filteredTransactions.where((trn){return (trn.label??currentDataPickNotifier.value.categories.firstWhere((trc){return trc.trcID==trn.trcID;}).label).toLowerCase().contains(labelNotifier.value.toLowerCase());}).toList();
      }
      if(categoriesNotifier.value.isNotEmpty){
        filteredTransactions = filteredTransactions.where((trn){
          for(TransactionCategory trc in categoriesNotifier.value){
            if(trc.trcID==trn.trcID){return true;}
          }
          return false;
        }).toList();
      }
      filteredTransactionsNotifier.value = sortTransactions(filteredTransactions);
    }
  }
  List<Transaction> sortTransactions(List<Transaction> transactions){
    return transactions..sort((trn1, trn2) => trn2.calendar.difference(trn1.calendar).inMilliseconds);
  }



  static const double entryItemHeight = 48;
  static const double entryElevation = 4;

  @override
  void initState() {
    scrollController = ScrollController();
    filteredTransactionsNotifier = ValueNotifier(sortTransactions(currentDataPickNotifier.value.transactions));
    currentDataPickNotifier.addListener(filterTransactions);
    labelNotifier = ValueNotifier(null);
    labelNotifier.addListener(filterTransactions);
    categoriesNotifier = ValueNotifier([]);
    categoriesNotifier.addListener(filterTransactions);
    void setRecommendations(){
      if(recommendations!=null){recommendations.remove(); recommendations=null;}
      List<TransactionCategory> recommendedCategories = currentDataPickNotifier.value.categories.where((trc){return trc.label.toLowerCase().startsWith(searchController.text.toLowerCase());}).toList();
      if(recommendedCategories.length>2){recommendedCategories = recommendedCategories.sublist(0, 1);}
      if(searchController.text.length>0){
        RenderBox renderBox = searchKey.currentContext.findRenderObject();
        Offset offset = renderBox.localToGlobal(Offset.zero);
        Size size = renderBox.size;
        recommendations = OverlayEntry(
          builder: (context) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 0,
            width: size.width,
            child: Material(
              elevation: entryElevation,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: recommendedCategories.length+1,
                itemBuilder: (context, index){
                  if(index==0){
                    return Container(
                      height: entryItemHeight,
                      child: RawMaterialButton(
                        onPressed: (){
                          labelNotifier.value = searchController.text;
                          searchController.text="";
                          searchNode.unfocus();
                        },
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(searchController.text, style: const TextStyle(color: primaryText, fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 1,),
                              ),
                            ),
                            const Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Text("(label)", style: TextStyle(color: secondaryText, fontSize: 16),),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: entryItemHeight,
                      child: RawMaterialButton(
                        onPressed: (){
                          List<TransactionCategory> categories = [];
                          categories.addAll(categoriesNotifier.value..add(recommendedCategories[index-1]));
                          categoriesNotifier.value = categories;

                          searchController.text="";
                          searchNode.unfocus();
                        },
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(recommendedCategories[index-1].label, style: const TextStyle(color: primaryText, fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 1,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: CategoryIconWithHalo(drawableID: recommendedCategories[index-1].drawableID, colorID: recommendedCategories[index-1].colorID, haloSize: 36,), //haloSize: 36, iconSize: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
        Overlay.of(context).insert(recommendations);
      }
    }
    searchController = TextEditingController();
    searchNode = FocusNode();
    searchNode.addListener((){
      if(searchNode.hasFocus){
        searchController.addListener(setRecommendations);
      } else {
        searchController.removeListener(setRecommendations);
        if(recommendations!=null){recommendations.remove(); recommendations=null;}
      }
    });
    keyboardVisibilityNotification = KeyboardVisibilityNotification(listener);
    super.initState();
  }

  @override
  void dispose() {
    if(recommendations!=null){recommendations.remove(); recommendations=null;}
    keyboardVisibilityNotification.dispose();
    currentDataPickNotifier.removeListener(filterTransactions);
    scrollController.dispose();
    filteredTransactionsNotifier.dispose();
    labelNotifier.dispose();
    categoriesNotifier.dispose();
    searchNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      shrinkWrap: false,
      scrollDirection: Axis.vertical,
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeader(
            minHeight: 48,
            maxHeight: 112, //64+48
            child: LayoutBuilder(
              builder: (context, constrains){
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    key: ValueKey(constrains.maxHeight==112?1:0),
                    color: white,
                    child: constrains.maxHeight==112?Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(Icons.help, color: colorPrimary,),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => MaterialDialog(
                                    headerText: "Usage tips",
                                    confirmButtonText: "Close",
                                    confirmButtonCallback: () => Navigator.pop(context),
                                    child: Flex(
                                      direction: Axis.vertical,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8, top: 16),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.sort, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("It's possible to sort transactions by their name or their category", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.touch_app, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("Long press any list item to delete it, click to transform or edit", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 64,
                                child: Center(
                                  child: TextField(
                                    controller: searchController,
                                    focusNode: searchNode,
                                    key: searchKey,
                                    onEditingComplete: (){
                                      labelNotifier.value = searchController.text;
                                      searchController.text="";
                                      searchNode.unfocus();
                                    },
                                    decoration: const InputDecoration(
                                      border: const UnderlineInputBorder(
                                        borderRadius: const BorderRadius.all(const Radius.circular(2)),
                                        borderSide: const BorderSide(color: colorPrimary, width: 2),
                                      ),
                                      labelText: "Search for..",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: const Icon(Icons.search, color: colorPrimary,),
                                onPressed: (){
                                  if(searchController.text.isNotEmpty) {
                                    labelNotifier.value = searchController.text;
                                    searchController.text = "";
                                    searchNode.unfocus();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 48,
                          child: ValueListenableBuilder<String>(
                            valueListenable: labelNotifier,
                            builder: (context, label, child){
                              return ValueListenableBuilder<List<TransactionCategory>>(
                                valueListenable: categoriesNotifier,
                                builder: (context, categories, child){
                                  return (label!=null || categories.length>0)?CustomScrollView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: false,
                                    slivers: <Widget>[
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate((context, index){
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Chip(
                                              avatar: CircleAvatar(
                                                backgroundColor: transparent,
                                                child: Icon(
                                                  (index==0 && label!=null) ? Icons.edit : Icons.category,
                                                  color: (index==0 && label!=null) ? chipIconColor: CategoryIconWithHalo.halos[categories[index-(label!=null?1:0)].colorID] ,
                                                  size: 18,
                                                ),
                                              ),
                                              deleteIcon: Icon(Icons.cancel, size: 18,),
                                              deleteIconColor: chipIconColor,
                                              backgroundColor: chipColor,
                                              label: Text((index==0 && label!=null) ? label : categories[index-(label!=null?1:0)].label),
                                              onDeleted: (){
                                                if(index==0 && label!=null){
                                                  labelNotifier.value=null;
                                                } else {
                                                  List<TransactionCategory> categories = [];
                                                  categories.addAll(categoriesNotifier.value..remove(categoriesNotifier.value[index-(label!=null?1:0)]));
                                                  categoriesNotifier.value = categories;
                                                }
                                              },
                                            ),
                                          );
                                        }, childCount: categories.length+(label!=null?1:0)),
                                      ),
                                    ],
                                  ):Center(child: const Text("No search parameters", style: const TextStyle(fontSize: 16, color: secondaryText),),);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ) : Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: ActionChip(
                              avatar: CircleAvatar(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: chipIconColor,
                                  ),
                                  height: 18,
                                  width: 18,
                                  child: const Icon(Icons.arrow_upward, size: 14, color: white,),
                                ),
                                backgroundColor: transparent,
                              ),
                              backgroundColor: chipColor,
                              label: const Text("To search parameters", style: const TextStyle(fontSize: 16, color: primaryText),),
                              onPressed: (){
                                scrollController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.ease);
                              },
                            ),
                          ),
                        ),
                        const Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: divider,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ValueListenableBuilder<List<Transaction>>(
          valueListenable: filteredTransactionsNotifier,
          builder: (context, filteredTransactions, child){
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index){ return HistoryItem(filteredTransactions[index],); },
                childCount: filteredTransactions.length,
              ),
            );
          },
        ),
      ],
    );
  }
}

class HistoryItem extends StatelessWidget{
  final Transaction transaction;
  final TransactionCategory category;
  HistoryItem(Transaction transaction):this.transaction=transaction, this.category = currentDataPickNotifier.value.categories.firstWhere((trc){return transaction.trcID==trc.trcID;});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        showDialog(
          context: context,
          builder: (context) => ConfirmRequester(
            cancelButtonText: "Cancel",
            question: "Are you sure you want to delete selected transaction (${transaction.label??category.label})?",
            confirmButtonText: "Delete",
            onConfirm: (){act(transaction, action_DELETE); Navigator.pop(context);},
          ),
        );
      },
      child: RawMaterialButton(
        splashColor: colorAccent,
        onPressed: (){
          Navigator.pushNamed(context, route_TransactionManager, arguments: Arguments(transactionCategory: category, transaction: transaction,),);
        },
        child: Container(
          height: 56,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: CategoryIconWithHalo(drawableID: category.drawableID, colorID: category.colorID, haloSize: 40,),
                    ),
                    Flexible(
                      child: (transaction.label!=null)?Text(transaction.label, style: const TextStyle(fontSize: 16, color: primaryText), overflow: TextOverflow.ellipsis, softWrap: false,):Text(category.label, style: const TextStyle(fontSize: 16, color: secondaryText), overflow: TextOverflow.ellipsis, softWrap: false,),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text((category.trcID<12?"- ":"")+generateSumString(transaction.value.toInt(), true), style: const TextStyle(color: secondaryText, fontSize: 16),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}