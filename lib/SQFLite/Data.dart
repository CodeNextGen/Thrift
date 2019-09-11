import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import 'package:thrift/SQFLite/ObsoleteBuffer.dart';
import 'package:thrift/SQFLite/Accounts.dart';

import 'package:thrift/Functions/manageNotification.dart';

import 'package:thrift/Functions/convertValues.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/DataTypes/Transaction.dart' as tr;
import 'package:thrift/Models/DataTypes/Entry.dart';

class Data{
  static const String filename = "AccountRegulator"; final int version;
  
  static const String table_Transactions = "trn";
  static const String table_Categories = "trc";
  static const String table_Entries = "ent";

  static const String field_uuid = "uid";
  static const String field_label = "lab";
  static const String field_value = "val";
  static const String field_currency = "cur";
  static const String field_calendar = "cal";
  static const String field_trcID = "tid";
  static const String field_accUUID = "aid";
  static const String field_labels = "lbs";
  static const String field_colorID = "col";
  static const String field_drawableID = "dra";
  static const String field_notificationID = "ntf";
  static const String field_reminderCalendar = "rem";
  static const String field_recurring = "rec";

  Data({@required this.version});

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
    var db = await openDatabase(
      path,
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
    return db;
  }

  onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $table_Categories($field_uuid TEXT PRIMARY KEY, $field_drawableID INTEGER, $field_colorID INTEGER, $field_label TEXT, $field_trcID INTEGER, $field_accUUID STRING)");
    await db.execute("CREATE TABLE $table_Transactions($field_uuid TEXT PRIMARY KEY, $field_label TEXT, $field_value REAL, $field_currency TEXT, $field_calendar INTEGER, $field_trcID INTEGER, $field_accUUID TEXT)");
    await db.execute("CREATE TABLE $table_Entries($field_uuid TEXT PRIMARY KEY, $field_labels TEXT, $field_reminderCalendar INTEGER, $field_accUUID TEXT, $field_trcID INTEGER, $field_recurring INTEGER, $field_notificationID INTEGER)");
  }

  onUpgrade(Database db, int oldVersion, int newVersion) async {
    int versionStepper = oldVersion;
    while(versionStepper<newVersion){
      switch(versionStepper){
        case 1:
          await db.execute("ALTER TABLE TransactionCategories RENAME TO obsoleteCategories");
          await db.execute("CREATE TABLE TransactionCategories(id INTEGER PRIMARY KEY, accID INTEGER, trcID INTEGER, label TEXT, drawableID INTEGER, colorID INTEGER)");
          await db.execute("INSERT INTO TransactionCategories SELECT id, accID, trcID, label, drawableID, colorID FROM obsoleteCategories");
          await db.execute("DROP TABLE obsoleteCategories");
          break;
        case 2:
          const ONETIME = -1;
          List<Map<String, dynamic>> obsoleteEntries = await db.rawQuery("SELECT * FROM Entries");
          await db.execute("DROP TABLE Entries");
          await db.execute("CREATE TABLE Entries(id INTEGER PRIMARY KEY, trcID INTEGER, accID INTEGER, labels TEXT, reminderCalendar INTEGER, notificationID INTEGER, recurring INTEGER)");
          flutterLocalNotificationsPlugin.cancelAll();
          Future.forEach(obsoleteEntries, (obs)async{
            await db.rawInsert("INSERT INTO Entries(id, accID, notificationID, trcID, labels, recurring, reminderCalendar) VALUES (?, ?, ?, ?, ?, ?, ?)",
              [obs["id"], obs["accID"], obs["notificationID"], obs["trcID"], obs["label"], obs["type"]!=ONETIME, obs["reminderCalendar"] == -1 ? null : millisToDate(obs["reminderCalendar"])],
            );
          });
          break;
        case 3:
          flutterLocalNotificationsPlugin.cancelAll();
          if(obsoleteAccounts == null){await (await Accounts(version: 2).db).rawQuery("SELECT ${Accounts.field_uuid} From ${Accounts.dbName}");}
          List<Map<String, dynamic>> transactionsMap = await db.rawQuery("SELECT * FROM Transactions");
          List<Map<String, dynamic>> entriesMap = await db.rawQuery("SELECT * FROM Entries");
          List<Map<String, dynamic>> categoriesMap = await db.rawQuery("SELECT * FROM TransactionCategories");
          List<tr.Transaction> transactions = [];
          List<Entry> entries = [];
          List<TransactionCategory> categories = [];
          try{
          categoriesMap.forEach((map){
            categories.add(
              TransactionCategory(
                accUUID: obsoleteAccounts.firstWhere((obs) => obs.obsoleteID == map["accID"]).account.uuid,
                trcID: map["trcID"],
                drawableID: map["drawableID"],
                colorID: map["colorID"],
                label: map["label"],
              ),
            );
          });
          transactionsMap.forEach((map){
            transactions.add(
              tr.Transaction(
                accUUID: obsoleteAccounts.firstWhere((obs) => obs.obsoleteID == map["accID"]).account.uuid,
                trcID: map["trcID"],
                label: map["label"],
                value: double.parse(map["cost"]),
                currency: map["currency"],
                calendar: millisToDate(map["calendar"]),
              ),
            );
          });
          entriesMap.forEach((map){
            Entry entry = Entry(
              labels: stringToLabels(map["labels"]),
              accUUID: obsoleteAccounts.firstWhere((obs) => obs.obsoleteID == map["accID"]).account.uuid,
              trcID: map["trcID"],
              recurring: intToBool(map["recurring"]),
              reminderCalendar: map["reminderCalendar"]!=-1?millisToDate(map["reminderCalendar"]):null,
            );
            entries.add(entry);
            manageNotification(entry, cats: categories);
          });
          } catch(e){
            print(e);
          }
          await db.rawQuery("DROP TABLE Transactions");
          await db.rawQuery("DROP TABLE Entries");
          await db.rawQuery("DROP TABLE TransactionCategories");
          await onCreate(db, version);
          await saveCategoriesBulk(categories, updatingDB: db);
          await saveEntriesBulk(entries, updatingDB: db);
          await saveTransactionsBulk(transactions, updatingDB: db);
          break;
      }
      versionStepper+=1;
    }
  }

  Future<void> deleteContentsOfAccount(String accUUID) async {
    await (await db).rawDelete("DELETE FROM $table_Categories WHERE $field_accUUID = \"$accUUID\"");
    await (await db).rawDelete("DELETE FROM $table_Entries WHERE $field_accUUID = \"$accUUID\"");
    await (await db).rawDelete("DELETE FROM $table_Transactions WHERE $field_accUUID = \"$accUUID\"");
  }

  Future<void> updateAccUUID(String obsoleteUUID, String newUUID) async {
    await (await db).transaction((txn) async {
        await txn.rawUpdate("UPDATE $table_Categories SET $field_accUUID = \"$newUUID\" WHERE $field_accUUID = \"$obsoleteUUID\"");
        await txn.rawUpdate("UPDATE $table_Entries SET $field_accUUID = \"$newUUID\" WHERE $field_accUUID = \"$obsoleteUUID\"");
        await txn.rawUpdate("UPDATE $table_Transactions SET $field_accUUID = \"$newUUID\" WHERE $field_accUUID = \"$obsoleteUUID\"");
      },
    );
  }

  Future<void> deleteContentsOfCategory(int trcID, String accUUID) async {
    await (await db).rawDelete("DELETE FROM $table_Categories WHERE $field_accUUID = \"$accUUID\" AND $field_trcID = \"$trcID\"");
    await (await db).rawDelete("DELETE FROM $table_Entries WHERE $field_accUUID = \"$accUUID\" AND $field_trcID = \"$trcID\"");
    await (await db).rawDelete("DELETE FROM $table_Transactions WHERE $field_accUUID = \"$accUUID\" AND $field_trcID = \"$trcID\"");
  }

  /*
  _______  _____    _____
 |__   __||  __ \  / ____|
    | |   | |__) || |
    | |   |  _  / | |
    | |   | | \ \ | |____
    |_|   |_|  \_\ \_____|

  */

  Future<List<TransactionCategory>> getCategories() async {
    List<TransactionCategory> categories = [];
    for(Map<String, dynamic> map in await (await db).rawQuery("SELECT * FROM $table_Categories")){
      categories.add(
        TransactionCategory(
          accUUID: map[field_accUUID],
          trcID: map[field_trcID],
          drawableID: map[field_drawableID],
          colorID: map[field_colorID],
          label: map[field_label],
          uuid: map[field_uuid],
        ),
      );
    }
    return categories;
  }

  Future deleteCategory(String uuid) async => await (await db).rawDelete("DELETE FROM $table_Categories WHERE $field_uuid = \"$uuid\"");

  Future saveCategory(TransactionCategory category) async =>
      await (await db).rawInsert(
        "INSERT INTO $table_Categories($field_uuid, $field_drawableID, $field_colorID, $field_label, $field_trcID, $field_accUUID) VALUES(?, ?, ?, ?, ?, ?)",
        [category.uuid, category.drawableID, category.colorID, category.label, category.trcID, category.accUUID],
      );

  Future updateCategory(TransactionCategory category) async =>
      await (await db).rawUpdate(
        "UPDATE $table_Categories SET $field_accUUID = ?, $field_drawableID = ?, $field_colorID = ?, $field_label = ?, WHERE $field_uuid = \"${category.uuid}\"",
        [category.accUUID, category.drawableID, category.colorID, category.label],
      );

  Future saveCategoriesBulk(List<TransactionCategory> categories, {Database updatingDB, Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(categories, (category) async {
        await txn.rawInsert(
          "INSERT INTO $table_Categories($field_uuid, $field_drawableID, $field_colorID, $field_label, $field_trcID, $field_accUUID) VALUES(?, ?, ?, ?, ?, ?)",
          [category.uuid, category.drawableID, category.colorID, category.label, category.trcID, category.accUUID],
        );
      });
    } else {
      await (updatingDB??(await db)).transaction((txn) async {
        await Future.forEach(categories, (category) async {
          await txn.rawInsert(
            "INSERT INTO $table_Categories($field_uuid, $field_drawableID, $field_colorID, $field_label, $field_trcID, $field_accUUID) VALUES(?, ?, ?, ?, ?, ?)",
            [category.uuid, category.drawableID, category.colorID, category.label, category.trcID, category.accUUID],
          );
        });
      });
    }
  }

  Future<void> deleteCategoriesBulk(List<String> uuids, {Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(uuids, (uuid) async {
        await txn.rawDelete("DELETE FROM $table_Categories WHERE $field_uuid = \"$uuid\"");
      });
    } else {
      await (await db).transaction((txn) async {
        await Future.forEach(uuids, (uuid) async {
          await txn.rawDelete("DELETE FROM $table_Categories WHERE $field_uuid = \"$uuid\"");
        });
      });
    }
  }

  /*
  _______  _____   _   _
 |__   __||  __ \ | \ | |
    | |   | |__) ||  \| |
    | |   |  _  / | . ` |
    | |   | | \ \ | |\  |
    |_|   |_|  \_\|_| \_|

  */

  Future<List<tr.Transaction>> getTransactions() async {
    List<tr.Transaction> transactions = [];
    for (Map<String, dynamic> map in await (await db).rawQuery(
        "SELECT * FROM $table_Transactions")) {
      transactions.add(
        tr.Transaction(
            accUUID: map[field_accUUID],
            trcID: map[field_trcID],
            label: map[field_label],
            value: map[field_value],
            currency: map[field_currency],
            calendar: millisToDate(map[field_calendar]),
            uuid: map[field_uuid]
        ),
      );
    }
    return transactions;
  }

  Future<void> deleteTransaction(tr.Transaction transaction) async => await (await db).rawDelete("DELETE FROM $table_Transactions WHERE $field_uuid = \"${transaction.uuid}\"");

  Future<void> saveTransaction(tr.Transaction transaction) async =>
      await (await db).rawInsert(
        "INSERT INTO $table_Transactions($field_uuid, $field_accUUID, $field_trcID, $field_label, $field_value, $field_currency, $field_calendar) VALUES(?, ?, ?, ?, ?, ?, ?)",
        [transaction.uuid, transaction.accUUID, transaction.trcID, transaction.label, transaction.value, transaction.currency, transaction.calendar.millisecondsSinceEpoch],
      );

  Future<void> updateTransaction(tr.Transaction transaction) async =>
      await (await db).rawUpdate(
        "UPDATE $table_Categories SET $field_accUUID = ?, $field_label = ?, $field_value = ?, $field_currency = ?, $field_calendar = ? WHERE $field_uuid = \"${transaction.uuid}\"",
        [transaction.accUUID, transaction.label, transaction.value, transaction.currency, transaction.calendar.millisecondsSinceEpoch],
      );

  Future<void> saveTransactionsBulk(List<tr.Transaction> transactions, {Database updatingDB, Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(transactions, (transaction) async {
        await txn.rawInsert(
          "INSERT INTO $table_Transactions($field_uuid, $field_accUUID, $field_trcID, $field_label, $field_value, $field_currency, $field_calendar) VALUES(?, ?, ?, ?, ?, ?, ?)",
          [transaction.uuid, transaction.accUUID, transaction.trcID, transaction.label, transaction.value, transaction.currency, transaction.calendar.millisecondsSinceEpoch],
        );
      });
    } else {
      await (updatingDB??(await db)).transaction((txn) async {
        await Future.forEach(transactions, (transaction) async {
          await txn.rawInsert(
            "INSERT INTO $table_Transactions($field_uuid, $field_accUUID, $field_trcID, $field_label, $field_value, $field_currency, $field_calendar) VALUES(?, ?, ?, ?, ?, ?, ?)",
            [transaction.uuid, transaction.accUUID, transaction.trcID, transaction.label, transaction.value, transaction.currency, transaction.calendar.millisecondsSinceEpoch],
          );
        });
      });
    }
  }

  Future<void> deleteTransactionsBulk(List<String> uuids, {Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(uuids, (uuid) async {
        await txn.rawDelete("DELETE FROM $table_Transactions WHERE $field_uuid = \"$uuid\"");
      });
    } else {
      await (await db).transaction((txn) async {
        await Future.forEach(uuids, (uuid) async {
          await txn.rawDelete("DELETE FROM $table_Transactions WHERE $field_uuid = \"$uuid\"");
        });
      });
    }
  }

  /*
  ______  _   _  _______
 |  ____|| \ | ||__   __|
 | |__   |  \| |   | |
 |  __|  | . ` |   | |
 | |____ | |\  |   | |
 |______||_| \_|   |_|

  */

  Future<List<Entry>> getEntries() async {
    List<Entry> entries = [];
    for(Map<String, dynamic> map in await (await db).rawQuery("SELECT * FROM $table_Entries")){
      entries.add(
        Entry(
          labels: stringToLabels(map[field_labels]),
          accUUID: map[field_accUUID],
          trcID: map[field_trcID],
          recurring: intToBool(map[field_recurring]),
          reminderCalendar: map[field_reminderCalendar] == null ? null : millisToDate(map[field_reminderCalendar]),
          uuid: map[field_uuid],
          notificationID: map[field_notificationID],
        ),
      );
    }
    return entries;
  }

  Future<void> deleteEntry(Entry entry) async => await (await db).rawDelete("DELETE FROM $table_Entries WHERE $field_uuid = \"${entry.uuid}\"");

  Future<void> saveEntry(Entry entry) async =>
      await (await db).rawInsert(
        "INSERT INTO $table_Entries($field_uuid, $field_labels, $field_accUUID, $field_trcID, $field_recurring, $field_reminderCalendar, $field_notificationID) VALUES(?, ?, ?, ?, ?, ?, ?)",
        [entry.uuid, labelsToString(entry.labels), entry.accUUID, entry.trcID, boolToInt(entry.recurring), entry.reminderCalendar == null ? null : entry.reminderCalendar.millisecondsSinceEpoch, entry.notificationID],
      );

  Future<void> updateEntry(Entry entry) async =>
      await (await db).rawUpdate(
        "UPDATE $table_Entries SET $field_accUUID = ?, $field_recurring = ?, $field_reminderCalendar = ?, $field_labels = ? WHERE $field_uuid = \"${entry.uuid}\"",
        [entry.accUUID, boolToInt(entry.recurring), entry.reminderCalendar == null ? null : entry.reminderCalendar.millisecondsSinceEpoch, labelsToString(entry.labels)],
      );

  Future<void> saveEntriesBulk(List<Entry> entries, {Database updatingDB, Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(entries, (entry) async {
        await txn.rawInsert(
          "INSERT INTO $table_Entries($field_uuid, $field_labels, $field_accUUID, $field_trcID, $field_recurring, $field_reminderCalendar, $field_notificationID) VALUES(?, ?, ?, ?, ?, ?, ?)",
          [entry.uuid, labelsToString(entry.labels), entry.accUUID, entry.trcID, boolToInt(entry.recurring), entry.reminderCalendar == null ? null : entry.reminderCalendar.millisecondsSinceEpoch, entry.notificationID],
        );
      });
    } else {
      await (updatingDB??(await db)).transaction((txn) async {
        await Future.forEach(entries, (entry) async {
          await txn.rawInsert(
            "INSERT INTO $table_Entries($field_uuid, $field_labels, $field_accUUID, $field_trcID, $field_recurring, $field_reminderCalendar, $field_notificationID) VALUES(?, ?, ?, ?, ?, ?, ?)",
            [entry.uuid, labelsToString(entry.labels), entry.accUUID, entry.trcID, boolToInt(entry.recurring), entry.reminderCalendar == null ? null : entry.reminderCalendar.millisecondsSinceEpoch, entry.notificationID],
          );
        });
      });
    }
  }

  Future<void> deleteEntriesBulk(List<String> uuids, {Transaction txn}) async {
    if(txn!=null){
      await Future.forEach(uuids, (uuid) async {
        await txn.rawDelete("DELETE FROM $table_Entries WHERE $field_uuid = \"$uuid\"");
      });
    } else {
      await (await db).transaction((txn) async {
        await Future.forEach(uuids, (uuid) async {
          await txn.rawDelete("DELETE FROM $table_Entries WHERE $field_uuid = \"$uuid\"");
        });
      });
    }
  }
}
