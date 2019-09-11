import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:thrift/Functions/Fetch.dart';

import 'package:thrift/Models/DataTypes/Entry.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/Arguments.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/Routes.dart';
import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Widgets/Category.dart';

import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';

class Agenda extends StatefulWidget{
  AgendaState createState() => AgendaState();
}

class AgendaState extends State<Agenda> {
  static const int sorting_POSITIVE = 1;
  static const int sorting_NEGATIVE = -1;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ValueListenableBuilder<CurrentDataPick>(
          valueListenable: currentDataPickNotifier,
          builder: (context, data, child){
            if(data.entries.isNotEmpty) {
              List<Entry> entries = data.entries
                ..sort((entry1, entry2) {
                  if (entry1.reminderCalendar != null &&
                      entry2.reminderCalendar != null) {
                    return entry1.reminderCalendar.compareTo(
                        entry2.reminderCalendar);
                  } else {
                    if (entry1.reminderCalendar != null) {
                      return sorting_NEGATIVE;
                    } else if (entry2.reminderCalendar != null) {
                      return sorting_POSITIVE;
                    } else {
                      return 0;
                    }
                  }
                });
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return AgendaListItem(
                    entry: entries[index],
                  );
                },
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 44, right: 32),
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.playlist_add, size: 96, color: dividerColor,),
                      const Padding(
                        padding: const EdgeInsets.all(12),
                        child: const Text("No pending transactions", style: const TextStyle(fontSize: 20, color: primaryText),),
                      ),
                      const Text("Add your agenda for easier expense planning and transaction management", style: const TextStyle(fontSize: 16, color: secondaryText), textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        //Has to be on bottom => on top of stack
        Positioned(
          bottom: kFloatingActionButtonMargin,
          right: kFloatingActionButtonMargin,
          child: FloatingActionButton(
            elevation: 6,
            child: const Icon(Icons.add, color: white,),
            backgroundColor: colorPrimary,
            onPressed: () =>  Navigator.pushNamed(context, route_EntryManager),
          ),
        ),
      ],
    );
  }
}

class AgendaListItem extends StatelessWidget{
  static const String noReminder = "No reminder";
  static const String recurring = "Recurring";

  static const String dateFormatString = "MM.dd.yyyy, E, HH:mm";
  final DateFormat dateFormat = DateFormat(dateFormatString);

  final TransactionCategory category;
  final Entry entry;
  AgendaListItem({@required this.entry}) : this.category = currentDataPickNotifier.value.categories.firstWhere((trc){return trc.trcID == entry.trcID;});

  static const double wrapSpacing = 4;
  static const double wrapRunSpacing = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = [];
    entry.labels.forEach((label){
      chips.add(Chip(
        label: Text(label),
        backgroundColor: chipColor,
      ));
    });
    return GestureDetector(
      onLongPress: (){
        showDialog(
          context: context,
          builder: (context) => MaterialDialog(
            headerText: "Are you sure you want to delete this pending purchase?",
            confirmButtonCallback: (){act(entry, action_DELETE); Navigator.pop(context);},
            confirmButtonText: "Delete",
            cancelButtonCallback: () => Navigator.pop(context),
            cancelButtonText: "Cancel",
          ),
        );
      },
      child: RawMaterialButton(
        splashColor: colorAccent,
        onPressed: () => Navigator.pushNamed(context, route_TransactionManager, arguments: Arguments(transactionCategory: category, entry: entry,)),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: CategoryIconWithHalo(drawableID: category.drawableID, colorID: category.colorID, haloSize: 40,),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 16, right: 16),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(entry.reminderCalendar!=null?dateFormat.format(entry.reminderCalendar.toLocal()):noReminder, style: const TextStyle(fontSize: 16, color: primaryText),),
                    entry.recurring ? const Padding(padding: const EdgeInsets.only(top: 6), child: const Text(recurring, style: const TextStyle(fontSize: 14, color: secondaryText),),) : Container(),
                    Flexible(
                      child: Wrap(
                        spacing: wrapSpacing,
                        runSpacing: wrapRunSpacing,
                        children: chips,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: IconButton(
                icon: Icon(Icons.edit, color: colorPrimaryDark,),
                onPressed: () => Navigator.pushNamed(context, route_EntryManager, arguments: Arguments(entry: entry)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}