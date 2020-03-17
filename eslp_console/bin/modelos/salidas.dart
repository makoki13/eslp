import 'dart:convert';

import '../datos.dart';
import './rwgps.dart';
import 'usuario.dart';
import 'web_server.dart';

class Salidas {
  final _bd_Salidas = BaseDeDatos('salidas.db');
  final _bd_localidades = BaseDeDatos('localidades.db');

  Future<void> inicia() async {
    await _bd_Salidas.abre();
    await _bd_localidades.abre();
  }

  Future<bool> estaRegistrada(String salida) async {
    return _bd_Salidas.existeRegistro('salida', salida);
  }

/* Devuelve true si ha habido algún cambio en la lista de hitos */
  Future<bool> procesa(Usuario usuario, String salida) async {
    var listaPuntos = <Coordenadas>[];

    listaPuntos = await RideWithGPS.getPuntosDeSalida(salida);
    var hayNovedad = false;
    var i = 1;
    var numPuntos = listaPuntos.length;
    await Future.forEach(listaPuntos, (elemento) async {
      print('procesando punto ${i} de ${numPuntos}');
      var texto =
          await WS.getPoblacion(elemento.getLatitud(), elemento.getLongitud());
      if (texto.isNotEmpty) {
        dynamic reg = jsonDecode(texto);
        var id = '';
        if (reg['id'].toString().length == 12) {
          id = reg['id'].toString().substring(0, 5);
        } else {
          id = '0' + reg['id'].toString().substring(0, 4);
        }
        //print ('Previo ::: ${reg.toString().substring(0,200)}');
        //print ('Previo ::: ${elemento.getLatitud()} , ${elemento.getLongitud()}');
        var tipoPunto = reg['geom'].toString().substring(0, 4);

        if (tipoPunto == 'MULT') {
          /*
            var nombre = reg['muni'].toString();
            var registroPorNombre = await _bd_localidades.getRegistro('nombre', nombre.toString().toUpperCase());
            print ('Registro ::: ${registroPorNombre.getTupla()}');
            id = registroPorNombre.getTupla()['id'];
            hayNovedad = hayNovedad || await usuario.procesaLocalidad(id);
            */
        }

        if ((tipoPunto == 'POIN') || (tipoPunto == 'null')) {
          //print ('Procesamos localidad ${id}');
          hayNovedad = hayNovedad || await usuario.procesaLocalidad(id);
        }
      }

      i++;
    });

    //Guarda en la tabla de salidas por usuario
    var tupla = {'salida': '${salida}'};
    await _bd_Salidas.addRegistro(tupla);

    return hayNovedad;
  }

  Future<bool> procesaSalida(usuario, elemento) async {
    var hayCambios = false;
    if (await estaRegistrada(elemento) == false) {
      // Procesar salida
      hayCambios = await procesa(usuario, elemento);
    }

    return hayCambios;
  }

  Future<bool> recorreVector(
      Usuario usuario, Iterable<String> listaSalidas) async {
    var hayCambios = false;
    var hayNuevoCambio = false;

    var numElementos = listaSalidas.length;
    var i = 0;
    await Future.forEach(listaSalidas, (elemento) async {
      i++;
      print('Procesando elemento ${i} de ${numElementos} : ${elemento}');
      hayNuevoCambio = await procesaSalida(usuario, elemento);
      hayCambios = hayCambios || hayNuevoCambio;
    });

    return hayCambios;
  }

  Future<int> numSalidasRegistradas() async {
    return await _bd_Salidas.numRegistros();
  }
}
