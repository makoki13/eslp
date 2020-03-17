import 'package:eslp_console/eslp_console.dart' as eslp_console;
import 'datos.dart';
import 'modelos/localidad.dart';
import 'modelos/rwgps.dart';
import 'modelos/salidas.dart';
import 'modelos/usuario.dart';

class Aplicacion {
  void actualizaUsuario()  {
    var hayCambios = false;
    Usuario usuario;
    Salidas salida;
    var puntuacion;

    eslp_console.sendLog(':', '[INICIO]');

    // Loguearse
    usuario = Usuario();
    salida = Salidas();
    RideWithGPS.init();
    usuario.inicia().then((a) {      
      salida.inicia().then((a) async {        
        var inicio = await salida.numSalidasRegistradas();
        var salidas = await usuario.getNumSalidasTotales();
        print ('Inicio: ${inicio} - Salidas: ${salidas}');
        
        await RideWithGPS.getListaDeSalidas(usuario, inicio , salidas ).then ( (listaSalidas) {
          if (listaSalidas.isNotEmpty) {
            salida.recorreVector(usuario, listaSalidas).then((valor) async {
              hayCambios = hayCambios || valor;
              puntuacion = await usuario.getPuntuacion();
              print('Puntuacion: ${puntuacion}');
              eslp_console.sendLog(':', '[FIN]');
            });
          }
        });
      });
    });
  }

  void test_add_provincia() async {
    var usuario = Usuario();

    await usuario.inicia();

    await usuario.actualizamosProvincia('46');
  }

  Future<void> erase_dbs (bool borra) async {
    final _bd_Usuarios = BaseDeDatos('usuarios.db');
    if (borra == true) await _bd_Usuarios.erase_db();
    final _bd_LocalidadesUsuario = BaseDeDatos('localidad_usuario.db');
    if (borra == true) await _bd_LocalidadesUsuario.erase_db();
    final _bd_ProvinciasUsuario = BaseDeDatos('provincia_usuario.db');
    if (borra == true) await _bd_ProvinciasUsuario.erase_db();
    final _bd_CCAAUsuario = BaseDeDatos('ca_usuario.db');
    if (borra == true) await _bd_CCAAUsuario.erase_db();
    final _bd_salidas = BaseDeDatos('salidas.db');
    if (borra == true) await _bd_salidas.erase_db();  
  }

  Future<void> test_rwgps () async {
    
    //var salidas = await RideWithGPS.getNumSalidas();
    //print ('Salidas: ${salidas}');
    
    RideWithGPS.init();
    var key = await RideWithGPS.getProvisionalKey();
    print ('key: ${key}');
    
  }

  Future<void> test_rwgps_II () async {
    RideWithGPS.init();
    var numero = await RideWithGPS.getNumSalidas();
    print('Numero ${numero}');

  }

  Future<void> rwgps_getKey() async {
    RideWithGPS.init();
    await RideWithGPS.getProvisionalKey();
  }

  void test_rwgps_III () {
    Usuario usuario;
    Salidas salida;
    var hayCambios = false;
    var puntuacion;

    usuario = Usuario();
    salida = Salidas();
    
    RideWithGPS.init();

    usuario.inicia().then((a) {      
      salida.inicia().then((a) async {        
        var inicio = await salida.numSalidasRegistradas();
        var salidas = await usuario.getNumSalidasTotales();

        print ('Inicio: ${inicio} - Salidas: ${salidas}');

        await RideWithGPS.getListaDeSalidas(usuario, inicio , salidas ).then ( (listaSalidas) {
          //print('LISTA SALIDAS: ${listaSalidas}');
          if (listaSalidas.isNotEmpty) {            
             salida.recorreVector(usuario, listaSalidas).then((valor) async {
              hayCambios = hayCambios || valor;
              puntuacion = await usuario.getPuntuacion();
              print('Puntuacion: ${puntuacion}');
              eslp_console.sendLog(':', '[FIN]');
            }); 
          }
        });
      });
    });  
  }

  void listaDeMunicipios () async {
    var localidad = Localidad();
    final _bd_localidades = BaseDeDatos('localidad_usuario.db');    
    await _bd_localidades.abre();

    await localidad.inicia();

    var resp = await _bd_localidades.devuelveTabla();
    await Future.forEach(resp, (elemento) async {     
      var itemLocalidad = elemento['localidad'];
      var datos = await localidad.getDatos(itemLocalidad);
      print ('${datos['nombre']}');
    });
  }
}
