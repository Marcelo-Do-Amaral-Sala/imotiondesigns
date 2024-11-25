import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../../clients/overlays/main_overlay.dart';
import '../../db/db_helper.dart';

class OverlayBackup extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayBackup({super.key, required this.onClose});

  @override
  _OverlayBackupState createState() => _OverlayBackupState();
}

class _OverlayBackupState extends State<OverlayBackup>
    with SingleTickerProviderStateMixin {
  bool isBodyPro = true;
  String? selectedGender;
  bool showConfirmation =
      false; // Nuevo estado para mostrar mensaje de confirmación
  bool isLoading = false;
  String statusMessage = 'Listo para hacer la copia de seguridad';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadBackup() async {
    try {
      setState(() {
        isLoading = true;
        statusMessage = 'Subiendo la copia de seguridad a GitHub...';
      });

      // Obtén la instancia del helper
      DatabaseHelper dbHelper = DatabaseHelper();

      await dbHelper.initializeDatabase();

      print('BASE DE DATOS INICIALIZADA');

      // Espera antes de subir el backup
      await Future.delayed(Duration(seconds: 2));

      print('SUBIENDO BACKUP...');

      // Realiza la subida del backup a GitHub
      await DatabaseHelper.uploadDatabaseToGitHub();

      // Reabrir la base de datos después de subir el backup
      await dbHelper.initializeDatabase();

      setState(() {
        isLoading = false;
        statusMessage = 'Copia de seguridad subida exitosamente a GitHub';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = 'Error al subir la copia de seguridad: $e';
      });
    }
  }

  Future<void> _downloadBackup() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Imprimir el estado actual de la base de datos antes de hacer cualquier cosa
      debugPrint(
          "Estado de la base de datos antes de la inicialización: ${db.isOpen ? 'Abierta' : 'Cerrada'}");

      setState(() {
        isLoading = true;
        statusMessage = 'Descargando la copia de seguridad desde GitHub...';
      });

      // Inicializar la base de datos (asegúrate de que esté abierta después de la eliminación)
      await dbHelper.initializeDatabase();

      // Verificar si la base de datos está abierta después de la inicialización
      if (!db.isOpen) {
        throw Exception(
            'La base de datos no se pudo abrir después de la inicialización');
      }

      debugPrint("Database open (after re-opening): ${db.isOpen}");

      // Descargar la copia de seguridad desde GitHub
      await DatabaseHelper.downloadDatabaseFromGitHub();

      // Verificar nuevamente si la base de datos sigue abierta después de la descarga
      final dbAfterDownload = await dbHelper.database;
      debugPrint(
          "Estado de la base de datos después de la descarga: ${dbAfterDownload.isOpen ? 'Abierta' : 'Cerrada'}");

      if (!dbAfterDownload.isOpen) {
        throw Exception('La base de datos está cerrada después de la descarga');
      }

      setState(() {
        isLoading = false;
        statusMessage = 'Copia de seguridad descargada exitosamente';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          statusMessage = 'Error al descargar la copia de seguridad: $e';
        });
      }
      print("Error durante la descarga del backup: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "COPIA DE SEGURIDAD",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _uploadBackup();
                  }, // Mantener vacío para que InkWell funcione
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'HACER COPIA',
                    style: TextStyle(
                      color: Color(0xFF2be4f3),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showConfirmation = true; // Mostrar confirmación al pulsar
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: const Color(0xFF2be4f3),
                  ),
                  child: const Text(
                    'RECUPERAR COPIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (showConfirmation) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Text(
                '¿Seguro que quieres restaurar la copia?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        // Primero se descarga la base de datos
                        await _downloadBackup();

                        // Después de la descarga, ocultamos la confirmación (si es necesario)
                        setState(() {
                          showConfirmation = false;
                        });

                        // Finalmente, reiniciamos la aplicación
                        await Restart.restartApp();
                      } catch (e) {
                        // Manejo de errores en caso de que algo falle durante la descarga
                        print('Error al descargar la copia de seguridad: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(width: 1.0, color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'SÍ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showConfirmation = false; // Ocultar confirmación
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(width: 1.0, color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'NO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }
}
