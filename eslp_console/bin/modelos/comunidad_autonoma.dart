import '../datos.dart';

class ComunidadAutonoma {
  final _bd_CCAA = BaseDeDatos('ca.db');
  String _idCA;

  Future<void> inicia(idCA) async {
    await _bd_CCAA.abre();
    _idCA = idCA;
  }
  
  Future<int> numeroMunicipios () async {
    var registro = await _bd_CCAA.getRegistro('id', _idCA);
    var datos = registro.getTupla();
    var items = datos['items'];
    return items;
  }
}