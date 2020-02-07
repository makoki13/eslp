import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future<Object> abreBaseDeDatos() async {
  var baseDeDatos = 'ca.db';
  var dbFactory = databaseFactoryIo;

  // open the database. We use the database factory to open the database
  var db = await dbFactory.openDatabase(baseDeDatos);
  return db;
}

void main() async {   
  var store = intMapStoreFactory.store();
 
  print('Inicio....');
  
  abreBaseDeDatos().then( ( db ) async {      
    var registro = await store.find(db);         
    registro.forEach( (dato) {
        print('${dato}');
    });            
    
  });          
}
