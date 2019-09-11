bool intToBool(int int){
  switch(int){
    case 0: return false;
    case 1: return true;
    default: return null;
  }
}

int boolToInt(bool bool) => bool?1:0;

DateTime millisToDate(int millis) => DateTime.fromMillisecondsSinceEpoch(millis);

const String comma = ",";

String labelsToString(List<String> labels){
  if(labels!=null) {
    String labStorage = '';
    for (int i = 0; i < labels.length; i++) {
      labStorage += labels[i];
      if (i < labels.length - 1) {
        labStorage += comma;
      }
    }
    return labStorage;
  } else {
    return null;
  }
}

List<String> stringToLabels(String labStorage){
  return labStorage.split(comma);
}