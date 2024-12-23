import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadJsonView extends StatefulWidget {
  @override
  _UploadJsonViewState createState() => _UploadJsonViewState();
}

class _UploadJsonViewState extends State<UploadJsonView> {

  // Leer archivo JSON desde los assets
  Future<Map<String, dynamic>> loadJson() async {
    final String response = await rootBundle.loadString('assets/traducciones1.json');
    final Map<String, dynamic> data = json.decode(response);
    return data;
  }

  // Subir los datos del JSON a Firestore
  Future<void> uploadTranslationsToFirestore() async {
    try {
      Map<String, dynamic> translations = await loadJson();
      CollectionReference traducciones = FirebaseFirestore.instance.collection('traducciones');

      translations.forEach((lang, keys) async {
        DocumentReference docRef = traducciones.doc(lang);
        Map<String, dynamic> languageData = {};

        keys.forEach((key, value) {
          languageData[key] = value;
        });

        await docRef.set(languageData);
      });

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Traducciones subidas exitosamente!')));
    } catch (e) {
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir datos: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Traducciones a Firestore'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Llamar a la función para subir el JSON a Firestore
            uploadTranslationsToFirestore();
          },
          child: const Text(
            'Subir Traducciones',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40), backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
