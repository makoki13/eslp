import 'package:eslp_console/eslp_console.dart' as eslp_console;
import 'package:http/http.dart' as http;

void onDataLoaded(String responseText) {
  var jsonString = responseText;
  //print(jsonString);

  eslp_console.sendLog(jsonString,' respuesta');
}

void test() async {
  var url = 'http://www.cartociudad.es/geocoder/api/geocoder/reverseGeocode?lon=-0.141949&lat=38.950952&type=codpostal';

  // call the web server asynchronously
  //var request = HttpRequest.getString(url).then(onDataLoaded);
  //eslp_console.sendLog(request,' request');

  var resp = await http.read(url);
  eslp_console.sendLog(resp,' respuesta');
}

void main() {
  test();
}