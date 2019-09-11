import 'package:flutter/material.dart';
import 'package:thrift/Models/DataTypes/Account.dart';

class ObsoleteAccount{
  final Account account;
  final int obsoleteID;
  ObsoleteAccount({@required this.account, @required this.obsoleteID});
}

List<ObsoleteAccount> obsoleteAccounts;