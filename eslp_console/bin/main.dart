import 'aplicacion.dart';

void main(List<String> arguments) {
  var miAplicacion = Aplicacion();

  miAplicacion.erase_dbs().then( (var valor) {
    miAplicacion.actualizaUsuario();      
  });
  
  //miAplicacion.test_add_provincia();
}
