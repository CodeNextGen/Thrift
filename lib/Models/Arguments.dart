import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/Entry.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

class Arguments{
  final TransactionCategory transactionCategory;
  final Transaction transaction;
  final Entry entry;

  Arguments({
    this.transactionCategory,
    this.transaction,
    this.entry,
  });
}