import 'aplicacion.dart';

void main(List<String> arguments) {
  var miAplicacion = Aplicacion();

  //miAplicacion.test_rwgps();

  
  miAplicacion.erase_dbs(true).then( (var valor) { miAplicacion.actualizaUsuario(); });
  
  
  //miAplicacion.test_add_provincia();
}
