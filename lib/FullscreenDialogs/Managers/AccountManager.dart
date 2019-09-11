import 'package:flutter/material.dart';

import 'package:thrift/Functions/Fetch.dart';
import 'package:thrift/Functions/KeyboardVisibilityNotification.dart';
import 'package:thrift/Functions/getDateRange.dart';

import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DateRange.dart';

import 'package:thrift/Models/DataTypes/Account.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Widgets/Reusable UI components/ScreenLabel.dart';
import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';
import 'package:thrift/Widgets/Reusable UI components/MaterialDialog.dart';
import 'package:thrift/Widgets/Dialogs/ConfirmRequester.dart';

import 'package:thrift/Widgets/Reusable UI components/AnimatedBackground.dart';

//Todo place dialog contents to workspace

class AccountManager extends StatefulWidget{
  AccountManagerState createState() => AccountManagerState();
}

class AccountManagerState extends State<AccountManager> with SingleTickerProviderStateMixin{

  FocusNode currencyNode;
  ValueNotifier<String> currencyNotifier;
  ValueNotifier<bool> currencyNeedsSpaceNotifier;
  ValueNotifier<bool> currencySignOnRightNotifier;

  FocusNode labelNode;
  ValueNotifier<String> labelNotifier;
  ValueNotifier<int> seasoningTypeNotifier;

  ValueNotifier<String> errorNotifier;

  TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    currencyNode = FocusNode();
    labelNode = FocusNode();
    currencyNotifier = ValueNotifier(currentDataPickNotifier.value.account.currency);
    currencyNeedsSpaceNotifier = ValueNotifier(currentDataPickNotifier.value.account.currencyNeedsSpace);
    currencySignOnRightNotifier = ValueNotifier(currentDataPickNotifier.value.account.currencySignOnRight);
    labelNotifier = ValueNotifier(currentDataPickNotifier.value.account.name);
    seasoningTypeNotifier = ValueNotifier(currentDataPickNotifier.value.account.seasoningType);
    errorNotifier = ValueNotifier(null);
    super.initState();
  }

  @override
  void dispose() {
    currencyNotifier.dispose();
    currencySignOnRightNotifier.dispose();
    currencyNeedsSpaceNotifier.dispose();
    labelNotifier.dispose();
    seasoningTypeNotifier.dispose();
    errorNotifier.dispose();
    super.dispose();
  }

  static final GlobalKey<FormState> currencyFormKey = GlobalKey();
  static final GlobalKey<FormState> labelFormKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      onKeyboardClosed: null,
      topBarButtons: <TopBarButton>[
        TopBarButton(
          onPressed: () async {
            bool buffCurrencySignOnRight = currencySignOnRightNotifier.value;
            String buffCurrency = currencyNotifier.value;
            bool buffCurrencyNeedsSpace = currencyNeedsSpaceNotifier.value;
            showDialog(
              context: context,
              builder: (context) => MaterialDialog(
                headerText: "Account's currency",
                confirmButtonCallback: (){
                  if(currencyFormKey.currentState.validate()){
                    currencyFormKey.currentState.save();
                    Navigator.pop(context);
                  }
                },
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ValueListenableBuilder<String>(
                        valueListenable: currencyNotifier,
                        builder: (context, curr, child){
                          return Form(
                            key: currencyFormKey,
                            child: TextFormField(
                              onEditingComplete: (){
                                if(currencyFormKey.currentState.validate()){
                                  currencyFormKey.currentState.save();
                                }
                              },
                              onSaved: (text){
                                currencyNode.unfocus();
                                currencyNotifier.value = text;
                              },
                              decoration: InputDecoration(
                                hintText: curr,
                                labelText: "Sign or abbreviation",
                              ),
                              focusNode: currencyNode,
                              validator: (string) {
                                if(string.isNotEmpty){
                                  if(string.length<=3) {
                                    if(!string.contains(" ")){
                                      return null;
                                    } else {
                                      return "Please do not use space";
                                    }
                                  } else {
                                    return "Please make it as short as 3 symbols";
                                  }
                                } else {
                                  return ("Please specify your currency");
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text("Position", style: const TextStyle(color: secondaryText, fontSize: 16),),
                          ValueListenableBuilder<bool>(
                            valueListenable: currencySignOnRightNotifier,
                            builder: (context, onRight, child){
                              return Switch(value: onRight, onChanged: (value) => currencySignOnRightNotifier.value = value,);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text("Needs space", style: const TextStyle(color: secondaryText, fontSize: 16),),
                          ValueListenableBuilder<bool>(
                            valueListenable: currencyNeedsSpaceNotifier,
                            builder: (context, needsSpace, child){
                              return Switch(value: needsSpace, onChanged: (value) => currencyNeedsSpaceNotifier.value = value,);
                            },
                          ),
                        ],
                      ),
                    ),
                    divider,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ValueListenableBuilder<bool>(
                            valueListenable: currencySignOnRightNotifier,
                            builder: (context, onRight, child){
                              return ValueListenableBuilder<bool>(
                                valueListenable: currencyNeedsSpaceNotifier,
                                builder: (context, needsSpace, child){
                                  return ValueListenableBuilder<String>(
                                    valueListenable: currencyNotifier,
                                    builder: (context, currency, child){
                                      return Text( "-${onRight?currency:""}${onRight && needsSpace?" ":""}1234567.89${!onRight && needsSpace?" ":""}${!onRight?currency:""}",
                                        style: const TextStyle(color: secondaryText, fontSize: 16),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                cancelButtonText: "Cancel",
                cancelButtonCallback: (){
                  currencyNotifier.value = buffCurrency;
                  currencyNeedsSpaceNotifier.value = buffCurrencyNeedsSpace;
                  currencySignOnRightNotifier.value = buffCurrencySignOnRight;
                  Navigator.pop(context);
                },
                confirmButtonText: "Save",
              ),
            );
          },
          iconData: Icons.monetization_on,
          text: "Account's currency",
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        TopBarButton(
          onPressed: () async {
            int buffSeasoningType = seasoningTypeNotifier.value;
            String label;
            showDialog(
              context: context,
              builder: (context) => MaterialDialog(
                headerText: "Settings",
                confirmButtonText: "Save",
                cancelButtonText: "Cancel",
                confirmButtonCallback: (){
                  if(labelFormKey.currentState.validate()){
                    labelFormKey.currentState.save();
                    labelNotifier.value = label;
                  }
                  Navigator.pop(context);
                },
                cancelButtonCallback: (){
                  seasoningTypeNotifier.value = buffSeasoningType;
                  Navigator.pop(context);
                },
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ValueListenableBuilder<String>(
                        valueListenable: labelNotifier,
                        builder: (context, lab, child){
                          return Form(
                            key: labelFormKey,
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: lab,
                                labelText: "Label",
                              ),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (str){
                                if(str.isNotEmpty){
                                  return null;
                                } else {
                                  return "Please enter account name";
                                }
                              },
                              onSaved: (text) => label = text,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Text("Refreshing", style: const TextStyle(fontSize: 16, color: secondaryText),),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: seasoningTypeNotifier,
                            builder: (context, seasoningType, child){
                              return DropdownButton<int>(
                                value: seasoningType,
                                items: <DropdownMenuItem<int>>[
                                  DropdownMenuItem<int>(value: Account.type_MONTHLY, child: const Text("Monthly"),),
                                  DropdownMenuItem<int>(value: Account.type_SEASONALLY, child: const Text("Seasonally"),),
                                  DropdownMenuItem<int>(value: Account.type_QUARTERLY, child: const Text("Quarterly"),),
                                ],
                                onChanged: (value){
                                  seasoningTypeNotifier.value=value;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          iconData: Icons.settings,
          text: "Settings",
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        ),
      ],
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ScreenLabel(label: "Manage accounts"),
          Expanded(
            child: Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TabBar(
                  labelColor: colorPrimary,
                  indicatorColor: colorPrimary,
                  controller: controller,
                  tabs: <Widget>[
                    Tab(text: "Accounts",),
                    Tab(text: "Periods",),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80, top: 8),
                            shrinkWrap: false,
                            itemCount: accounts.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onLongPress: (){
                                  if(index!=0){
                                    showDialog(
                                      context: context,
                                      builder: (context) => ConfirmRequester(
                                        cancelButtonText: "Cancel",
                                        question: "Are you sure you want to delete selected account (${accounts[index].name})? After an account is deleted, all data associated with it is removed. This cannot be undone.",
                                        confirmButtonText: "Delete",
                                        onConfirm: (){act(accounts[index], action_DELETE); Navigator.pop(context); Navigator.pop(context);}, //ToDo rebuild dialog?
                                      ),
                                    );
                                  }
                                },
                                child: RawMaterialButton(
                                  splashColor: colorAccent,
                                  onPressed: (){
                                    print(index);
                                    setLayout(account: accounts[index]);
                                    Navigator.pop(context);
                                    //ToDo check
                                    /*
          if(thriftUnit.layoutData.value.currentAccount.id==thriftUnit.accounts[index].id){
            Navigator.pop(context);
          } else {
            thriftUnit.selectAccount(thriftUnit.accounts[index].id);
            Navigator.pop(context);
          }
          */
                                  },
                                  child: Container(
                                    height: 48,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: Text(accounts[index].name, style: const TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.normal), textAlign: TextAlign.start,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: FloatingActionButton(
                              onPressed: () => showDialog(context: context, builder: (context) => CreateAccount()),
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context){
                          List<Transaction> allAccountTransactions = List.from(currentDataPickNotifier.value.transactions);
                          List<DateRange> dateRangesUTC = [getDateRange(DateTime.now())];
                          while(allAccountTransactions.isNotEmpty){
                            allAccountTransactions.removeWhere((trn){
                              bool contains = false;
                              dateRangesUTC.forEach((dateRange){
                                if(trn.calendar.isAfter(dateRange.firstDate) && trn.calendar.isBefore(dateRange.secondDate)){
                                  contains=true;
                                }
                              });
                              return contains;
                            });
                            if(allAccountTransactions.isNotEmpty) {
                              dateRangesUTC.add(getDateRange(allAccountTransactions[0].calendar));
                            }
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: dateRangesUTC.length,
                            itemBuilder: (context, index){
                              return RawMaterialButton(
                                splashColor: colorAccent,
                                onPressed: () {
                                  setLayout(dateRange: dateRangesUTC[index]);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  height: 48,
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(dateRangesUTC[index].name, style: const TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.normal), textAlign: TextAlign.start,),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      errorNotifier: errorNotifier,
      onConfirmed: (){
        Account currentAccount = currentDataPickNotifier.value.account;
        if(
          currentAccount.name != labelNotifier.value
          || currentAccount.currency != currencyNotifier.value
          || currentAccount.currencySignOnRight != currencySignOnRightNotifier.value
          || currentAccount.currencyNeedsSpace != currencyNeedsSpaceNotifier.value
          || currentAccount.seasoningType != seasoningTypeNotifier.value
        ){
          act(
            Account(
              name: labelNotifier.value,
              uuid: currentAccount.uuid,
              seasoningType: seasoningTypeNotifier.value,
              currency: currencyNotifier.value,
              currencyNeedsSpace: currencyNeedsSpaceNotifier.value,
              currencySignOnRight: currencySignOnRightNotifier.value,
            ),
            action_UPDATE,
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

class CreateAccount extends StatefulWidget{
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount>{
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  KeyboardVisibilityNotification keyboardVisibilityNotification;
  String label;
  ValueNotifier<int> presetNotifier;
  FocusNode focusNode;

  @override
  void initState() {
    keyboardVisibilityNotification = KeyboardVisibilityNotification((keyboardVisible){
      if(!keyboardVisible){
        if(formKey.currentState.validate()) {
          formKey.currentState.save();
        }
      }
    });
    presetNotifier = ValueNotifier(type_PERSONAL);
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilityNotification.dispose();
    presetNotifier.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDialog(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flex(
                  direction: Axis.horizontal,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Account name",
                          ),
                          validator: (string) {
                            if(string.isNotEmpty){
                              return null;
                            } else {
                              return ("Please specify account name");
                            }
                          },
                          focusNode: focusNode,
                          onSaved: (str){
                            focusNode.unfocus();
                            label = str;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Text("Preset", style: TextStyle(fontSize: 16, color: secondaryText),),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: presetNotifier,
                        builder: (context, seasoningType, child){
                          return DropdownButton<int>(
                            value: seasoningType,
                            items: <DropdownMenuItem<int>>[
                              DropdownMenuItem<int>(value: type_PERSONAL, child: const Text("Personal"),),
                              DropdownMenuItem<int>(value: type_BUSINESS, child: const Text("Business"),),
                            ],
                            onChanged: (value){
                              presetNotifier.value=value;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      headerText: "Create account",
      confirmButtonText: "Confirm",
      confirmButtonCallback: (){
        if(formKey.currentState.validate()){
          formKey.currentState.save();
          act(
            Account(name: null, seasoningType: null, currency: null, currencySignOnRight: null, currencyNeedsSpace: null),
            action_INSERT,
            label: label,
            presetType: presetNotifier.value,
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      cancelButtonCallback: () => Navigator.pop(context),
      cancelButtonText: "Cancel",
    );
  }
}