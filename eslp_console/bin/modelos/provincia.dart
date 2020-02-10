import '../datos.dart';

class Provincia {
  final _bd_Provincias = BaseDeDatos('provincias.db');
  String _idProvincia;

  Future<void> inicia(idProvincia) async {
    await _bd_Provincias.abre();
    _idProvincia = idProvincia;
  }
  
  Future<int> numeroMunicipios () async {
    var registro = await _bd_Provincias.getRegistro('id', _idProvincia);
    var datos = registro.getTupla();
    var items = datos['items'];
    return items;
  }
}