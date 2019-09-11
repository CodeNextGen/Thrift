import 'package:flutter/material.dart';

import 'package:thrift/Instances/SharedPreferences.dart';

import 'package:thrift/Functions/GenerateUUIDv4.dart';
import 'package:thrift/Functions/convertValues.dart';

class Entry{
  static const String field_ID = "_id";
  static const String field_labels = "lab";
  static const String field_accUUID = "acc";
  static const String field_trcID = "trc";
  static const String field_recurring = "rec";

  final String uuid;
  final List<String> labels;
  final DateTime reminderCalendar;
  final String accUUID;
  final int trcID;
  final bool recurring;
  final int notificationID;

  Entry({
    @required this.labels,
    @required this.accUUID,
    @required this.trcID,
    @required this.recurring,
    @required this.reminderCalendar,
    int notificationID,
    String uuid,
  }):this.uuid = uuid??generateUUID(), this.notificationID = notificationID??genNextNotificationID();

  Map<String, dynamic> toJson() => {
    field_ID: uuid,
    field_labels: labels,
    field_accUUID: accUUID,
    field_trcID: trcID,
    field_recurring: boolToInt(recurring),
  };

  Entry.fromJson(Map<String, dynamic> map)
      :
        this.uuid = map[field_ID],
        this.labels = map[field_labels],
        this.reminderCalendar = null,
        this.accUUID = map[field_accUUID],
        this.trcID = map[field_trcID],
        this.recurring = intToBool(map[field_recurring]),
        this.notificationID = null;

  static int genNextNotificationID(){
    const String prefs_notificationID= "NotificationID";
    int currentID = sharedPreferences.getInt(prefs_notificationID)??0;
    sharedPreferences.setInt(prefs_notificationID, currentID+1);
    return currentID;
  }
}
