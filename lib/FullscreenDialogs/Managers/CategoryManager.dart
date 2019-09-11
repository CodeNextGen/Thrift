import 'package:flutter/material.dart';

import 'package:thrift/Functions/generateSumString.dart';
import 'package:thrift/Functions/Fetch.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';
import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';
import 'package:thrift/Widgets/Reusable UI components/ScreenLabel.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';
import 'package:thrift/Widgets/Dialogs/ConfirmRequester.dart';
import 'package:thrift/Widgets/Category.dart';

import 'package:thrift/Widgets/Dialogs/CategorySelector.dart';

import 'package:thrift/Widgets/Reusable UI components/AnimatedBackground.dart';

class CategoryManager extends StatefulWidget{
  final TransactionCategory category;
  CategoryManager({@required this.category});
  CategoryManagerState createState() => CategoryManagerState();
}

class CategoryManagerState extends State<CategoryManager>{
  static const String drawableNotSpecified = "Please select an icon";
  static const String colorNotSpecified = "Please select a color";
  static const String labelNotSpecified = "Please select an icon";

  double getSum(TransactionCategory category){
    double sum = 0;
    currentDataPickNotifier.value.transactions.forEach((trn){
      if(trn.trcID == category.trcID){
        sum+=trn.value;
      }
    });
    return sum;
  }

  ValueNotifier<TransactionCategory> replacedCategoryNotifier;

  ValueNotifier<AttributeSet> attributeSetNotifier;

  ValueNotifier<String> errorNotifier;

  FocusNode focusNode;
  TextEditingController textEditingController;

  ValueNotifier<int> colorIDNotifier;
  ValueNotifier<int> drawableIDNotifier;


  @override
  void initState() {
    replacedCategoryNotifier = ValueNotifier(widget.category);
    replacedCategoryNotifier.addListener((){
      attributeSetNotifier.value = AttributeSet(
        label: replacedCategoryNotifier.value.drawableID == -1 || replacedCategoryNotifier.value.label=="Expense" || replacedCategoryNotifier.value.label=="Income" ? "" : replacedCategoryNotifier.value.label,
        sum: getSum(replacedCategoryNotifier.value),
        colorID: replacedCategoryNotifier.value.colorID,
        drawableID: replacedCategoryNotifier.value.drawableID,
        save: replacedCategoryNotifier.value.drawableID==-1 || getSum(replacedCategoryNotifier.value) == 0?null:true,
      );
    });

    attributeSetNotifier = ValueNotifier(
      AttributeSet(
        label: replacedCategoryNotifier.value.drawableID!=-1? widget.category.label:"",
        sum: getSum(replacedCategoryNotifier.value),
        colorID: widget.category.colorID,
        drawableID: widget.category.drawableID,
        save: replacedCategoryNotifier.value.drawableID==-1 || getSum(replacedCategoryNotifier.value) == 0?null:true,
      ),
    );

    errorNotifier = ValueNotifier(null);
    textEditingController = TextEditingController();

    focusNode = FocusNode();

    drawableIDNotifier = ValueNotifier(attributeSetNotifier.value.drawableID);
    drawableIDNotifier.addListener((){
      attributeSetNotifier.value = AttributeSet(
        label: attributeSetNotifier.value.label,
        sum: attributeSetNotifier.value.sum,
        colorID: attributeSetNotifier.value.colorID,
        drawableID: drawableIDNotifier.value,
        save: attributeSetNotifier.value.save,
      );
    });
    colorIDNotifier = ValueNotifier(attributeSetNotifier.value.colorID);
    colorIDNotifier.addListener((){
      attributeSetNotifier.value = AttributeSet(
        label: attributeSetNotifier.value.label,
        sum: attributeSetNotifier.value.sum,
        colorID: colorIDNotifier.value,
        drawableID: attributeSetNotifier.value.drawableID,
        save: attributeSetNotifier.value.save,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    replacedCategoryNotifier.dispose();

    textEditingController.dispose();

    drawableIDNotifier.dispose();
    colorIDNotifier.dispose();

    attributeSetNotifier.dispose();

    errorNotifier.dispose();

    focusNode.dispose();
    super.dispose();
  }

  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TransactionCategory>(
      valueListenable: replacedCategoryNotifier,
      builder: (context, category, child){
        return ValueListenableBuilder<AttributeSet>(
          valueListenable: attributeSetNotifier,
          builder: (context, value, child){
            return AnimatedBackground(
              onKeyboardClosed: (){
                focusNode.unfocus();
                if(formKey.currentState.validate()){
                  formKey.currentState.save();
                }
              },
              topBarButtons: <TopBarButton>[
                TopBarButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context) {
                        List<TransactionCategory> selectList = List.from(currentDataPickNotifier.value.categories);

                        for(int i=0; i<12; i++){
                          TransactionCategory emptyExpenseTrc = selectList.firstWhere((trc){return trc.trcID == i;}, orElse: () => null);
                          if(emptyExpenseTrc!=null){
                            selectList.add(TransactionCategory(accUUID: currentDataPickNotifier.value.account.uuid, trcID: i, drawableID: -1, colorID: -1, label: "Expense"));
                            break;
                          }
                        }

                        for(int i=12; i<24; i++){
                          TransactionCategory emptyIncomeTrc = selectList.firstWhere((trc){return trc.trcID == i;}, orElse: () => null);
                          if(emptyIncomeTrc==null){
                            selectList.add(TransactionCategory(accUUID: currentDataPickNotifier.value.account.uuid, trcID: i, drawableID: -1, colorID: -1, label: "Income"));
                            break;
                          }
                        }

                        return CategorySelector(
                          categoryNotifier: replacedCategoryNotifier,
                          categories: selectList,
                        );
                      },
                    );
                  },
                  iconData: Icons.label_important,
                  text: category.drawableID==-1 ? "Creating new (${category.trcID<12?"Expense":"Income"})" : "Replacing ${category.label}",
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 8),
                ),
                TopBarButton(
                  onPressed: (){
                    attributeSetNotifier.value.save !=null && attributeSetNotifier.value.save ?
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ConfirmRequester(question: "Are you sure you want to remove ALL transactions (including agenda) related to this category? This will only take effect when you confirm category changes.", confirmButtonText: "Remove", cancelButtonText: "Cancel", onConfirm: (){
                            attributeSetNotifier.value = AttributeSet(
                              label: attributeSetNotifier.value.label,
                              sum: attributeSetNotifier.value.save!=null?!attributeSetNotifier.value.save?getSum(replacedCategoryNotifier.value):0:getSum(replacedCategoryNotifier.value),
                              colorID: attributeSetNotifier.value.colorID,
                              drawableID: attributeSetNotifier.value.drawableID,
                              save: attributeSetNotifier.value.save!=null?!attributeSetNotifier.value.save:attributeSetNotifier.value.save,
                            );
                            Navigator.pop(context);
                          },
                          ),
                    )
                        :
                    attributeSetNotifier.value = AttributeSet(
                      label: attributeSetNotifier.value.label,
                      sum: attributeSetNotifier.value.save!=null?!attributeSetNotifier.value.save?getSum(replacedCategoryNotifier.value):0:getSum(replacedCategoryNotifier.value),
                      colorID: attributeSetNotifier.value.colorID,
                      drawableID: attributeSetNotifier.value.drawableID,
                      save: attributeSetNotifier.value.save!=null?!attributeSetNotifier.value.save:attributeSetNotifier.value.save,
                    );
                  },
                  iconData: attributeSetNotifier.value.save!=null?attributeSetNotifier.value.save?Icons.save:Icons.delete_sweep:Icons.autorenew,
                  text: attributeSetNotifier.value.save!=null?attributeSetNotifier.value.save?"Keeping transactions":"Removing transactions":"No transactions to save",
                  padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 16),
                ),
              ],
              child: Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ScreenLabel(label: "Manage categories"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        IconButton(
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
                                          child: const Icon(Icons.category, color: colorPrimaryDark,),
                                        ),
                                        const Expanded(
                                          child: const Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: const Text("Specify a category to be replaced with new input;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: const <Widget>[
                                        const Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: const Icon(Icons.save, color: colorPrimaryDark,),
                                        ),
                                        const Expanded(
                                          child: const Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: const Text("Specify whether to keep or remove transactions of replaced category;", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
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
                                          child: const Icon(Icons.edit, color: colorPrimaryDark,),
                                        ),
                                        const Expanded(
                                          child: const Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: const Text("Set up any preferred configuration fo the category. Don't enter a long label - your screen has limited size, one conprehensible word should suffice.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              onEditingComplete: () => focusNode.unfocus(),
                              focusNode: focusNode,
                              decoration: const InputDecoration(labelText: "Label",),
                              controller: textEditingController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (str) => str.isNotEmpty?null:"Please enter a valid label",
                              onSaved: (str){
                                textEditingController.text = "";
                                attributeSetNotifier.value = AttributeSet(
                                  sum: attributeSetNotifier.value.sum,
                                  colorID: attributeSetNotifier.value.colorID,
                                  label: str,
                                  drawableID: attributeSetNotifier.value.drawableID,
                                  save: attributeSetNotifier.value.save,
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: colorPrimary,),
                          onPressed: (){
                            if(formKey.currentState.validate()){
                              formKey.currentState.save();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: ValueListenableBuilder<AttributeSet>(
                              valueListenable: attributeSetNotifier,
                              builder: (context, attributeSet, child){
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Flex(
                                        direction: Axis.vertical,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(attributeSet.label.isEmpty?"New (${replacedCategoryNotifier.value.trcID<12?"expense":"income"})":attributeSet.label, style: const TextStyle(color: primaryText, fontSize: 14),),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: CategoryIconWithHalo(drawableID: attributeSet.drawableID, colorID: attributeSet.colorID, haloSize: 48,), //ToDo use saved defaults. in fact, add category size as a property in Device
                                          ),
                                          Text(generateSumString(attributeSet.sum.toInt(), true), style: const TextStyle(color: secondaryText, fontSize: 14),),
                                        ],
                                      ),
                                    ),
                                    Flex(
                                      direction: Axis.vertical,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          height: 40,
                                          child: RawMaterialButton(
                                            shape: const StadiumBorder(),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) => AssetSelectorDialog(idNotifier: drawableIDNotifier, type: AssetSelectorDialog.type_ICONS,),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Flex(
                                                direction: Axis.horizontal,
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const <Widget>[
                                                  const Icon(Icons.image, color: colorPrimary,),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                                    child: const Text("Image", style: const TextStyle(color: colorPrimary, fontSize: 18, fontWeight: FontWeight.w500),),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 40,
                                          child: RawMaterialButton(
                                            shape: const StadiumBorder(),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) => AssetSelectorDialog(idNotifier: colorIDNotifier, type: AssetSelectorDialog.type_COLORS,),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Flex(
                                                direction: Axis.horizontal,
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const <Widget>[
                                                  const Icon(Icons.palette, color: colorPrimary,),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                                    child: const Text("Color", style: const TextStyle(color: colorPrimary, fontSize: 18, fontWeight: FontWeight.w500),),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: ValueListenableBuilder(
                              valueListenable: replacedCategoryNotifier,
                              builder: (context, replacedCategory, child){
                                return replacedCategoryNotifier.value.drawableID!=-1?Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Container(
                                    height: 40,
                                    child: RawMaterialButton(
                                      shape: const StadiumBorder(),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => ConfirmRequester(
                                          cancelButtonText: "Cancel",
                                          confirmButtonText: "Delete",
                                          question: "Are you sure you want to delete this category? This will also remove ALL transactions (including agenda) related to this category.",
                                          onConfirm: (){
                                            act(replacedCategoryNotifier.value, action_DELETE);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const <Widget>[
                                            const Icon(Icons.delete_forever, color: colorPrimary,),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: const Text("Delete", style: const TextStyle(color: colorPrimary, fontSize: 18, fontWeight: FontWeight.w500),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ):Container();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              errorNotifier: errorNotifier,
              onConfirmed: (){
                if(attributeSetNotifier.value.label!=null && attributeSetNotifier.value.label.isNotEmpty) {
                  if(attributeSetNotifier.value.drawableID!=-1) {
                    if(attributeSetNotifier.value.colorID!=null) {
                      act(
                        TransactionCategory(
                          accUUID: currentDataPickNotifier.value.account.uuid,
                          uuid: replacedCategoryNotifier.value.drawableID == -1 ? null : replacedCategoryNotifier.value.uuid,
                          trcID: replacedCategoryNotifier.value.trcID,
                          drawableID: attributeSetNotifier.value.drawableID,
                          colorID: attributeSetNotifier.value.colorID,
                          label: attributeSetNotifier.value.label,
                        ),
                        replacedCategoryNotifier.value.drawableID == -1
                            ? action_INSERT
                            : action_UPDATE,
                      );
                      if(attributeSetNotifier.value.save!=null && !attributeSetNotifier.value.save){
                        data.deleteContentsOfCategory(replacedCategoryNotifier.value.trcID, replacedCategoryNotifier.value.accUUID);
                        transactions.removeWhere((trn) => trn.accUUID == replacedCategoryNotifier.value.accUUID && trn.trcID == replacedCategoryNotifier.value.trcID);
                        entries.removeWhere((entry) => entry.accUUID == replacedCategoryNotifier.value.accUUID && entry.trcID == replacedCategoryNotifier.value.trcID);
                        setLayout();
                        //todo check
                        /*
                        thriftUnit.regulator.removeTransactionsOfTRC(replacedCategoryNotifier.value.trcID, replacedCategoryNotifier.value.accID);
                        thriftUnit.regulator.removeEntriesOfTRC(replacedCategoryNotifier.value.trcID, replacedCategoryNotifier.value.accID);
                        thriftUnit.allTransactions.removeWhere((trn) => trn.trcID == replacedCategoryNotifier.value.trcID && trn.accID == replacedCategoryNotifier.value.accID);
                        thriftUnit.allEntries.removeWhere((entry) => entry.trcID == replacedCategoryNotifier.value.trcID && entry.accID == replacedCategoryNotifier.value.accID);
                        LayoutData data = LayoutData(
                          transactionCategories: thriftUnit.layoutData.value.transactionCategories,
                          transactions: thriftUnit.layoutData.value.transactions,
                          entries: thriftUnit.layoutData.value.entries,
                          currentAccount: thriftUnit.layoutData.value.currentAccount,
                          currentDateRange: thriftUnit.layoutData.value.currentDateRange,
                        );
                        data.transactions.removeWhere((trn){return trn.trcID==replacedCategoryNotifier.value.trcID;});
                        data.entries.removeWhere((entry){return entry.trcID==replacedCategoryNotifier.value.trcID;});
                        thriftUnit.layoutData.value = data;
                        thriftUnit.updateLayout(null); */
                      }
                      Navigator.pop(context);
                    } else {
                      errorNotifier.value = "Please select color";
                    }
                  } else {
                    errorNotifier.value = "Please select icon";
                  }
                } else {
                  errorNotifier.value = "Please specify label";
                }
              },
            );
          },
        );
      },
    );
  }
}

class AttributeSet{
  final double sum;
  final int colorID;
  final int drawableID;
  final bool save;
  final String label;
  AttributeSet({@required this.sum, @required this.colorID, @required this.label, @required this.drawableID, @required this.save});
  const AttributeSet.empty({this.sum = 0, this.colorID = -1, this.label = "", this.drawableID = -1, this.save});
}

class AssetSelectorDialog extends StatefulWidget{
  static const int type_COLORS = 0;
  static const int type_ICONS = 1;

  final ValueNotifier<int> idNotifier;
  final int type;
  AssetSelectorDialog({@required this.idNotifier, @required this.type});

  AssetSelectorState createState() => AssetSelectorState();
}

class AssetSelectorState extends State<AssetSelectorDialog>{
  static const Color splashColor = Color(0xff81c784);
  static const Color selectedColor = Color(0xff43a047);
  static const Color notSelectedColor = Color(0xffBDBDBD);

  ValueNotifier<int> idSelectedNotifier;

  @override
  void initState() {
    idSelectedNotifier = ValueNotifier(-1);
    super.initState();
  }

  @override
  void dispose() {
    idSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDialog(
      cancelButtonText: "Cancel",
      cancelButtonCallback: () => Navigator.pop(context),
      confirmButtonText: "Save",
      confirmButtonCallback: (){
        if(idSelectedNotifier.value>=0 && idSelectedNotifier.value<CategoryIconWithHalo.halos.length){
          widget.idNotifier.value=idSelectedNotifier.value;
          Navigator.pop(context);
        }
      },
      headerText: widget.type == AssetSelectorDialog.type_COLORS?"Select color":"Select ${widget.type == AssetSelectorDialog.type_COLORS ? "color" : "icon"}",
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 300,
            child: GridView.builder(
              shrinkWrap: false,
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                crossAxisCount: 4,
              ),
              itemCount: widget.type == AssetSelectorDialog.type_COLORS?CategoryIconWithHalo.halos.length:CategoryIcon.drawables.length,
              itemBuilder: (context, index){
                if(widget.type == AssetSelectorDialog .type_COLORS) {
                  return ValueListenableBuilder(
                    valueListenable: idSelectedNotifier,
                    builder: (context, idSelected, child) {
                      return RawMaterialButton(
                        splashColor: colorPrimaryDark,
                        shape: CircleBorder(),
                        fillColor: CategoryIconWithHalo.halos[index],
                        onPressed: () {
                          idSelectedNotifier.value = index;
                        },
                        child: idSelected == index ? Icon(
                          Icons.check, size: 24, color: white,) : Container(),
                      );
                    },
                  );
                } else {
                  return ValueListenableBuilder(
                    valueListenable: idSelectedNotifier,
                    builder: (context, idSelected, child){
                      return RawMaterialButton(
                        splashColor: splashColor,
                        shape: CircleBorder(),
                        fillColor: idSelected==index?selectedColor:notSelectedColor,
                        onPressed: (){idSelectedNotifier.value=index;},
                        child: Icon(CategoryIcon.drawables[index], size: 22, color: white,)
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}