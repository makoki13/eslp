import './usuario.dart';

class Coordenadas {
  String latitud;
  String longitud;

  Coordenadas (String lat, String long) {
    latitud = lat;
    longitud = long;
  }

  String getLatitud () { return latitud;}
  String getLongitud () { return longitud;}
}

class RideWithGPS {
  static List<String> getListaDeSalidas(Usuario usuario) {
    var lista = <String>[];

    //lista.add('Salida1');
    //lista.add('Salida2');
    //lista.add('Salida3');

    lista.add('Salida40');
    lista.add('Salida41');
    lista.add('Salida42');

    return lista;
  }

  static List<Coordenadas> getPuntosDeSalida(String salida) {
    var lista = <Coordenadas>[];

    var coordenada = Coordenadas('-0.141949','38.950952'); //Miramar    
    lista.add(coordenada);
    coordenada = Coordenadas('-0.148800','38.960356'); //Guardamar
    lista.add(coordenada);
    coordenada = Coordenadas('-0.155366','38.968665'); //Daimuz
    lista.add(coordenada);
    coordenada = Coordenadas('-0.163133','38.987948'); //Gandia (Grao)        
    lista.add(coordenada);
    coordenada = Coordenadas('-0.301455','39.014899'); //Barx
    lista.add(coordenada);

    return lista;
  }
}
