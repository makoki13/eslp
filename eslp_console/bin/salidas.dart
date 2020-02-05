
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'package:eslp_console/eslp_console.dart' as eslp_console;

Future<Object> abreBaseDeDatos() async {
  var baseDeDatos = 'salidas.db';
  var dbFactory = databaseFactoryIo;
    
  // open the database. We use the database factory to open the database
  var db = await dbFactory.openDatabase(baseDeDatos);  
  return db;
}

Future<bool> estaRegistrada(DatabaseClient db, String usuario, String salida) async {  
  var store = StoreRef.main();

  var clave = usuario + '###' + salida;
  eslp_console.sendLog( clave, '[#2c1]');

  var title = await store.record(clave).get(db) as String;
  eslp_console.sendLog( title, '[#2c2]');

  return title != null;
}

/* Devuelve true si ha habido algún cambio en la lista de hitos */
Future<bool> procesa (var db, String usuario, String salida) async {
  //Guarda en la tabla de salidas por usuario
  var store = StoreRef.main();
  var clave = usuario + '###' +  salida;
  
  await store.record(clave).put(db, 'XXXXX');
  eslp_console.sendLog( clave, '[#2d]');
  return true;
}

Future<bool> procesaSalida(db, usuario, elemento) async {
  var hayCambios = false;    
  if (await estaRegistrada(db, usuario, elemento) == false) {
    // Procesar salida
    hayCambios = await procesa(db, usuario, elemento);
    eslp_console.sendLog( hayCambios, '[#2b]');
  }

  return hayCambios;  
}

Future<bool> recorreVector(db, usuario, Iterable<String> listaSalidas) async {
  var hayCambios = false;
  var hayNuevoCambio = false;
  
  await Future.forEach(listaSalidas, (elemento) async {
    eslp_console.sendLog(elemento,'[#2a]');    
    hayNuevoCambio = await procesaSalida(db, usuario, elemento);
    hayCambios = hayCambios || hayNuevoCambio;
    eslp_console.sendLog(hayCambios,'[#2c]');   
    eslp_console.sendLog( '--------------', ''); 
  });    
  
  return hayCambios;
}
