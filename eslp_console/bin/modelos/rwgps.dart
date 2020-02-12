import 'dart:convert';

import 'package:http/http.dart' as http;

import './usuario.dart';

class Coordenadas {
  String latitud;
  String longitud;

  Coordenadas(String lat, String long) {
    latitud = lat;
    longitud = long;
  }

  String getLatitud() {
    return latitud;
  }

  String getLongitud() {
    return longitud;
  }
}

class RideWithGPS {
  static Future<String> getProvisionalKey() {
    var url =
        'https://ridewithgps.com/users/current.json?email=pablo.makoki@gmail.com&password=J0P4G3R1#beatles&apikey=testkey1&version=2';
    var resp = http.read(url).catchError((err) {
      print('Ostias Puta');
      return '-1';
    }).then((resp) {
      print('resp: ${resp}');
      dynamic reg = jsonDecode(resp);
      print(' clave: ${reg}');
      return '0';
    });

    return resp;
  }

  static Future<int> getNumSalidas() async {
    var url = 'https://ridewithgps.com/users/1336335.json';
    var resp = await http.read(url);
    dynamic reg = jsonDecode(resp);
    print(' Rsp: ${reg}');
    var numSalidas = reg['trips_included_in_totals_count'];
    if (numSalidas == null) return 0;
    print(' Rsp: ${numSalidas}');
    return numSalidas;
  }

  static Future<List<String>> getListaDeSalidas(
      Usuario usuario, int inicio, int cantidad) {
    var limite = cantidad - inicio;    
    var url =
        'https://ridewithgps.com/users/1336335/trips.json?offset=${inicio}0&limit=${limite}';
    return http.read(url).then((resp) {
      var lista = <String>[];
      dynamic listaSalidas = jsonDecode(resp);
      print('LISTA SALIDAS: ${listaSalidas}');
      if (listaSalidas.isNotEmpty) {
        listaSalidas.foreach((data) {
          var id = data['id'];
          lista.add(id);
          print(' Rsp: ${id}');
        });
      }
      return lista;
    });
  }

  static Future<List<Coordenadas>> getPuntosDeSalida(String salida) {
    var url = 'https://ridewithgps.com/trips/44080279.json';
    return http.read(url).then((resp) {
      dynamic reg = jsonDecode(resp);
      print(' Rsp: ${reg}');
      var listaCoordenadas = reg['track_points'];

      var lista = <Coordenadas>[];

      listaCoordenadas.foreach((data) {
        var coordenada = Coordenadas(data['x'], data['y']);
        lista.add(coordenada);
      });

      return lista;
    });
  }
}
