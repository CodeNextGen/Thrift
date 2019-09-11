import 'package:flutter/material.dart';

import 'package:thrift/Functions/GenerateUUIDv4.dart';

class TransactionCategory{
  static const String field_ID = "_id";
  static const String field_drawableID = "dra";
  static const String field_colorID = "col";
  static const String field_label = "lab";
  static const String field_trcID = "trc";
  static const String field_accUUID = "acc";

  final String uuid;
  final int drawableID;
  final int colorID;
  final String label;
  final int trcID;
  final String accUUID;

  TransactionCategory({
    @required this.accUUID,
    @required this.trcID,
    @required this.drawableID,
    @required this.colorID,
    @required this.label,
    String uuid,
  }): this.uuid = uuid??generateUUID();

  Map<String, dynamic> toJson() => {
    field_ID: uuid,
    field_drawableID: drawableID,
    field_colorID: colorID,
    field_label: label,
    field_trcID: trcID,
    field_accUUID: accUUID,
  };

  TransactionCategory.fromJson(Map<String, dynamic> map)
      :
        this.uuid = map[field_ID],
        this.drawableID = map[field_drawableID],
        this.colorID = map[field_colorID],
        this.label = map[field_label],
        this.trcID = map[field_trcID],
        this.accUUID = map[field_accUUID];
}