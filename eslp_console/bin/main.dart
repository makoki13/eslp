import 'package:eslp_console/eslp_console.dart' as eslp_console;

import './rwgps.dart';
import './usuario.dart';
import './salidas.dart';

void main(List<String> arguments) {
  var hayCambios = false;
  
  eslp_console.sendLog( ':', '[INICIO]' );
  
  // Loguearse
  var usuario = getUsuario();

  // Obtener salidas
  List<String> listaSalidas;
  listaSalidas = getListaDeSalidas(usuario);
  
  // Para cada salida  
  if (listaSalidas.isNotEmpty) {
    abreBaseDeDatos().then( ( db) {
      recorreVector(db, usuario, listaSalidas).then((valor) {
        hayCambios = hayCambios || valor;
        getPuntuacion(hayCambios);
        eslp_console.sendLog( ':', '[FIN]' );
      });
    });    
  };   

  
}
