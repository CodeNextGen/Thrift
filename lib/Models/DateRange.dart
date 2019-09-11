import 'package:flutter/material.dart';

class DateRange{
  final String name;
  final DateTime firstDate;
  final DateTime secondDate;
  DateRange({@required this.firstDate, @required this.secondDate, @required this.name});
}