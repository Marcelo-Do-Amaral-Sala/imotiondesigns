import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MiWidget extends StatefulWidget {
  @override
  _MiWidgetState createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> {
  List<String> respuestaTroceada = [];

  @override
  void initState() {
    super.initState();
    obtenerDatos(); // Llama a la función en el initState
  }

  Future<void> obtenerDatos() async {
    try {
      List<String> datos = await hacerSolicitud("imotion21");

      // Imprimir cada elemento con su índice
      for (int i = 0; i < datos.length; i++) {
        print("${i + 1}. ${datos[i]}");
      }

      setState(() {
        respuestaTroceada = datos;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Datos en initState"),
      ),
      body: Center(
        child: respuestaTroceada.isNotEmpty
            ? ListView.builder(
          itemCount: respuestaTroceada.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(respuestaTroceada[index]),
            );
          },
        )
            : CircularProgressIndicator(),
      ),
    );
  }

  // Función de solicitud GET con encriptación
  Future<List<String>> hacerSolicitud(String modulo) async {
    String datos = encrip("18<#>$modulo");
    Uri url = Uri.parse("https://imotionems.es/lic2.php?a=$datos");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body.split('|');
      } else {
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ocurrió un error: $e");
    }
  }

  // Función de encriptación
  String encrip(String wcadena) {
    String xkkk =
        'ABCDE0FGHIJ1KLMNO2PQRST3UVWXY4Zabcd5efghi6jklmn7opqrs8tuvwx9yz(),-.:;@';
    String xkk2 = '[]{}<>?¿!¡*#';
    int wp = 0, wd = 0, we = 0, wr = 0;
    String wa = '', wres = '';
    int wl = xkkk.length;
    var wcont = Random().nextInt(10);

    if (wcadena.isNotEmpty) {
      wres = xkkk.substring(wcont, wcont + 1);
      for (int wx = 0; wx < wcadena.length; wx++) {
        wa = wcadena.substring(wx, wx + 1);
        wp = xkkk.indexOf(wa);
        if (wp == -1) {
          wd = wa.codeUnitAt(0);
          we = wd ~/ wl;
          wr = wd % wl;
          wcont += wr;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkk2.substring(we, we + 1) + xkkk.substring(wcont, wcont + 1);
        } else {
          wcont += wp;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkkk.substring(wcont, wcont + 1);
        }
      }
    }

    print("Cadena encriptada: $wres");
    return wres;
  }
}
