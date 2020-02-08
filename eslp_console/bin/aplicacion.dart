import 'package:eslp_console/eslp_console.dart' as eslp_console;
import 'modelos/rwgps.dart';
import 'modelos/salidas.dart';
import 'modelos/usuario.dart';

class Aplicacion {
  void actualizaUsuario() {
    var hayCambios = false;
    Usuario usuario;
    Salidas salida;
    var puntuacion;

    eslp_console.sendLog(':', '[INICIO]');

    // Loguearse
    usuario = Usuario();
    usuario.inicia().then((a) {
      salida = Salidas();
      salida.inicia().then((a) {
        List<String> listaSalidas;
        listaSalidas = RideWithGPS.getListaDeSalidas(usuario);
        // Para cada salida
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
  }
}
