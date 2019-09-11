import 'dart:math';

String generateUUID(){
  const int byteMaxInt = 256;
  const int hexRadix = 16;
  const String padZero = "0";
  const int byteStringLength = 2;

  String uuid = "";
  Random random;
  try {random = Random.secure();} catch (e){random = Random();}
  for(int i=0; i<16; i++){uuid+=random.nextInt(byteMaxInt).toRadixString(hexRadix).padLeft(byteStringLength, padZero);}
  return uuid;
}