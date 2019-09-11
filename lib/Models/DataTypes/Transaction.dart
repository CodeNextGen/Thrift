import 'package:flutter/material.dart';

import 'package:thrift/Functions/GenerateUUIDv4.dart';
import 'package:thrift/Functions/convertValues.dart';

class Transaction{
  static const String field_ID = "_id";
  static const String field_label = "lab";
  static const String field_value = "val";
  static const String field_currency = "cur";
  static const String field_calendar = "cal";
  static const String field_trcID = "trc";
  static const String field_accUUID = "acc";

  final String uuid;
  final String label;
  final double value;
  final String currency;
  final DateTime calendar;
  final int trcID;
  final String accUUID;

  Transaction({
    @required this.accUUID,
    @required this.trcID,
    @required this.label,
    @required this.value,
    @required this.currency,
    @required this.calendar,
    String uuid,
  }): this.uuid = uuid??generateUUID();

  Map<String, dynamic> toJson() => {
    field_ID: uuid,
    field_label: label,
    field_value: value,
    field_currency: currency,
    field_calendar: calendar.millisecondsSinceEpoch,
    field_trcID: trcID,
    field_accUUID: accUUID,
  };

  Transaction.fromJson(Map<String, dynamic> map)
      :
        this.uuid = map[field_ID],
        this.label = map[field_label],
        this.value = map[field_value],
        this.currency = map[field_currency],
        this.calendar = millisToDate(map[field_calendar]),
        this.trcID = map[field_trcID],
        this.accUUID = map[field_accUUID];
}