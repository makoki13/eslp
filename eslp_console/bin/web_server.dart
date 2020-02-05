import 'package:http/http.dart' as http;

Future<String> getPoblacion(longitud,latitud) async {
  var url = 'http://www.cartociudad.es/geocoder/api/geocoder/reverseGeocode?lon=' + longitud + '&lat=' + latitud + '&type=codpostal';
  var resp = await http.read(url);
  return resp;
}