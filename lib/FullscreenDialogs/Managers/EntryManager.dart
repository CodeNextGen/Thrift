import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:thrift/Functions/Fetch.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Models/DataTypes/Entry.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

import 'package:thrift/Widgets/Reusable UI components/ScreenLabel.dart';
import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';
import 'package:thrift/Widgets/Dialogs/CategorySelector.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';

import 'package:thrift/Widgets/Reusable UI components/AnimatedBackground.dart';

class EntryManager extends StatefulWidget{
  final Entry entry;
  EntryManager({this.entry});
  EntryManagerState createState() => EntryManagerState();
}

class EntryManagerState extends State<EntryManager>{
  static const String categoryNotSpecified = "Please specify category";
  static const String labelsNotSpecified = "Please specify your agenda";
  static const String selectTimeButtonText = "Select date (optional)";
  static const String selectCategoryButtonText = "Select category";

  static const String dateFormatString = "MM.dd.yyyy, E, HH:mm";
  final DateFormat dateFormat = DateFormat(dateFormatString);

  TextEditingController textEditingController;
  FocusNode focusNode;

  ValueNotifier<List<String>> labelsNotifier;
  ValueNotifier<bool> recurringNotifier;
  ValueNotifier<TransactionCategory> categoryNotifier;
  ValueNotifier<DateTime> dateTimeNotifier;

  ValueNotifier<String> errorNotifier;

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController.addListener((){
      if(textEditingController.text.isNotEmpty){
        if(textEditingController.text.replaceAll(",", "").isEmpty){
          textEditingController.text = "";
        } else if(textEditingController.text.replaceAll(",", "").isNotEmpty && textEditingController.text[textEditingController.text.length-1] == ","){
          labelsNotifier.value = List.from(labelsNotifier.value..add(textEditingController.text.replaceAll(",", "")));
          textEditingController.text = "";
        }
      }
    });
    focusNode = FocusNode();

    labelsNotifier = ValueNotifier(widget.entry!=null?widget.entry.labels:[]);
    recurringNotifier = ValueNotifier(widget.entry!=null?widget.entry.recurring:false);
    categoryNotifier = ValueNotifier(widget.entry!=null?currentDataPickNotifier.value.categories.firstWhere((trc){return trc.trcID == widget.entry.trcID;}):null);
    dateTimeNotifier = ValueNotifier(widget.entry!=null?widget.entry.reminderCalendar:null);

    errorNotifier = ValueNotifier(null);

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();

    labelsNotifier.dispose();
    recurringNotifier.dispose();
    categoryNotifier.dispose();
    dateTimeNotifier.dispose();

    errorNotifier.dispose();

    super.dispose();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TransactionCategory>(
      valueListenable: categoryNotifier,
      builder: (context, category, child){
        return ValueListenableBuilder<DateTime>(
          valueListenable: dateTimeNotifier,
          builder: (context, dateTime, child){
            return AnimatedBackground(
              onKeyboardClosed: (){
                if(textEditingController.text.isNotEmpty){
                  labelsNotifier.value = List.from(labelsNotifier.value..add(textEditingController.text.replaceAll(",", "")));
                  textEditingController.text = "";
                }
                focusNode.unfocus();
              },
              topBarButtons: [
                TopBarButton(
                  onPressed: () async {
                    final DateTime selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 180)),
                    );
                    if(selectedDate!=null) {
                      final TimeOfDay selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if(selectedTime!=null){
                        dateTimeNotifier.value=DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                      }
                    }
                  },
                  iconData: dateTime == null ? Icons.notifications_none : Icons.notifications_active,
                  text: dateTime == null ? selectTimeButtonText : dateFormat.format(dateTime),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ScreenLabel(label: "Add transaction agenda"),
                  Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: const <Widget>[
                                            const Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: const Icon(Icons.playlist_add, color: colorPrimaryDark,),
                                            ),
                                            const Expanded(
                                              child: const Padding(
                                                padding: const EdgeInsets.only(right: 16),
                                                child: const Text("Add planned transactions related to the selected category in bulk;", style: const TextStyle(fontSize: 16, color: secondaryText),),
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
                                              child: const Icon(Icons.notifications, color: colorPrimaryDark,),
                                            ),
                                            const Expanded(
                                              child: const Padding(
                                                padding: const EdgeInsets.only(right: 16),
                                                child: const Text("Optionally add a reminder - it will set off a notification at the given time;", style: const TextStyle(fontSize: 16, color: secondaryText),),
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
                                              child: const Icon(Icons.update, color: colorPrimaryDark,),
                                            ),
                                            const Expanded(
                                              child: const Padding(
                                                padding: const EdgeInsets.only(right: 16),
                                                child: const Text("Recurring notifications don't get removed form the list. They have to be deleted manually.", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                              ),
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
                              child: TextField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  labelText: "Items",
                                  hintText: "Comma-separated",
                                ),
                                focusNode: focusNode,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: colorPrimary,),
                              onPressed: (){
                                if(textEditingController.text.isNotEmpty){
                                  if(textEditingController.text.replaceAll(",", "").isNotEmpty){
                                    labelsNotifier.value = List.from(labelsNotifier.value..add(textEditingController.text.replaceAll(",", "")));
                                  }
                                  focusNode.unfocus();
                                  textEditingController.text = "";
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: labelsNotifier,
                      builder: (context, labels, child){
                        print("Labels updated");
                        List<Widget> children = [];
                        for(int i=labels.length-1; i>=0; i--){
                          children.add(
                            Container(
                              child: Chip(
                                deleteIcon: Icon(Icons.cancel, size: 18,),
                                deleteIconColor: chipIconColor,
                                backgroundColor: chipColor,
                                label: Text(labels[i]),
                                onDeleted: (){
                                  labelsNotifier.value = List.from(labels..removeAt(i));
                                },
                              ),
                            ),
                          );
                        }
                        return Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                              child: const Divider(color: dividerColor, height: 1,),
                            ),
                            Expanded(
                              child: ListView(
                                children: <Widget>[
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 0,
                                    direction: Axis.horizontal,
                                    children: children,
                                  ),
                                ],
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Divider(color: dividerColor, height: 1,),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: recurringNotifier,
                    builder: (context, recurring, child){
                      return Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Checkbox(
                              value: recurring,
                              onChanged: (value) => recurringNotifier.value = value,
                            ),
                          ),
                          Text(
                            "Recurring", style: TextStyle(color: secondaryText, fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              errorNotifier: errorNotifier,
              onConfirmed: (){
                if(categoryNotifier.value!=null){
                  if(labelsNotifier.value!=null && labelsNotifier.value.isNotEmpty){
                    act(
                      Entry(
                        accUUID: currentDataPickNotifier.value.account.uuid,
                        labels: labelsNotifier.value,
                        trcID: categoryNotifier.value.trcID,
                        uuid: widget.entry == null ? null : widget.entry.uuid,
                        notificationID: widget.entry == null ? null : widget.entry.notificationID,
                        recurring: recurringNotifier.value,
                        reminderCalendar: dateTimeNotifier.value==null?null:dateTimeNotifier.value.toUtc(),
                      ),
                      widget.entry == null ? action_INSERT : action_UPDATE,
                    );
                    Navigator.pop(context);
                  } else {
                    errorNotifier.value = labelsNotSpecified;
                  }
                } else {
                  errorNotifier.value = categoryNotSpecified;
                }
              },
              scaffoldKey: scaffoldKey,
            );
          },
        );
      },
    );
  }
}