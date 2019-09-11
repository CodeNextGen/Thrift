import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:convert';

import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/Models/DataTypes/TransactionCategory.dart';
import 'package:thrift/Models/DataTypes/Transaction.dart';
import 'package:thrift/Models/DataTypes/Account.dart';
import 'package:thrift/Models/DataTypes/Entry.dart';

import 'package:thrift/Functions/Fetch.dart';

const String product_ID = "thrift_premium";

const String jwtHeader = "JWT";
const String purchaseTokenHeader = "TOK";
const String deviceHeader = "DVC";
const String emailHeader = "ema";
const String passwordHeader = "pwd";
const String codeHeader = "cod";

const String requestType_HEADER = "typ";
const String requestType_COMPARE = "com";
const String requestType_ADD = "add";
const String requestType_DELETE = "del";
const String requestType_UPDATE = "upd";

const String TRN = "trn";
const String TRC = "trc";
const String ACC = "acc";
const String ENT = "ent";
const String request_obsoleteUUID = "obu";

const String versionHeader = "vhd";

FlutterSecureStorage secureStorage = FlutterSecureStorage();

class AuthData{
  static const String version = "0";
  static Future<AuthData> fromMemory() async =>
      AuthData(
        subscribed: null,
        signature: await secureStorage.read(key: jwtHeader),
        purchaseToken: await secureStorage.read(key: purchaseTokenHeader),
      );

  bool subscribed;
  String signature;
  String purchaseToken;

  Map<String, String> get headers => {
    versionHeader: version,
    jwtHeader: signature,
    purchaseTokenHeader: purchaseToken,
  };

  AuthData({@required this.subscribed, @required this.signature, @required this.purchaseToken});
}

void updateAuthData({bool subscribed, String signature, String purchaseToken}){
  if(signature!=null){secureStorage.write(key: jwtHeader, value: signature);}
  if(purchaseToken!=null){secureStorage.write(key: purchaseTokenHeader, value: purchaseToken);}
  authDataNotifier.value =  AuthData(
    subscribed: subscribed ?? authDataNotifier.value.subscribed,
    signature: signature ?? authDataNotifier.value.signature,
    purchaseToken: purchaseToken ?? authDataNotifier.value.purchaseToken,
  );
  synchronize();
}

ValueNotifier<int> syncNotifier = ValueNotifier(sync_synchronized);

const int sync_synchronized = 0;
const int sync_background = 1;
const int sync_foreground = 2;

Future<void> synchronize({int state = sync_background}) async {
  List<String> trcUUIDs = List();
  List<String> trnUUIDs = List();
  List<String> entUUIDs = List();
  List<String> accUUIDs = List();

  categories.forEach((unit) => trcUUIDs.add(unit.uuid));
  transactions.forEach((unit) => trnUUIDs.add(unit.uuid));
  entries.forEach((unit) => entUUIDs.add(unit.uuid));
  accounts.forEach((unit) => accUUIDs.add(unit.uuid));

  syncNotifier.value = state;
  await transmit(
    jsonData: {
      requestType_HEADER: requestType_COMPARE,
      TRN: trnUUIDs,
      TRC: trcUUIDs,
      ENT: entUUIDs,
      ACC: accUUIDs,
    },
  );
  syncNotifier.value = sync_synchronized;
}

Future<void> checkSubscription() async {
  if(await InAppPurchaseConnection.instance.isAvailable()) {
    final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
    if(response.error == null){
      bool subscribed = false;
      String purchaseToken;
      response.pastPurchases.forEach((PurchaseDetails details){
        if(details.productID==product_ID){
          subscribed = true;
          purchaseToken = details.verificationData.serverVerificationData;
        }
      });
      updateAuthData(purchaseToken: purchaseToken, subscribed: subscribed);
    }
  }
}

ValueNotifier<AuthData> authDataNotifier;

Future<int> transmit({
  Map<String, dynamic> jsonData,
  Map<String, String> headers,
  bool mayHaveJWT = false,
}) async {
  const String url = "https://darkandjeweled.com";
  if(headers !=null || (authDataNotifier.value!=null && authDataNotifier.value.subscribed!=null && authDataNotifier.value.subscribed && authDataNotifier.value.signature != null)){
    Response response = await post(url, headers: headers??authDataNotifier.value.headers, body: jsonData!=null?jsonEncode(jsonData):null);
    debugPrint(jsonData.toString());
    print("====================================");
    debugPrint(response.headers.toString());
    debugPrint(response.body);
    if(mayHaveJWT){
      if(response.body!=null && response.body.isNotEmpty){
        print(response.body);
        updateAuthData(signature: response.body);
      }
    }

    if(jsonData!=null && jsonData[requestType_HEADER] == requestType_COMPARE && response.statusCode == 200){
      const String respond_unMentionedIDs = "unm";
      const String respond_unStoredIDs = "uns";
      const String respond_deletedIDs = "del";

      if(response.body!=null && response.body.isNotEmpty){
        Map<String, dynamic> responseData = jsonDecode(response.body);

        await (await data.db).transaction((txn) async {
          List<Transaction> transacti = List();
          List<Entry> entri = List();
          List<TransactionCategory> categori = List();

          //ToDo check if there are conflicting accounts and/or categories. trust API over it.

          if(responseData["$respond_unMentionedIDs$TRN"]!=null){
            List<Map<String, dynamic>> unMentionedList = List<Map<String, dynamic>>.from(responseData["$respond_unMentionedIDs$TRN"]);
            if(unMentionedList.isNotEmpty){
              unMentionedList.forEach((map) => transacti.add(Transaction.fromJson(map)));
            }
          }

          if(responseData["$respond_unMentionedIDs$ENT"]!=null){
            List<Map<String, dynamic>> unMentionedList = List<Map<String, dynamic>>.from(responseData["$respond_unMentionedIDs$ENT"]);
            if(unMentionedList.isNotEmpty){
              unMentionedList.forEach((map) => entri.add(Entry.fromJson(map)));
            }
          }

          if(responseData["$respond_unMentionedIDs$TRC"]!=null){
            List<Map<String, dynamic>> unMentionedList = List<Map<String, dynamic>>.from(responseData["$respond_unMentionedIDs$TRC"]);
            if(unMentionedList.isNotEmpty){
              unMentionedList.forEach((map) => categori.add(TransactionCategory.fromJson(map)));
            }
          }

          categories.addAll(categori);
          transactions.addAll(transacti);
          entries.addAll(entri);

          await data.saveCategoriesBulk(categori, txn: txn);
          await data.saveEntriesBulk(entri, txn: txn);
          await data.saveTransactionsBulk(transacti, txn: txn);

          List<String> deletedTransactionIDs = List();
          List<String> deletedCategoryIDs = List();
          List<String> deletedEntryIDs = List();

          if(responseData["$respond_deletedIDs$TRN"]!=null){
            deletedTransactionIDs = List<String>.from(responseData["$respond_deletedIDs$TRN"]);
          }

          if(responseData["$respond_deletedIDs$TRC"]!=null){
            deletedCategoryIDs = List<String>.from(responseData["$respond_deletedIDs$TRC"]);
          }

          if(responseData["$respond_deletedIDs$ENT"]!=null){
            deletedEntryIDs = List<String>.from(responseData["$respond_deletedIDs$ENT"]);
          }

          await data.deleteCategoriesBulk(deletedCategoryIDs, txn: txn);
          await data.deleteTransactionsBulk(deletedTransactionIDs, txn: txn);
          await data.deleteEntriesBulk(deletedEntryIDs, txn: txn);

        });

        await (await acc.db).transaction((txn) async {
          List<Account> accou = List();
          if(responseData["$respond_unMentionedIDs$ACC"]!=null){
            List<Map<String, dynamic>> unMentionedList = List<Map<String, dynamic>>.from(responseData["$respond_unMentionedIDs$ACC"]);
            if(unMentionedList.isNotEmpty){
              unMentionedList.forEach((map) => accou.add(Account.fromJson(map)));
            }
          }
          accounts.addAll(accou);
          await acc.saveAccountsBulk(accou, txn: txn);

          List<String> deletedAccountIDs = List();

          if(responseData["$respond_deletedIDs$ACC"]!=null){
            deletedAccountIDs = List<String>.from(responseData["$respond_deletedIDs$ACC"]);
          }

          await acc.deleteAccountsBulk(deletedAccountIDs, txn: txn);
        });

        List<String> unStoredTransactionIDs = List();
        List<String> unStoredCategoryIDs = List();
        List<String> unStoredEntryIDs = List();
        List<String> unStoredAccountIDs = List();

        if(responseData["$respond_unStoredIDs$TRN"]!=null){
          unStoredTransactionIDs = List<String>.from(responseData["$respond_unStoredIDs$TRN"]);
        }

        if(responseData["$respond_unStoredIDs$ENT"]!=null){
          unStoredEntryIDs = List<String>.from(responseData["$respond_unStoredIDs$ENT"]);
        }

        if(responseData["$respond_unStoredIDs$TRC"]!=null){
          unStoredCategoryIDs = List<String>.from(responseData["$respond_unStoredIDs$TRC"]);
        }

        if(responseData["$respond_unStoredIDs$ACC"]!=null){
          unStoredAccountIDs = List<String>.from(responseData["$respond_unStoredIDs$ACC"]);
        }
        
        List<Map<String, dynamic>> unStoredTransactions = List();
        List<Map<String, dynamic>> unStoredEntries = List();
        List<Map<String, dynamic>> unStoredCategories = List();
        List<Map<String, dynamic>> unStoredAccounts = List();

        unStoredTransactionIDs.forEach((uuid){
          Transaction trn = transactions.firstWhere((unit) => unit.uuid == uuid, orElse: ()=>null);
          if(trn!=null){
            unStoredTransactions.add(trn.toJson());
          }
        });

        unStoredEntryIDs.forEach((uuid){
          Entry ent = entries.firstWhere((unit) => unit.uuid == uuid, orElse: ()=>null);
          if(ent!=null){
            unStoredEntries.add(ent.toJson());
          }
        });

        unStoredCategoryIDs.forEach((uuid){
          TransactionCategory category = categories.firstWhere((unit) => unit.uuid == uuid, orElse: ()=>null);
          if(category!=null){
            unStoredCategories.add(category.toJson());
          }
        });

        unStoredAccountIDs.forEach((uuid){
          Account account = accounts.firstWhere((unit) => unit.uuid == uuid, orElse: ()=>null);
          if(account!=null){
            unStoredAccounts.add(account.toJson());
          }
        });

        print("Sending unstored. recieved this: ");
        print(await transmit(
          jsonData: ({
            requestType_HEADER: requestType_ADD,
            TRN: unStoredTransactions,
            ENT: unStoredEntries,
            TRC: unStoredCategories,
            ACC: unStoredAccounts,
          }),
        ));
      }
    }
    return response.statusCode;
  }
  return null;
}

class HttpStatus {
  static const int processing = 102;
  static const int ok = 200;
  static const int noContent = 204;
  static const int resetContent = 205;
  static const int found = 302;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int paymentRequired = 402;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int notAcceptable = 406;
  static const int requestTimeout = 408;
  static const int conflict = 409;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}