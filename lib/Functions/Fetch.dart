import 'package:flutter/material.dart';

import 'package:thrift/API/Transmit.dart';

import 'package:thrift/Functions/getDateRange.dart';
import 'package:thrift/Functions/manageNotification.dart';

import 'package:thrift/Models/DataTypes/Account.dart';
import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/DataTypes/Entry.dart';
import 'package:thrift/Models/DateRange.dart';

import 'package:thrift/Instances/Notifiers/Snackbar.dart';
import 'package:thrift/Instances/SharedPreferences.dart';
import 'package:thrift/Instances/DataPick.dart';
import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/SQFLite/Accounts.dart';
import 'package:thrift/SQFLite/Data.dart';
import 'package:thrift/SQFLite/ObsoleteBuffer.dart';

Accounts acc = Accounts(version: 2);
Data data = Data(version: 4);

Future<void> fetch() async {
  accounts = await acc.getAccounts();
  categories = await data.getCategories();
  transactions = await data.getTransactions();
  entries = await data.getEntries();
}

const String preference_jwt = "jwt";

void setLayout({DateRange dateRange, Account account}){
  const String preferences_currentAccountUUID = "currentAccountUUID";
  Account acc;
  DateRange dtr;
  if(currentDataPickNotifier != null && accounts.isNotEmpty) {
    acc = account ?? currentDataPickNotifier.value.account;
    sharedPreferences.setString(preferences_currentAccountUUID, acc.uuid);
    dtr = dateRange ?? currentDataPickNotifier.value.dateRange;
    currentDataPickNotifier.value = CurrentDataPick(
      dateRange: dtr,
      account: acc,
      transactions: transactions.where((trn) => trn.accUUID == acc.uuid && trn.calendar.isAfter(dtr.firstDate) && trn.calendar.isBefore(dtr.secondDate)).toList(),
      entries: entries.where((entry) => entry.accUUID == acc.uuid).toList(),
      categories: categories.where((trc) => trc.accUUID == acc.uuid).toList(),
    );
  } else {
    String accUUID = sharedPreferences.getString(preferences_currentAccountUUID);
    if(accUUID == null){
      int obsoleteAccID = sharedPreferences.getInt("currentAccountID");
      if(obsoleteAccID!=null){
        acc = obsoleteAccounts.firstWhere((obs) => obs.obsoleteID == obsoleteAccID).account;
      } else {
        saveDefaultAccount();
        acc = accounts[0];
        sharedPreferences.setString(preferences_currentAccountUUID, acc.uuid);
      }
    } else {
      acc = accounts.firstWhere((account) => account.uuid == accUUID);
      sharedPreferences.setString(preferences_currentAccountUUID, acc.uuid);
    }
    dtr = getDateRange(DateTime.now(), account: acc);
    currentDataPickNotifier = ValueNotifier(
      CurrentDataPick(
        dateRange: dtr,
        account: acc,
        transactions: transactions.where((trn) => trn.accUUID == acc.uuid && trn.calendar.isAfter(dtr.firstDate) && trn.calendar.isBefore(dtr.secondDate)).toList(),
        entries: entries.where((entry) => entry.accUUID == acc.uuid).toList(),
        categories: categories.where((trc) => trc.accUUID == acc.uuid).toList(),
      ),
    );
  }
}

const int action_INSERT = 0;
const int action_UPDATE = 1;
const int action_DELETE = 2;

Future<int> syncAPI(){
  return transmit(jsonData: {
    requestType_HEADER: requestType_COMPARE,
  });
}

Future<void> act(var value, int action, {int presetType, String label, bool showSnackBar = true, bool transmi = true}) async { //ToDo await all db actions!!!!!
  switch(value.runtimeType){
    case List:
      if(action == action_INSERT) {
        if (value is List<Account>) {
          acc.saveAccountsBulk(accounts);
          accounts.addAll(value);
          if (transmi) {
            List<Map<String, dynamic>> accList = List();
            value.forEach((acc) {
              accList.add(acc.toJson());
            });
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                ACC: accList,
              },
            );
          }
        } else if (value is List<Transaction>) {
          data.saveTransactionsBulk(value);
          transactions.addAll(value);
          if (transmi) {
            List<Map<String, dynamic>> trnList = List();
            value.forEach((trn) {
              trnList.add(trn.toJson());
            });
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                TRN: trnList,
              },
            );
          }
        } else if (value is List<TransactionCategory>) {
          data.saveCategoriesBulk(value);
          categories.addAll(value);
          if (transmi) {
            List<Map<String, dynamic>> trcList = List();
            value.forEach((trc) {
              trcList.add(trc.toJson());
            });
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                TRC: trcList,
              },
            );
          }
        } else if (value is List<Entry>) {
          data.saveEntriesBulk(value);
          entries.addAll(value);
          value.forEach((ent){
            manageNotification(ent);
          });
          if(transmi){
            List<Map<String, dynamic>> entList = List();
            value.forEach((ent){
              entList.add(ent.toJson());
            });
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                ENT: entList,
              },
            );
          }
        }
      }
      break;
    case Account:
      switch(action){
        case action_INSERT:
          Account account = Account(
            name: label,
            seasoningType: Account.type_MONTHLY,
            currency: "\$",
            currencyNeedsSpace: false,
            currencySignOnRight: false,
          );
          List<TransactionCategory> cat = saveDefaultFiles(presetType, account.uuid);
          List<Map<String, dynamic>> categoriesJSON = List();
          cat.forEach((trc){
            categoriesJSON.add(trc.toJson());
          });
          acc.saveAccount(account);
          accounts.add(account);
          setLayout(account: account);
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                ACC: [account.toJson()],
                TRC: categoriesJSON,
              },
            );
          }
          break;
        case action_UPDATE:
          Account obsoleteAccount = accounts.firstWhere((acc) => acc.uuid == value.uuid);
          accounts.remove(obsoleteAccount);
          Account newAccount = Account(
            name: value.name,
            seasoningType: value.seasoningType,
            currency: value.currency,
            currencySignOnRight: value.currencySignOnRight,
            currencyNeedsSpace: value.currencyNeedsSpace,
          );
          acc.deleteAccount(obsoleteAccount.uuid);
          acc.saveAccount(newAccount);
          accounts.add(newAccount);

          data.updateAccUUID(obsoleteAccount.uuid, newAccount.uuid);

          List<Transaction> updatedTransactions = List();
          List<Entry> updatedEntries = List();
          List<TransactionCategory> updatedCategories = List();

          transactions.forEach((trn){
            if(trn.accUUID == obsoleteAccount.uuid){
              updatedTransactions.add(Transaction(
                accUUID: newAccount.uuid,
                trcID: trn.trcID,
                uuid: trn.uuid,
                label: trn.label,
                value: trn.value,
                currency: trn.currency,
                calendar: trn.calendar,
              ));
            }
          });
          categories.forEach((trc){
            if(trc.accUUID == obsoleteAccount.uuid){
              updatedCategories.add(TransactionCategory(
                  accUUID: newAccount.uuid,
                  trcID: trc.trcID,
                  drawableID: trc.drawableID,
                  colorID: trc.colorID,
                  label: trc.label,
                  uuid: trc.uuid
              ));
            }
          });
          entries.forEach((ent){
            if(ent.accUUID == obsoleteAccount.uuid){
              updatedEntries.add(Entry(
                labels: ent.labels,
                accUUID: newAccount.uuid,
                trcID: ent.trcID,
                recurring: ent.recurring,
                reminderCalendar: ent.reminderCalendar,
                uuid: ent.uuid,
                notificationID: ent.notificationID,
              ));
            }
          });

          transactions.removeWhere((unit) => unit.accUUID == obsoleteAccount.uuid);
          transactions.addAll(updatedTransactions);
          categories.removeWhere((unit) => unit.accUUID == obsoleteAccount.uuid);
          categories.addAll(updatedCategories);
          entries.removeWhere((unit) => unit.accUUID == obsoleteAccount.uuid);
          entries.addAll(updatedEntries);

          setLayout(account: newAccount);
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_UPDATE,
                request_obsoleteUUID: request_obsoleteUUID,
                ACC: newAccount.toJson(),
              },
            );
          }
          break;
        case action_DELETE:
          accounts.remove(value);
          data.deleteContentsOfAccount(value.uuid);
          acc.deleteAccount(value.uuid);
          List<Entry> removedEntries = entries.where((entry) => entry.accUUID == value.uuid).toList();
          removedEntries.forEach((entry){
            manageNotification(entry, delete: true);
          });
          entries.removeWhere((entry) => entry.accUUID == value.uuid);
          transactions.removeWhere((trn) => trn.accUUID == value.uuid);
          categories.removeWhere((trc) => trc.accUUID == value.uuid);
          if(currentDataPickNotifier.value.account.uuid == value.uuid && accounts.isNotEmpty) {
            setLayout(account: accounts[0]);
          } else {
            setLayout();
          }
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_DELETE,
                ACC: [value.uuid()],
              },
            );
          }
          break;
      }
      break;
    case TransactionCategory:
      switch(action){
        case action_INSERT:
          categories.add(value);
          data.saveCategory(value);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                TRC: [value],
              },
            );
          }
          break;
        case action_UPDATE:
          TransactionCategory obsoleteCategory = categories.firstWhere((trc) => trc.uuid == value.uuid);
          categories.remove(obsoleteCategory);
          TransactionCategory newCategory = TransactionCategory(
            accUUID: value.accUUID,
            trcID: value.trcID,
            drawableID: value.drawableID,
            colorID: value.colorID,
            label: value.label,
          );
          categories.add(newCategory);
          data.deleteCategory(obsoleteCategory.uuid);
          data.saveCategory(newCategory);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_UPDATE,
                request_obsoleteUUID: obsoleteCategory.uuid,
                TRC: newCategory.toJson(),
              },
            );
          }
          break;
        case action_DELETE:
          List<Entry> removedEntries = entries.where((entry) => entry.accUUID == value.accUUID && entry.trcID == value.trcID).toList();
          removedEntries.forEach((entry){
            manageNotification(entry, delete: true);
          });
          entries.removeWhere((entry) => entry.accUUID == value.accUUID && entry.trcID == value.trcID);
          transactions.removeWhere((trn) => trn.accUUID == value.accUUID && trn.trcID == value.trcID);
          categories.remove(value);
          data.deleteContentsOfCategory(value.trcID, value.accUUID);
          data.deleteCategory(value.uuid);
          setLayout();
          if(!(showSnackBar!=null && !showSnackBar)) {
            snackbarNotifier.value = SnackBar(
              content: Text("Category removed"),
              action: SnackBarAction(
                label: "UNDO",
                onPressed: ()=>act(value, action_INSERT),
                textColor: snackBarAction,
              ),
            );
          }
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_DELETE,
                TRC: [value.uuid()],
              },
            );
          }
          break;
      }
      break;
    case Transaction:
      switch(action){
        case action_INSERT:
          transactions.add(value);
          data.saveTransaction(value);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                TRN: [value.toJson()],
              },
            );
          }
          break;
        case action_UPDATE:
          Transaction obsoleteTransaction = transactions.firstWhere((trn) => trn.uuid == value.uuid);
          transactions.remove(obsoleteTransaction);
          Transaction newTransaction = Transaction(
            accUUID: value.accUUID,
            trcID: value.trcID,
            label: value.label,
            value: value.value,
            currency: value.currency,
            calendar: value.calendar,
          );
          transactions.add(newTransaction);
          data.deleteTransaction(obsoleteTransaction);
          data.saveTransaction(newTransaction);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_UPDATE,
                request_obsoleteUUID: obsoleteTransaction.uuid,
                TRN: newTransaction.toJson(),
              },
            );
          }
          break;
        case action_DELETE:
          transactions.remove(value);
          data.deleteTransaction(value);
          setLayout();
          if(!(showSnackBar!=null && !showSnackBar)) {
            snackbarNotifier.value = SnackBar(
              content: Text("Transaction removed"),
              action: SnackBarAction(
                label: "UNDO",
                onPressed: () => act(value, action_INSERT),
                textColor: snackBarAction,
              ),
            );
          }
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_DELETE,
                TRN: [value.uuid],
              },
            );
          }
          break;
      }
      break;
    case Entry:
      switch(action){
        case action_INSERT:
          entries.add(value);
          data.saveEntry(value);
          manageNotification(value);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_ADD,
                ENT: [value.toJson()],
              },
            );
          }
          break;
        case action_UPDATE:
          Entry obsoleteEntry = entries.firstWhere((entry) => entry.uuid == value.uuid);
          entries.remove(obsoleteEntry);
          manageNotification(obsoleteEntry, delete: true);
          Entry newEntry = Entry(
            labels: value.labels,
            accUUID: value.accUUID,
            trcID: value.trcID,
            recurring: value.recurring,
            reminderCalendar: value.reminderCalendar,
          );
          entries.add(newEntry);
          manageNotification(newEntry);
          data.deleteEntry(obsoleteEntry);
          data.saveEntry(newEntry);
          setLayout();
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_UPDATE,
                request_obsoleteUUID: obsoleteEntry.uuid,
                ENT: newEntry.toJson(),
              },
            );
          }
          break;
        case action_DELETE:
          entries.remove(value);
          data.deleteEntry(value);
          manageNotification(value, delete: true);
          setLayout();
          if(showSnackBar) {
            snackbarNotifier.value = SnackBar(
              content: Text("Agenda entry removed"),
              action: SnackBarAction(
                label: "UNDO",
                onPressed: () => act(value, action_INSERT),
                textColor: snackBarAction,
              ),
            );
          }
          if(transmi){
            transmit(
              jsonData: {
                requestType_HEADER: requestType_DELETE,
                ENT: [value.uuid()],
              },
            );
          }
          break;
      }
      break;
  }
}

const int type_PERSONAL = 0;
const int type_BUSINESS = 1;

void saveDefaultAccount(){
  Account defaultAccount = Account(
    name: "Personal",
    seasoningType: Account.type_MONTHLY,
    currency: "\$",
    currencyNeedsSpace: false,
    currencySignOnRight: false,
  );
  List<TransactionCategory> cat = saveDefaultFiles(type_PERSONAL, defaultAccount.uuid);
  List<Map<String, dynamic>> categoriesJSON = List();
  cat.forEach((trc){
    categoriesJSON.add(trc.toJson());
  });
  acc.saveAccount(defaultAccount);
  accounts.add(defaultAccount);
  transmit(
    jsonData: {
      requestType_HEADER: requestType_ADD,
      ACC: [defaultAccount.toJson()],
      TRC: categoriesJSON,
    },
  );
}

List<TransactionCategory> saveDefaultFiles(int type, String accUUID){
  //ToDo add business defaults, determine type by integer ^ here
  List<TransactionCategory> defaultList = [];
  if(type==type_PERSONAL){
    defaultList = <TransactionCategory>[
      //Expenses
      TransactionCategory(accUUID: accUUID, trcID: 0, drawableID: 0, colorID: 51, label: "Kin",),
      TransactionCategory(accUUID: accUUID, trcID: 1, drawableID: 1, colorID: 34, label: "Restaurant",),
      TransactionCategory(accUUID: accUUID, trcID: 2, drawableID: 2, colorID: 6, label: "Apparel",),
      TransactionCategory(accUUID: accUUID, trcID: 3, drawableID: 3, colorID: 26, label: "Leisure",),
      TransactionCategory(accUUID: accUUID, trcID: 4, drawableID: 4, colorID: 56, label: "Transport",),
      TransactionCategory(accUUID: accUUID, trcID: 5, drawableID: 5, colorID: 18, label: "Groceries",),
      TransactionCategory(accUUID: accUUID, trcID: 6, drawableID: 6, colorID: 48, label: "Health",),
      //7
      TransactionCategory(accUUID: accUUID, trcID: 8, drawableID: 7, colorID: 1, label: "Seldom",),
      TransactionCategory(accUUID: accUUID, trcID: 9, drawableID: 8, colorID: 35, label: "Bill",),
      //10
      TransactionCategory(accUUID: accUUID, trcID: 11, drawableID: 9, colorID: 16, label: "Major",),
      //Incomes
      TransactionCategory(accUUID: accUUID, trcID: 12, drawableID: 10, colorID: 54, label: "Salary",),
      TransactionCategory(accUUID: accUUID, trcID: 17, drawableID: 11, colorID: 1, label: "Seldom",),
      TransactionCategory(accUUID: accUUID, trcID: 18, drawableID: 12, colorID: 44, label: "Rental",),
      TransactionCategory(accUUID: accUUID, trcID: 23, drawableID: 13, colorID: 39, label: "Dividend",),
    ];
  } else if(type==type_BUSINESS){
    defaultList = <TransactionCategory>[
      //Expenses
      TransactionCategory(accUUID: accUUID, trcID: 0, drawableID: 14, colorID: 51, label: "Marketing",),
      TransactionCategory(accUUID: accUUID, trcID: 2, drawableID: 8, colorID: 35, label: "Taxes",),
      TransactionCategory(accUUID: accUUID, trcID: 3, drawableID: 15, colorID: 26, label: "Contracts",),
      TransactionCategory(accUUID: accUUID, trcID: 5, drawableID: 10, colorID: 0, label: "Labor",),
      TransactionCategory(accUUID: accUUID, trcID: 6, drawableID: 13, colorID: 25, label: "Dividend",),
      TransactionCategory(accUUID: accUUID, trcID: 8, drawableID: 16, colorID: 42, label: "Utilities",),
      TransactionCategory(accUUID: accUUID, trcID: 9, drawableID: 17, colorID: 57, label: "Benefits",),
      TransactionCategory(accUUID: accUUID, trcID: 11, drawableID: 18, colorID: 16, label: "Insurance",),
      //Incomes
      TransactionCategory(accUUID: accUUID, trcID: 12, drawableID: 19, colorID: 37, label: "Gains",),
      TransactionCategory(accUUID: accUUID, trcID: 17, drawableID: 20, colorID: 38, label: "Revenue",),
    ];
  }
  categories.addAll(defaultList);
  data.saveCategoriesBulk(defaultList);
  return defaultList;
}