import 'package:eslp_console/eslp_console.dart' as eslp_console;

import './rwgps.dart';
import './usuario.dart';
import './salidas.dart';

void main(List<String> arguments) {
  var hayCambios = false;
  Usuario usuario;
  Salidas salida;
    
  eslp_console.sendLog( ':', '[INICIO]' );

  // Loguearse
  usuario = Usuario('pablo.makoki@gmail.com');

  salida = Salidas();
    
  // Obtener salidas
  List<String> listaSalidas;
  listaSalidas = RideWithGPS.getListaDeSalidas(usuario);
  
  // Para cada salida  
  if (listaSalidas.isNotEmpty) {
    salida.abreBaseDeDatos().then( ( db) {
      salida.recorreVector(db, usuario, listaSalidas).then((valor) {
        hayCambios = hayCambios || valor;
        usuario.getPuntuacion(hayCambios);
        eslp_console.sendLog( ':', '[FIN]' );
      });
    });    
  };   

  
}
