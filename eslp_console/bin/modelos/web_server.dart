import 'dart:convert';
import 'package:http/http.dart' as http;

class WS {
  static Future<dynamic> sendRequest(url) {
    //print ('URL: ${url}');

    return http.get(url).catchError((err) {      
      return {'error': '${err}'};
    }).then((resp) {      
      dynamic reg = jsonDecode(resp.body);
      return reg;
    });

  }

  static Future<String> getPoblacion(longitud, latitud) async {
    var url =
        'http://www.cartociudad.es/geocoder/api/geocoder/reverseGeocode?lon=' +
            longitud +
            '&lat=' +
            latitud +
            '&type=codpostal';
    var resp = await http.read(url);
    return resp;
  }
}
