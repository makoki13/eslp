import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class Registro {
  RecordSnapshot _registro;
  int _clave;

  Registro(RecordSnapshot registro, int clave) {
    _registro = registro;
    _clave = clave;
  }

  RecordSnapshot getTupla () { return _registro; }
  int getClave () { return _clave; }
}

class BaseDeDatos {
  String _tabla;
  DatabaseClient _db;
  DatabaseFactory _dbFactory;

  BaseDeDatos (String tabla) {
    _tabla = tabla;
  }

  Future<Object> abreBaseDeDatos(String baseDeDatos) async {
    
    _dbFactory = databaseFactoryIo;

    // open the database. We use the database factory to open the database
    _db = await _dbFactory.openDatabase(baseDeDatos);
    return _db;
  }

  Object abre() async  {
    return await abreBaseDeDatos(_tabla);
  }

  Future<bool> existeClave(clave) async {
    var store = intMapStoreFactory.store();
    var title = await store.record(clave).get(_db) as String;    
    return title != null;
  }

  Future<bool> existeRegistro(String clave, String valor) async {
    var store = intMapStoreFactory.store();
  
    var finder = Finder(
      filter: Filter.equals(clave, valor),
      sortOrders: [SortOrder(clave)]);
    var records = await store.find(_db, finder: finder);
    
    return records.isNotEmpty;
  }  

  Future<Registro> getRegistro(String clave, String valor) async {
    //print ('TABLA: ${_tabla} - CLAVE: ${clave} - VALOR: ${valor}');
    var store = intMapStoreFactory.store();
    var finder = Finder(
      filter: Filter.equals(clave, valor),
      sortOrders: [SortOrder(clave)]);
    var registro = await store.findFirst(_db, finder: finder);        
    if (registro == null) {
      //print ('${valor} es nulo');
      return null;
    }

    //print ('Num tuplas: ${numTuplas} registro: ${registro}');

    var datosRegistro = await store.record(registro.key).getSnapshot(_db); 
    var claveRegistro = registro.key;
    return Registro(datosRegistro, claveRegistro); 
  } 

  Future<int> addRegistro(Map tupla) async {
    var store = intMapStoreFactory.store();
    var key = await store.add(_db, tupla);      
    return key;
  }

  Future<void> addClave(var clave) async {
     var store = StoreRef.main();
    await store.record(clave).put(_db, 'XXXXX');
  }

  Future<Map> updateRegistro(int clave, String campo, var valor) async {
    var store = intMapStoreFactory.store();
    return await store.record(clave).update(_db, {campo: valor});
  }

  Future<int> numRegistros () async  {
    var store = intMapStoreFactory.store();
    final records = await store.find(_db);
    return records.length;
  }

  Future<void> erase_db () async {
    _dbFactory = databaseFactoryIo;

    // open the database. We use the database factory to open the database
    _db = await _dbFactory.openDatabase(_tabla);
    var store = intMapStoreFactory.store();
    await store.delete(_db);
  }

  Future<List<RecordSnapshot>> devuelveTabla() async {
    var store = intMapStoreFactory.store();
    return await store.find(_db);
  }
}