import 'dart:convert';

import 'package:http/http.dart' as http;

import 'web_server.dart';
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
  static final String _apikey = '824e0ab1';
  static String _authToken;
  static final int _versionAPI = 2;
  static final _tiempoEntrePuntos = 0;

  static void init() {
    _authToken = '54e40ca820e6e6434b2249c8b527e3b3';
  }
  
  static Future<String> getProvisionalKey() {
    //var url =
    //    'https://ridewithgps.com/users/current.json?email=pablo.makoki@gmail.com&password=J0P4G3R1#beatles&apikey=${_apikey}&version=2';
    //var url =
    //    'https://ridewithgps.com/users/current.json?email=pablo.makoki@gmail.com&password=J0P4G3R1#beatles&apikey=${_apikey}';
   
    var url =
        'https://ridewithgps.com/users/current.json';   
    //var parametros =  {'email': 'pablo.makoki@gmail.com', 'password': 'J0P4G3R1#beatles', 'apikey': '824e0ab1', 'version': '2', 'auth_token': '54e40ca820e6e6434b2249c8b527e3b3' };    
    var parametros =  {'email': 'pablo.makoki@gmail.com', 'password': 'J0P4G3R1#beatles', 'apikey': '824e0ab1', 'version': '2'};    
    
    var resp = http.get(url, headers: parametros).catchError((err) {
      print('Ostias Puta ${err}');
      return '-1';
    }).then((resp) {      
      print('resp 1: ${resp.headers}');
      print('resp 2: ${resp.statusCode}');    
      return '0';
    });

    return resp;
  }

  static Future<int> getNumSalidas() async {        
    var url = 'https://ridewithgps.com/users/1336335.json?auth_token=${_authToken}&apikey=${_apikey}&version=${_versionAPI}';
    
    var cadenaJSON = await WS.sendRequest(url);    
    if (cadenaJSON['error'] != null) {
      print ('ERROR: ${cadenaJSON['error']}');
      return 0;
    }
    
    var numSalidas = cadenaJSON['user']['trips_included_in_totals_count'];
    if (numSalidas == null) return 0;
      
    return numSalidas;    
  }

  static Future<List<String>> getListaDeSalidas(
      Usuario usuario, int inicio, int cantidad) {
    var limite = cantidad - inicio;    
    var url =
        'https://ridewithgps.com/users/1336335/trips.json?offset=${inicio}0&limit=${limite}&auth_token=${_authToken}&apikey=${_apikey}&version=${_versionAPI}';
    return http.read(url).then((resp) {
      var lista = <String>[];
      dynamic listaSalidas = jsonDecode(resp);      
      if (listaSalidas['results'].isNotEmpty) {                
        //print ('ELEM: ${listaSalidas['results'].length}');
        //print ('ELEM: ${listaSalidas}');
        for (var i = 0; i < listaSalidas['results'].length; i++) {                  
          var id = listaSalidas['results'][i]['id'];          
          /*
          if (id.toString().trim() == '43182876') {
            print ('ELEM: ${id}');
            lista.add(id.toString());
          }
          */
          lista.add(id.toString());          
        };        
      }
      return lista;
    });
  }

  static Future<List<Coordenadas>> getPuntosDeSalida(String salida) async {
    var tiempoAnterior = 0;
    var diferenciaTiempo;
    var url = 'https://ridewithgps.com/trips/${salida}.json?auth_token=${_authToken}&apikey=${_apikey}&version=${_versionAPI}';
    var cadenaJSON = await WS.sendRequest(url);    
    if (cadenaJSON['error'] != null) {
      print ('ERROR: ${cadenaJSON['error']}');
      return null;
    }

    var listaCoordenadas = cadenaJSON['trip']['track_points'];
    
    //print ('CJSON: ${cadenaJSON}');


    var lista = <Coordenadas>[];

    for (var i = 0; i < listaCoordenadas.length; i++) { 
      var data = listaCoordenadas[i];      
      if ( (data['x'].toString().trim() != '') && (data['y'].toString().trim() != '') && (data['x'] != null) && (data['y'] != null)   ) {
        var tiempo = data['t'];
        diferenciaTiempo = tiempo - tiempoAnterior;
        if ( (diferenciaTiempo >  _tiempoEntrePuntos) || (i == 0) )  {
          //print ('Punto ${i} de ${listaCoordenadas.length}');
          tiempoAnterior = tiempo;
          //print ('data x ${data['x'].toString()} - data y ${data['y'].toString()}');
          var coordenada = Coordenadas(data['x'].toString(), data['y'].toString());
          lista.add(coordenada); 
        }        
      }      
     }

    /*
    listaCoordenadas.foreach((data) {
      var coordenada = Coordenadas(data['x'], data['y']);
      lista.add(coordenada);
    });
    */

    return lista;

    /*
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
    */
  }
}
