import 'package:thrift/Instances/DataPick.dart';

const String minusSign = "-";
const String emptyString = "";
const String spaceString = " ";

String generateSumString(int value, bool abbrev){
  if(currentDataPickNotifier.value.account.currencySignOnRight){
    return
      "${value<0?minusSign:emptyString}" //no space before currency
      "${abbrev?abbreviate(value):limit(value)}" //value
      "${currentDataPickNotifier.value.account.currencyNeedsSpace?spaceString:emptyString}" //space
      "${currentDataPickNotifier.value.account.currency}" //currency
    ;
  } else {
    return
      "${value<0?minusSign:emptyString} " //with space before currency
      "${currentDataPickNotifier.value.account.currency}" //currency
      "${currentDataPickNotifier.value.account.currencyNeedsSpace?spaceString:emptyString}" //space
      "${abbrev?abbreviate(value):limit(value)}" //value
    ;
  }
}

const String billionAbbr = "bn";
const String millionAbbr = "m";
const String thousandAbbr = "k";
const int bn = 1000000000;
const int m = 1000000;
const int k = 1000;

String abbreviate(int number){
  int num = number.abs();

  if(num > bn){
    return "${num~/bn}$billionAbbr";
  } else if (num > m){
    return "${num~/m}$millionAbbr";
  } else if (num > k){
    return "${num~/k}$thousandAbbr";
  } else {
    return "$num";
  }
}

String limit(int number){
  int num = number.abs();

  if(num > bn){
    return "${num~/m}$millionAbbr";
  } else if(num > m){
    return "${num~/k}$thousandAbbr";
  } else {
    return "$num";
  }
}