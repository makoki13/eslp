import 'package:eslp_console/eslp_console.dart' as eslp_console;

String getUsuario() {
  return 'pablo.makoki@gmail.com';
}

int recalculaPuntuacion() {
  return 100;
}

int getPuntuacionActual() {
  return 50;
}

void getPuntuacion(bool hayCambios) {
    var puntuacion = 0;
  
    if (hayCambios == true) {
      puntuacion = recalculaPuntuacion();
    } else {
      puntuacion = getPuntuacionActual();
    }
    
    eslp_console.sendLog( puntuacion, '[#puntuacion]' );
}