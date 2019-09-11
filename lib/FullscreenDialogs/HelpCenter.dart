import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';


class HelpCenter extends StatefulWidget{
  HelpCenterState createState() => HelpCenterState();
}

class HelpCenterState extends State<HelpCenter>{
  ValueNotifier<int> selectedIDNotifier;

  @override
  void initState() {
    selectedIDNotifier = ValueNotifier(-1);
    super.initState();
  }

  @override
  void dispose() {
    selectedIDNotifier.dispose();
    super.dispose();
  }

  ExpansionPanel panel({@required int index, @required String question, @required String answer}){
    return ExpansionPanel(
      isExpanded: selectedIDNotifier.value==index,
      canTapOnHeader: true,
      headerBuilder: (context, expanded){
        return Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                  color: colorPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: const Center(child: const Icon(Icons.sort, size: 20, color: white,)),
              ),
            ),
            Flexible(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(question, style: const TextStyle(color: primaryText, fontSize: 16),),
            )),
          ],
        );
      },
      body: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 8),
            child: Text(answer, style: const TextStyle(color: secondaryText, fontSize: 16),),
          ))
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          color: white,
          iconTheme: IconThemeData(color: primaryText),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Help center", style: const TextStyle(color: primaryText),),
        ),
        body: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: selectedIDNotifier,
                builder: (context, selectedID, child){
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: white,
                            child: Flex(
                              direction: Axis.vertical,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                const Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  child: const Text("If you cannot find an answer you need, please contact our support", style: const TextStyle(color: secondaryText, fontSize: 16),),
                                ),
                                divider,
                                const Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  child: const Text("Frequently asked questions:", style: const TextStyle(color: secondaryText, fontSize: 16),),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ExpansionPanelList(
                          expansionCallback: (index, selected){
                            if(!selected){
                              selectedIDNotifier.value=index;
                            } else {
                              selectedIDNotifier.value=-1;
                            }
                          },
                          children: <ExpansionPanel>[
                            panel(
                              index: 0,
                              question: "How do I manage accounts?",
                              answer: 'Click the "gear" icon to edit current account. Click the "bank" icon to switch accounts or create a new account.',
                            ),
                            panel(
                              index: 1,
                              question: "How do I add incomes?",
                              answer: "You can open the incomes chart by clicking the diagram.",
                            ),
                            panel(
                              index: 2,
                              question: "How do I edit categories?",
                              answer: 'You can long-press a category to open an editor page.',
                            ),
                            panel(
                              index: 3,
                              question: "How do I delete a data entry?",
                              answer: 'You can long-press any list item in the "History" and "Agenda" lists to delete a transaction or a pending transaction.',
                            ),
                            panel(
                              index: 4,
                              question: "How do I edit a data entry?",
                              answer: 'Tap a transaction in the "History" list or tap the "edit" icon in the "Agenda" list on a pending transaction.',
                            ),
                            panel(
                              index: 5,
                              question: "App shows unintended behavior and/or I have experienced dataloss",
                              answer: 'Please contact us as soon as possible. We will do anything we can to retrieve your data and prevent this from happening in future.',
                            ),
                            panel(
                              index: 6,
                              question: "I have an idea for the app",
                              answer: "Do not hesitate to contact us. We will respond to every message we recieve.",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}