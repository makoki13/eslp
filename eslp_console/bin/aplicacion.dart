import 'package:eslp_console/eslp_console.dart' as eslp_console;
import 'datos.dart';
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
    usuario.inicia().then((a) {
      salida = Salidas();
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
        } );        
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
    
    
    var key = await RideWithGPS.getProvisionalKey();
    print ('key: ${key}');
    
  }
}
