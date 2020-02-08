import '../datos.dart';
import 'localidad.dart';

class Usuario {
  String _usuario;

  final _bd_Usuarios = BaseDeDatos('usuarios.db');
  final _bd_LocalidadesUsuario = BaseDeDatos('localidad_usuario.db');
  Localidad localidad = Localidad();

  Usuario() {
    var identificador = _getUsuarioActual();
    _usuario = identificador;
  }

  Future<void> inicia() async {
    await _bd_Usuarios.abre();
    await _bd_LocalidadesUsuario.abre();
    await localidad.inicia();
  }

  String _getUsuarioActual() {
    return 'pablo.makoki@gmail.com';
  }

  String getUsuario() {
    return _usuario;
  }

  Future<int> getPuntuacionActual() async {    
    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    var datos = registro.getTupla();

    return datos['puntos'];
  }

  Future<int> getPuntuacion() async {    
    return await getPuntuacionActual();
  }

  Future<bool> existeLocalidad(BaseDeDatos db, String idLocalidad) async {
    return _bd_LocalidadesUsuario.existeRegistro('localidad', idLocalidad);
  }

  void actualizamosPuntuacion() async {
    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    var datos = registro.getTupla();

    var nuevaPuntuacion = datos['puntos'] + 1;
    await _bd_Usuarios.updateRegistro(
        registro.getClave(), 'puntos', nuevaPuntuacion);
  }

  Future<Map> obtenemosInfoLocalidad(idLocalidad) async {     
    return await localidad.getDatos(idLocalidad);
  }

  //incrementamos en 1 las poblaciones visitadas de la comarca

  //Si en valor de poblaciones visitadas de la comarca es igual al total de la comarca inc. en 10 la puntuacion

  //incrementamos en 1 las poblaciones visitadas de la provincia

  //Si en valor de poblaciones visitadas de la provincia es igual al total de la provincia inc. en 100 la puntuacion

  //incrementamos en 1 las poblaciones visitadas de la c.a.

  //Si en valor de poblaciones visitadas de la c.a. es igual al total de la c.a. inc. en 1000 la puntuacion

  //Si el número de c.a. visitadas es igual al total del pais ponemos completado en la ficha del usuario y sumamos 10000 en la puntuacion

  Future<bool> procesaLocalidad(String idLocalidad) async {
    var existe = await existeLocalidad(_bd_LocalidadesUsuario, idLocalidad);
    if (existe == false) {
      //insertamos en la tabla de localidad_usuario
       var tupla = {'usuario': '${_usuario}', 'localidad': '${idLocalidad}'};
      var key = await _bd_LocalidadesUsuario.addRegistro( tupla );
      await actualizamosPuntuacion();
      var localidad = await obtenemosInfoLocalidad(idLocalidad);
      print('Localidad: {$key . $localidad}');
    }

    return !existe;
  }
}
