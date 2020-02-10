import 'dart:convert';

import '../datos.dart';
import './rwgps.dart';
import 'usuario.dart';
import 'web_server.dart';

class Salidas {
  final _bd_Salidas = BaseDeDatos('salidas.db');

  Future<void> inicia() async {
    await _bd_Salidas.abre();
  }

  Future<bool> estaRegistrada(String salida) async {    
    return _bd_Salidas.existeRegistro('salida', salida);
  }

/* Devuelve true si ha habido algún cambio en la lista de hitos */
  Future<bool> procesa(Usuario usuario, String salida) async {
    //Guarda en la tabla de salidas por usuario
    var tupla = {'salida': '${salida}'};
    await _bd_Salidas.addRegistro(tupla);

    var listaPuntos = <Coordenadas>[];

    listaPuntos = RideWithGPS.getPuntosDeSalida(salida);
    var hayNovedad = false;
    await Future.forEach(listaPuntos, (elemento) async {
      var texto =
          await WS.getPoblacion(elemento.getLatitud(), elemento.getLongitud());
      dynamic reg = jsonDecode(texto);
      var id = reg['id'].toString().substring(0, 5);

      hayNovedad = hayNovedad || await usuario.procesaLocalidad(id);
    });

    return hayNovedad;
  }

  Future<bool> procesaSalida(usuario, elemento) async {
    var hayCambios = false;
    if (await estaRegistrada(elemento) == false) {
      // Procesar salida
      print ('Procesando salida ${elemento}');
      hayCambios = await procesa(usuario, elemento);
    }

    return hayCambios;
  }

  Future<bool> recorreVector(
      Usuario usuario, Iterable<String> listaSalidas) async {
    var hayCambios = false;
    var hayNuevoCambio = false;

    await Future.forEach(listaSalidas, (elemento) async {     
      hayNuevoCambio = await procesaSalida(usuario, elemento);
      hayCambios = hayCambios || hayNuevoCambio;
    });

    return hayCambios;
  }
}
