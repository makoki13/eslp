import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
//import 'package:sembast/utils/value_utils.dart';

import 'package:eslp_console/eslp_console.dart' as eslp_console;

class Usuario {
  String usuario;

  Future<Object> abreBaseDeDatos(String baseDeDatos) async {
    
    var dbFactory = databaseFactoryIo;

    // open the database. We use the database factory to open the database
    var db = await dbFactory.openDatabase(baseDeDatos);
    return db;
  }

  Usuario (String identificador) {
    usuario = identificador;
  }

  String getUsuario() {
    return usuario;
  }

  int recalculaPuntuacion() {
    return 100;
  }

  int getPuntuacionActual() {
    return 50;
  }

  void getPuntuacion(bool hayCambios) {    
    var puntuacion = 0;

    if (hayCambios == true) {
      puntuacion = recalculaPuntuacion();
    } else {
      puntuacion = getPuntuacionActual();
    }

    eslp_console.sendLog(puntuacion, '[#puntuacion]');
  }

  Future<bool> existeLocalidad(DatabaseClient db, String idLocalidad) async {
    var store = intMapStoreFactory.store();
  
    var finder = Finder(
      filter: Filter.equals('localidad', idLocalidad),
      sortOrders: [SortOrder('localidad')]);
    var records = await store.find(db, finder: finder);
    
    return records.isNotEmpty;
  }

  void actualizamosPuntuacion(DatabaseClient db) async {      
      var store = intMapStoreFactory.store();
      var finder = Finder(
        filter: Filter.equals('nombre', usuario),
        sortOrders: [SortOrder('nombre')]);
      var record = await store.findFirst(db, finder: finder);
      var registro = await store.record(record.key).getSnapshot(db);                        
      var nuevaPuntuacion = registro['puntos'] + 1;                
        
      var res = await store.record(record.key).update(db, {'puntos': nuevaPuntuacion});
  }

  Future<RecordSnapshot> obtenemosInfoLocalidad(idLocalidad) async {
      //obtenemos datos de la poblacion
      var dbLocalidades = await abreBaseDeDatos('localidades.db');
      var store = intMapStoreFactory.store();
      var finder = Finder(
        filter: Filter.equals('id', idLocalidad),
        sortOrders: [SortOrder('id')]);
      var record = await store.findFirst(dbLocalidades, finder: finder);
      var registro = await store.record(record.key).getSnapshot(dbLocalidades);                        

      return registro;
  }  

  //incrementamos en 1 las poblaciones visitadas de la comarca

  //Si en valor de poblaciones visitadas de la comarca es igual al total de la comarca inc. en 10 la puntuacion

  //incrementamos en 1 las poblaciones visitadas de la provincia

  //Si en valor de poblaciones visitadas de la provincia es igual al total de la provincia inc. en 100 la puntuacion

  //incrementamos en 1 las poblaciones visitadas de la c.a.

  //Si en valor de poblaciones visitadas de la c.a. es igual al total de la c.a. inc. en 1000 la puntuacion

  //Si el número de c.a. visitadas es igual al total del pais ponemos completado en la ficha del usuario y sumamos 10000 en la puntuacion
  
  Future<bool> procesaLocalidad(String idLocalidad) async {
    var store = StoreRef.main();

    var dbUsuario = await abreBaseDeDatos('usuarios.db');

    //Primero buscamos la localidad en la tabla
    await abreBaseDeDatos('localidad_usuario.db').then( ( db ) async {
      await existeLocalidad(db, idLocalidad).then( (valor) async { 
        if ( valor == false ) {
          //insertamos en la tabla de localidad_usuario
          var key = await store.add(db, {
                    'usuario': '${usuario}', 
                    'localidad':'${idLocalidad}'
          });      
          await actualizamosPuntuacion(dbUsuario);
          var localidad = await obtenemosInfoLocalidad(idLocalidad);     
          print ('Localidad: {$localidad}');
        }
      });
    });
    
    return true;
  }
}
