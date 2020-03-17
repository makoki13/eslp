import '../datos.dart';
import 'comunidad_autonoma.dart';
import 'localidad.dart';
import 'provincia.dart';
import 'rwgps.dart';

class Usuario {
  String _usuario;
  int _puntuacion;
  int _numSalidasProcesadas;

  final _bd_Usuarios = BaseDeDatos('usuarios.db');
  final _bd_LocalidadesUsuario = BaseDeDatos('localidad_usuario.db');
  final _bd_ProvinciasUsuario = BaseDeDatos('provincia_usuario.db');
  final _bd_CCAAUsuario = BaseDeDatos('ca_usuario.db');
  Localidad localidad = Localidad();

  Usuario() {
    var identificador = _getUsuarioActual();
    _usuario = identificador;
  }

  Future<void> inicia() async {
    var datos;

    await _bd_Usuarios.abre();
    await _bd_LocalidadesUsuario.abre();
    await _bd_ProvinciasUsuario.abre();
    await _bd_CCAAUsuario.abre();
    await localidad.inicia();

    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    if (registro == null) {
      var tupla = {'id': '00', 'nombre': '${_usuario}' , 'puntos' : 0, 'salidas': 0, 'completado' : 0};
      await _bd_Usuarios.addRegistro(tupla);      
      datos = tupla;
    }  
    else {
      datos = registro.getTupla();
    }
    _puntuacion = datos['puntos'];
  }

  String _getUsuarioActual() {
    return 'pablo.makoki@gmail.com';
  }

  String getUsuario() {
    return _usuario;
  }

  Future<int> getNumSalidasTotales () async {
    return await RideWithGPS.getNumSalidas();
  }

  int getNumSalidasProcesadas () { return _numSalidasProcesadas; }

/*
  Future<int> getDataUsuario() async {    
    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    var datos = registro.getTupla();

    return datos['puntos'];
  }
*/  

  Future<int> getPuntuacionActual() async { return _puntuacion; }   
    /*
    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    var datos = registro.getTupla();

    return datos['puntos'];
    
  }
  */

  Future<int> getPuntuacion() async {    
    return await getPuntuacionActual();
  }

  Future<bool> existeLocalidad(BaseDeDatos db, String idLocalidad) async {
    return _bd_LocalidadesUsuario.existeRegistro('localidad', idLocalidad);
  }

  void actualizamosPuntuacion(int puntos) async {
    var clave; 
    var datos;
    var registro = await _bd_Usuarios.getRegistro('nombre', _usuario);
    if (registro == null) {
      var tupla = {'id': '00', 'nombre': '${_usuario}' , 'puntos' : 0, 'salidas': 0, 'completado' : 0};
      clave = await _bd_Usuarios.addRegistro(tupla);      
      datos = tupla;
    }  
    else {
      clave = registro.getClave();
      datos = registro.getTupla();
    } 

    var nuevaPuntuacion = datos['puntos'] + puntos;
    await _bd_Usuarios.updateRegistro(
        clave, 'puntos', nuevaPuntuacion);

    //print ('nueva puntcaiocn ${nuevaPuntuacion}');
    
    _puntuacion = nuevaPuntuacion;
  }

  Future<Map> obtenemosInfoLocalidad(idLocalidad) async {     
    return await localidad.getDatos(idLocalidad);
  }

  //incrementamos en 1 las poblaciones visitadas de la comarca
  //Si en valor de poblaciones visitadas de la comarca es igual al total de la comarca inc. en 10 la puntuacion
  Future<bool> actualizamosComarca(String idComarca) async {
    return true;
  }

  //incrementamos en 1 las poblaciones visitadas de la provincia
  //Si en valor de poblaciones visitadas de la provincia es igual al total de la provincia inc. en 100 la puntuacion  
  Future<bool> actualizamosProvincia(String idProvincia) async {
    var provincia = Provincia();
    var nuevaPuntuacion = 0;
    var clave;
    var haHabidoCompletitud = false;

    var registro = await _bd_ProvinciasUsuario.getRegistro('provincia', idProvincia);
    if (registro == null) {
      var tupla = {'usuario': '${_usuario}', 'provincia': '${idProvincia}' , 'localidades' : 0};
      clave = await _bd_ProvinciasUsuario.addRegistro(tupla);
      nuevaPuntuacion = 1;
    }
    else {
      var datos = registro.getTupla();
      nuevaPuntuacion = datos['localidades'] + 1;
      clave = registro.getClave();
    }


    await _bd_ProvinciasUsuario.updateRegistro(clave, 'localidades', nuevaPuntuacion);

    await provincia.inicia(idProvincia);
    var municipiosTotales = await provincia.numeroMunicipios();
    //print ('MUNICIPIOS DE PROVINCIA: ${municipiosTotales} ');
    if (municipiosTotales <= nuevaPuntuacion ) { //Se ha completado una provincia!
      haHabidoCompletitud = true;
      actualizamosPuntuacion(100);
    }

    return haHabidoCompletitud;
  }

  //incrementamos en 1 las poblaciones visitadas de la c.a.
  //Si en valor de poblaciones visitadas de la c.a. es igual al total de la c.a. inc. en 1000 la puntuacion
  Future<bool> actualizamosComunidadAutonoma(String idCA) async {
    var comunidadAutonoma = ComunidadAutonoma();
    var nuevaPuntuacion = 0;
    var clave;
    var haHabidoCompletitud = false;

    var registro = await _bd_CCAAUsuario.getRegistro('ca', idCA);
    if (registro == null) {
      var tupla = {'usuario': '${_usuario}', 'ca': '${idCA}' , 'localidades' : 0};
      clave = await _bd_CCAAUsuario.addRegistro(tupla);
      nuevaPuntuacion = 1;
    }
    else {
      var datos = registro.getTupla();
      nuevaPuntuacion = datos['localidades'] + 1;
      clave = registro.getClave();
    }

    await _bd_CCAAUsuario.updateRegistro(clave, 'localidades', nuevaPuntuacion);

    await comunidadAutonoma.inicia(idCA);
    var municipiosTotales = await comunidadAutonoma.numeroMunicipios();
    //print ('MUNICIPIOS DE C.A.: ${municipiosTotales} ');
    if (municipiosTotales <= nuevaPuntuacion ) { //Se ha completado una comunidad autonoma!
      haHabidoCompletitud = true;
      actualizamosPuntuacion(1000);    
    }

    return haHabidoCompletitud;  
  }
  
  ///
  /// Esta función habrá que tratarla como una única transacción.
  ///
  Future<bool> procesaLocalidad(String idLocalidad) async {        
    var existe = await existeLocalidad(_bd_LocalidadesUsuario, idLocalidad);    
    if (existe == false) {
      //insertamos en la tabla de localidad_usuario
      var tupla = {'usuario': '${_usuario}', 'localidad': '${idLocalidad}'};      
      var key = await _bd_LocalidadesUsuario.addRegistro( tupla );
      await actualizamosPuntuacion(1);
      var localidad = await obtenemosInfoLocalidad(idLocalidad);
      //print('Localidad: {$key . $localidad}');
      var actualizamosLaProvincia = await actualizamosComarca(localidad['comarca']);
      if (actualizamosLaProvincia == true) {
        var actualizamosLaComunidadAutonoma = await actualizamosProvincia(localidad['provincia']);
        if (actualizamosLaComunidadAutonoma == true) {
          var testeamosPais = await actualizamosComunidadAutonoma(localidad['ca']);
          if (testeamosPais == true) {
              var numCCAACompletadas = await _bd_CCAAUsuario.numRegistros();
              //Si el número de c.a. visitadas es igual al total del pais ponemos completado en la ficha del usuario y sumamos 10000 en la puntuacion
              if (numCCAACompletadas == 19) {
                await actualizamosPuntuacion(10000);
              }
          }
        }
      }
    }
    return !existe;
  }
}