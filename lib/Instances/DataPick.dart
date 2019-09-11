import 'package:flutter/material.dart';

import 'package:thrift/Models/DataTypes/Account.dart';
import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/DataTypes/Entry.dart';

import 'package:thrift/Models/DateRange.dart';

List<Transaction> transactions;
List<TransactionCategory> categories;
List<Entry> entries;
List<Account> accounts;
ValueNotifier<CurrentDataPick> currentDataPickNotifier;

class CurrentDataPick{
  final DateRange dateRange;
  final Account account;
  final List<Transaction> transactions;
  final List<Entry> entries;
  final List<TransactionCategory> categories;
  CurrentDataPick({
    @required this.dateRange,
    @required this.account,
    @required this.transactions,
    @required this.entries,
    @required this.categories,
  });
}