import 'dart:io';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';

//import 'package:eslp_console/eslp_console.dart' as eslp_console;

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future<Object> abreBaseDeDatos() async {
  var baseDeDatos = 'localidades.db';
  var dbFactory = databaseFactoryIo;

  // open the database. We use the database factory to open the database
  var db = await dbFactory.openDatabase(baseDeDatos);
  return db;
}

void main() async {  
  var fileName = 'test.txt';
  var pathToFile = join(dirname(Platform.script.toFilePath()), '', fileName);
  //print(pathToFile);
  var file = File(pathToFile);
  //print(file);

  var store = intMapStoreFactory.store();
  
  var contents;
  if (await file.exists()) {
    print('Inicio....');
    contents = await file.readAsLinesSync();      
    abreBaseDeDatos().then( ( db) {
      var numLinea = 1;
      Future.forEach(contents, (linea) async {        
        //print ('Linea: ${linea}}');
        var listaPalabras = linea.split('#');
        var primeraPalabra = listaPalabras[0];
        //print ('Primera Palabra: ${primeraPalabra}}');
        var listaPalabrasPrimeraPalabra = primeraPalabra.split(' ');
        var id = listaPalabrasPrimeraPalabra[1];
        var idProvincia = id.toString().substring(0,2);
        var indice = 0;
        //var restoPalabras =  listaPalabras[1];
        //print ('Inicio 3 ${id} ${listaPalabras}');
        await Future.forEach(listaPalabras, (elemento) async {
          //print ('Inicio 4 ${indice} ${listaPalabras.length}');
          if (indice > 0) {
            if (elemento.toString().trim() != '') {
              var localidad = elemento.toString().trim();
              print ('${numLinea} ${indice} : ${id} - ${localidad}');

              var finder = Finder(
                filter: Filter.equals('nombre', localidad),
                sortOrders: [SortOrder('nombre')]);
              var records = await store.find(db, finder: finder);
              if (records.isEmpty) {
                print ('**************** ${indice} : ${id} - ${localidad}');
                var key = await store.add(db, {
                  'id': '${id}', 
                  'nombre':'${localidad}',
                  'comarca': '',
                  'provincia': '${idProvincia}',
                  'ca': '19'
                });
              }
            }
          }
          indice++;
        });
        numLinea++;
      });          
    });    
  }
}