import 'package:dson/dson.dart';
import '../datos.dart';

class Localidad {
  final _bd = BaseDeDatos('localidades.db');
  String _idLocalidad;
  Map _datos;

  Future<void> inicia() async {
    await _bd.abre();
  }

  Future<Map> getDatos(idLocalidad) async {     
    _idLocalidad = idLocalidad;
    var datos = _bd.getRegistro('id',_idLocalidad).then((registro) {            
      var tupla = registro.getTupla();                  
      _datos = {
        'id' : tupla['id'],
        'nombre' : tupla['nombre'],
        'comarca' : tupla['comarca'],
        'provincia' : tupla['provincia'],
        'ca' : tupla['ca']
      };         
      return _datos; 
    });
    return datos;
  }

  @override
  String toString() {    
    return toJson( _datos );    
  }

}