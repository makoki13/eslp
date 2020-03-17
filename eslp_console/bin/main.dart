import 'aplicacion.dart';

void main(List<String> arguments) {
  var miAplicacion = Aplicacion();

  //miAplicacion.test_rwgps();

  //miAplicacion.test_rwgps_III();

  
  miAplicacion.erase_dbs(true).then( (var valor) { miAplicacion.actualizaUsuario(); });

  //miAplicacion.listaDeMunicipios();
  
  
  //miAplicacion.test_add_provincia();

  //miAplicacion.rwgps_getKey();
}
