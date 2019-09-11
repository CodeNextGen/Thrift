import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:thrift/Functions/Fetch.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/Entry.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';
import 'package:thrift/Widgets/Reusable UI components/ScreenLabel.dart';

import 'package:thrift/Widgets/Dialogs/CategorySelector.dart';

import 'package:thrift/Widgets/Reusable UI components/AnimatedBackground.dart';

class TransactionManager extends StatefulWidget{
  final TransactionCategory category;
  final Transaction transaction;
  final Entry entry;
  TransactionManager({@required this.category, this.transaction, this.entry});
  TransactionManagerState createState() => TransactionManagerState();
}

class TransactionManagerState extends State<TransactionManager>{
  static const String costNotSpecified = "Please specify transaction value";
  static const String categoryNotSpecified = "Please specify category";
  static const String selectTimeButtonText = "Select date";
  static const String selectCategoryButtonText = "Select category";

  String get details{
    if(widget.transaction!=null){
      return "Selected transaction will be updated";
    } else if(widget.entry!=null){
      if(widget.entry.recurring){
        return "Pending transaction is recurring";
      } else {
        return "Pending transaction will be removed";
      }
    } else {
      return "";
    }
  }

  String label; double value;
  ValueNotifier<TransactionCategory> categoryNotifier;
  ValueNotifier<DateTime> dateTimeNotifier;

  ValueNotifier<String> errorNotifier;

  TextEditingController textLabelEditingController;
  TextEditingController textValueEditingController;

  FocusNode labelNode;
  FocusNode valueNode;
  
  static const String dateFormatString = "EEEE, MM.dd.yyyy";
  final DateFormat dateFormat = DateFormat(dateFormatString);
  
  @override
  void initState() {
    categoryNotifier = ValueNotifier(widget.entry != null ? currentDataPickNotifier.value.categories.firstWhere((trc){return widget.entry.trcID == trc.trcID;}) : widget.category);
    dateTimeNotifier = ValueNotifier(widget.transaction!=null ? widget.transaction.calendar : DateTime.now());

    textLabelEditingController = TextEditingController(text: widget.transaction!=null?widget.transaction.label:"");
    textValueEditingController = TextEditingController(text: widget.transaction!=null?widget.transaction.value.toStringAsFixed(2):"");

    labelNode = FocusNode();
    valueNode = FocusNode();

    errorNotifier = ValueNotifier(null);

    super.initState();
  }
  
  @override
  void dispose() {
    categoryNotifier.dispose();
    dateTimeNotifier.dispose();

    textLabelEditingController.dispose();
    textValueEditingController.dispose();

    labelNode.dispose();
    valueNode.dispose();

    errorNotifier.dispose();

    super.dispose();
  }

  static final GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: dateTimeNotifier,
      builder: (context, dateTime, child) {
        return ValueListenableBuilder<TransactionCategory>(
          valueListenable: categoryNotifier,
          builder: (context, category, child){
            return AnimatedBackground(
              onKeyboardClosed: (){
                labelNode.unfocus();
                valueNode.unfocus();
              },
              topBarButtons: [
                TopBarButton(
                  onPressed: () async {
                    final DateTime selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 180)),
                      lastDate: DateTime.now().add(Duration(days: 180)),
                    );
                    if(selectedDate!=null) {
                      dateTimeNotifier.value=DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                    }
                  },
                  iconData: Icons.date_range,
                  text: dateFormat.format(dateTime),
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 8),
                ),
                TopBarButton(
                  onPressed: () => showDialog(context: context, builder: (context) => CategorySelector(categoryNotifier: categoryNotifier, categories: currentDataPickNotifier.value.categories)),
                  iconData: Icons.loyalty,
                  text: category == null ? selectCategoryButtonText : category.label,
                  padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 16),
                ),
              ],
              child: Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ScreenLabel(label:  ),
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
                                                  child: const Icon(Icons.monetization_on, color: colorPrimaryDark,),
                                                ),
                                                const Expanded(
                                                  child: const Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: const Text("Specify your transaction's value;", style: const TextStyle(fontSize: 16, color: secondaryText),),
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
                                                  child: const Icon(Icons.category, color: colorPrimaryDark,),
                                                ),
                                                const Expanded(
                                                  child: const Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: const Text("Specify the category the transaction is related to;", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
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
                                                  child: const Icon(Icons.date_range, color: colorPrimaryDark,),
                                                ),
                                                const Expanded(
                                                  child: const Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: const Text("Don't forget to check the date of transaction - by default it's set to right now.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
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
                                  child: TextFormField(
                                    onEditingComplete: () => valueNode.unfocus(),
                                    controller: textValueEditingController,
                                    focusNode: valueNode,
                                    decoration: InputDecoration( //todo const? remove currency?
                                      labelText: "Value",
                                      helperText: "Required",
                                      suffixText: currentDataPickNotifier.value.account.currency,
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (str){
                                      if(str.isNotEmpty){
                                        try{
                                          double parse = double.parse(str);
                                          if(parse != 0 && parse.abs()>0.01) {
                                            return null;
                                          } else {
                                            return "Please don't add reduntant transactions";
                                          }
                                        } catch(e) {
                                          return "Please enter a valid number";
                                        }
                                      } else {
                                        return "Please enter transaction value";
                                      }
                                    },
                                    onSaved: (str){
                                      value = double.parse(str.replaceAll(",", "."));
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: colorPrimary,),
                                  onPressed: (){
                                    if(textValueEditingController.text.isNotEmpty){
                                      try{
                                        value = double.parse(textValueEditingController.text.replaceAll(",", "."));
                                      } catch (e){}
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
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
                                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                                            child: Flex(
                                              direction: Axis.horizontal,
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: const <Widget>[
                                                const Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: const Icon(Icons.label_important, color: colorPrimaryDark,),
                                                ),
                                                const Expanded(
                                                  child: const Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: const Text("Optionally add a label for easier transaction management;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                                            child: Flex(
                                              direction: Axis.horizontal,
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: const <Widget>[
                                                const Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: const Icon(Icons.transform, color: colorPrimaryDark,),
                                                ),
                                                const Expanded(
                                                  child: const Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: const Text("If no label is specified, category name will be used instead", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
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
                                  child: TextFormField(
                                    onEditingComplete: () => labelNode.unfocus(),
                                    validator: (str) => null,
                                    onSaved: (str) => label = str,
                                    controller: textLabelEditingController,
                                    focusNode: labelNode,
                                    keyboardType: TextInputType.text,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: const InputDecoration( //todo const? remove currency?
                                      labelText: "Label",
                                      helperText: "Optional",
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: colorPrimary,),
                                  onPressed: (){
                                    if(textLabelEditingController.text.isNotEmpty){
                                      label = textLabelEditingController.text;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(details, style: const TextStyle(color: secondaryText, fontSize: 16),),
                  ),
                ],
              ),
              errorNotifier: errorNotifier,
              onConfirmed: (){
                if(formKey.currentState.validate()){
                  formKey.currentState.save();
                  if(value!=null){
                    if(categoryNotifier.value!=null){
                      act(
                        Transaction(
                          accUUID: currentDataPickNotifier.value.account.uuid,
                          trcID: categoryNotifier.value.trcID,
                          uuid: widget.transaction==null?null:widget.transaction.uuid,
                          label: (label!=null && label.isNotEmpty)?label:null,
                          value: value,
                          currency: currentDataPickNotifier.value.account.currency,
                          calendar: dateTimeNotifier.value.toUtc(),
                        ),
                        widget.transaction==null?action_INSERT:action_UPDATE,
                      );
                      if(widget.entry!=null && !widget.entry.recurring){
                        act(widget.entry, action_DELETE, showSnackBar: false);
                      }
                      Navigator.pop(context);
                    } else {
                      errorNotifier.value = categoryNotSpecified;
                    }
                  } else {
                    errorNotifier.value = costNotSpecified;
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}