import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import 'package:thrift/Functions/convertValues.dart';

import 'package:thrift/Models/DataTypes/Account.dart';
import 'package:thrift/SQFLite/ObsoleteBuffer.dart';

class Accounts{
  static const String filename = "AccountHolder"; final int version;

  static const String dbName = "acc";

  static const String field_uuid = "uid";
  static const String field_name = "nam";
  static const String field_seasoningType = "sea";
  static const String field_currency = "cur";
  static const String field_currencySignOnRight = "sig";
  static const String field_currencyNeedsSpace = "spa";

  Accounts({@required this.version});

  Database database;
  final Lock lock = Lock();
  Future<Database> get db async {
    if (database == null) {
      await lock.synchronized(() async {
        if(database == null){
          database = await initializeDatabase();
        }
      });
    }
    return database;
  }


  initializeDatabase() async {
    String directoryPath = await getDatabasesPath();
    String path = join(directoryPath, "$filename.db");
    var db = await openDatabase(path, version: version, onCreate: onCreate, onUpgrade: onUpgrade);
    return db;
  }

  onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $dbName($field_uuid TEXT PRIMARY KEY, $field_name TEXT, $field_seasoningType INTEGER, $field_currency TEXT, $field_currencySignOnRight INTEGER, $field_currencyNeedsSpace INTEGER)");
  }

  onUpgrade(Database db, int oldVersion, int newVersion) async {
    int versionStepper = oldVersion;
    while(versionStepper<newVersion){
      switch(versionStepper){
        case 1:
          obsoleteAccounts = [];
          List<Map> list = await db.rawQuery("SELECT * FROM AccountsHolder");
          List<Account> accounts = [];
          list.forEach((map){
            Account account = Account(
              name: map["accName"],
              seasoningType: map["seasoningType"],
              currency: map["currency"],
              currencySignOnRight: intToBool(map["currencySignOnRight"]),
              currencyNeedsSpace: intToBool(map["currencyNeedsSpace"]),
            );
            accounts.add(account);
            obsoleteAccounts.add(ObsoleteAccount(account: account, obsoleteID: map["accID"]));
          });
          await db.rawQuery("DROP TABLE AccountsHolder");
          await onCreate(db, newVersion);
          await saveAccountsBulk(accounts, updatingDB: db);
          break;
      }
      versionStepper+=1;
    }
  }
  
  Future<List<Account>> getAccounts() async {
    List<Account> accounts = [];
    for(Map<String, dynamic> map in await (await db).rawQuery("SELECT * FROM $dbName")){
      accounts.add(
        Account(
          name: map[field_name],
          seasoningType: map[field_seasoningType],
          currency: map[field_currency],
          currencySignOnRight: intToBool(map[field_currencySignOnRight]),
          currencyNeedsSpace: intToBool(map[field_currencyNeedsSpace]),
          uuid: map[field_uuid],
        ),
      );
    }
    return accounts;
  }

  Future<void> deleteAccount(String uuid) async =>
      await (await db).rawDelete("DELETE FROM $dbName WHERE $field_uuid = \"$uuid\"");

  Future<void> saveAccount(Account account) async =>
      await (await db).rawInsert(
        "INSERT INTO $dbName($field_uuid, $field_name, $field_seasoningType, $field_currency, $field_currencySignOnRight, $field_currencyNeedsSpace) VALUES(?, ?, ?, ?, ?, ?)",
        [account.uuid, account.name, account.seasoningType, account.currency, boolToInt(account.currencySignOnRight), boolToInt(account.currencyNeedsSpace)],
      );

  Future<void> updateAccount(Account account) async =>
      await (await db).rawUpdate(
        "UPDATE $dbName SET $field_name = ?, $field_seasoningType = ?, $field_currency = ?, $field_currencySignOnRight = ?, $field_currencyNeedsSpace = ? WHERE $field_uuid = \"${account.uuid}\"",
        [account.name, account.seasoningType, account.currencyNeedsSpace, boolToInt(account.currencySignOnRight), boolToInt(account.currencyNeedsSpace)],
      );

  Future<void> saveAccountsBulk(List<Account> accounts, {Database updatingDB, Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(accounts, (account) async {
        await txn.rawInsert(
          "INSERT INTO $dbName($field_uuid, $field_name, $field_seasoningType, $field_currency, $field_currencySignOnRight, $field_currencyNeedsSpace) VALUES(?, ?, ?, ?, ?, ?)",
          [account.uuid, account.name, account.seasoningType, account.currency, boolToInt(account.currencySignOnRight), boolToInt(account.currencyNeedsSpace)],
        );
      });
    } else {
      await (updatingDB??(await db)).transaction((txn) async {
        await Future.forEach(accounts, (account) async {
          await txn.rawInsert(
            "INSERT INTO $dbName($field_uuid, $field_name, $field_seasoningType, $field_currency, $field_currencySignOnRight, $field_currencyNeedsSpace) VALUES(?, ?, ?, ?, ?, ?)",
            [account.uuid, account.name, account.seasoningType, account.currency, boolToInt(account.currencySignOnRight), boolToInt(account.currencyNeedsSpace)],
          );
        });
      });
    }
  }

  Future<void> deleteAccountsBulk(List<String> uuids, {Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(uuids, (uuid){
        txn.rawDelete("DELETE FROM $dbName WHERE $field_uuid = \"$uuid\"");
      });
    } else {
      await (await db).transaction((txn) async {
        await Future.forEach(uuids, (uuid){
          txn.rawDelete("DELETE FROM $dbName WHERE $field_uuid = \"$uuid\"");
        });
      });
    }
  }
}