import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:thrift/Models/DataTypes/Entry.dart';
import 'package:thrift/Models/DataTypes/TransactionCategory.dart';

import 'package:thrift/Instances/DataPick.dart';

import 'package:thrift/SQFLite/ObsoleteBuffer.dart';

const String notificationIcon = "notification_icon";

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin()
  ..initialize(InitializationSettings(AndroidInitializationSettings(notificationIcon), IOSInitializationSettings()));

const String channelID = "rm";
const String channelName = "Reminders";
const String channelDescription = "All the reminders you set for your purchase agenda";

final NotificationDetails details = NotificationDetails(
//ANDROID
  AndroidNotificationDetails(
    channelID,
    channelName,
    channelDescription,
    importance: Importance.High,
    priority: Priority.High,
  ),
//IOS
  IOSNotificationDetails(),
);

Future<void> manageNotification(Entry entry, {bool delete, List<TransactionCategory> cats}) async {
  await cancelNotification(entry.notificationID);
  if(delete!=true){
    DateTime calendar = entry.reminderCalendar!=null?entry.reminderCalendar.toLocal():null;
    if(calendar!=null && calendar.isAfter(DateTime.now())){
      await flutterLocalNotificationsPlugin.schedule(
        entry.notificationID,
        'Reminder for category: ${categories??cats.firstWhere((trc) => trc.accUUID == entry.accUUID && trc.trcID == entry.trcID).label}',
        'Account: ${accounts!=null && accounts.isNotEmpty?accounts.firstWhere((acc) => acc.uuid == entry.accUUID).name:obsoleteAccounts.firstWhere((obs) => obs.account.uuid == entry.accUUID).account.name}',
        calendar,
        details,
        payload: "${entry.accUUID}.${entry.notificationID}"
      );
    }
  }
}

Future<void> cancelNotification(int notificationID) async {
  await flutterLocalNotificationsPlugin.cancel(notificationID);
}