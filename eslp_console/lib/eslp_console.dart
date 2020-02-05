import 'package:dson/dson.dart';

void sendLog(valor,texto) {
  var jsonString = '';
  jsonString = toJson( valor ) +  toJson( texto );
  print(jsonString);
}


