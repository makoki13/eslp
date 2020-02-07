import 'dart:convert';

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import './rwgps.dart';
import 'usuario.dart';
import 'web_server.dart';

import 'package:eslp_console/eslp_console.dart' as eslp_console;


class Salidas {
  Future<Object> abreBaseDeDatos() async {
    var baseDeDatos = 'salidas.db';
    var dbFactory = databaseFactoryIo;

    // open the database. We use the database factory to open the database
    var db = await dbFactory.openDatabase(baseDeDatos);
    return db;
  }

  Future<bool> estaRegistrada(
      DatabaseClient db, Usuario usuario, String salida) async {
    var store = StoreRef.main();

    var idUsuario = usuario.getUsuario();
    var clave = idUsuario + '###' + salida;
    eslp_console.sendLog(clave, '[#2c1]');

    var title = await store.record(clave).get(db) as String;
    eslp_console.sendLog((title != null), '[#2c2]');

    return title != null;    
  }

/* Devuelve true si ha habido algún cambio en la lista de hitos */
  Future<bool> procesa(var db, Usuario usuario, String salida) async {
    //Guarda en la tabla de salidas por usuario
    var idUsuario = usuario.getUsuario();

    var store = StoreRef.main();
    var clave = idUsuario + '###' + salida;
    var listaPuntos = <Coordenadas>[];
    
    await store.record(clave).put(db, 'XXXXX');
    eslp_console.sendLog(clave, '[#2d]');

    listaPuntos =  RideWithGPS.getPuntosDeSalida(salida);
    await Future.forEach(listaPuntos, (elemento) async {
      var texto = await WS.getPoblacion(elemento.getLatitud(), elemento.getLongitud());
      dynamic reg = jsonDecode(texto);
      var id = reg['id'].toString().substring(0,5);
      
      await usuario.procesaLocalidad(id);

      eslp_console.sendLog(id, '[#id]');
    });

    return true;
  }

  Future<bool> procesaSalida(db, usuario, elemento) async {
    var hayCambios = false;
    if (await estaRegistrada(db, usuario, elemento) == false) {
      // Procesar salida
      hayCambios = await procesa(db, usuario, elemento);
      eslp_console.sendLog(hayCambios, '[#2b]');
    }

    return hayCambios;
  }

  Future<bool> recorreVector(db, Usuario usuario, Iterable<String> listaSalidas) async {
    var hayCambios = false;
    var hayNuevoCambio = false;

    await Future.forEach(listaSalidas, (elemento) async {
      eslp_console.sendLog(elemento, '[#2a]');
      hayNuevoCambio = await procesaSalida(db, usuario, elemento);
      hayCambios = hayCambios || hayNuevoCambio;
      eslp_console.sendLog(hayCambios, '[#2c]');
      eslp_console.sendLog('--------------', '');
    });

    return hayCambios;
  }
}
