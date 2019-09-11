import 'package:flutter/material.dart';

import 'package:thrift/Functions/GenerateUUIDv4.dart';
import 'package:thrift/Functions/convertValues.dart';

class Account{
  static const String field_ID = "_id";
  static const String field_seasoningType = "sea";
  static const String field_name = "nam";
  static const String field_currency = "cur";
  static const String field_currencySignOnRight = "sig";
  static const String field_currencyNeedsSpace = "spa";


  static const int type_MONTHLY = 0;
  static const int type_SEASONALLY = 1;
  static const int type_QUARTERLY = 2;

  final String uuid;
  final int seasoningType;
  final String name;
  final String currency;
  final bool currencySignOnRight;
  final bool currencyNeedsSpace;

  Account({
    @required this.name,
    @required this.seasoningType,
    @required this.currency,
    @required this.currencySignOnRight,
    @required this.currencyNeedsSpace,
    String uuid,
  }): this.uuid = uuid??generateUUID();

  Map<String, dynamic> toJson() => {
    field_ID: uuid,
    field_name: name,
    field_seasoningType: seasoningType,
    field_currency: currency,
    field_currencyNeedsSpace: boolToInt(currencyNeedsSpace),
    field_currencySignOnRight: boolToInt(currencySignOnRight),
  };

  Account.fromJson(Map<String, dynamic> map)
      :
        this.uuid = map[field_ID],
        this.seasoningType = map[field_seasoningType],
        this.name = map[field_name],
        this.currency = map[field_currency],
        this.currencySignOnRight = intToBool(map[field_currencySignOnRight]),
        this.currencyNeedsSpace = intToBool(map[field_currencyNeedsSpace]);
}