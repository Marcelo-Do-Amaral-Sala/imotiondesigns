import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../utils/translation_utils.dart';

class CustomPdfGenerator {
  Future<File?> generateAndSavePdf(
    BuildContext context,
    String fileName,
    String? clientName,
    String? clientGender,
    String? clientAge,
    int? clientHeight,
    int? clientWeight,
    List<Map<String, String>> resumen,
    Map<String, dynamic> recomendacion,
    Uint8List imageBytes,
    Map<String, dynamic> imc,
  ) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    // Cargar fuentes
    final oswaldRegularFont =
    pw.Font.ttf(await rootBundle.load('assets/fonts/Oswald-Regular.ttf'));
    final oswaldBoldFont =
    pw.Font.ttf(await rootBundle.load('assets/fonts/Oswald-Bold.ttf'));

    // Cargar imágenes
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logopdf.png')).buffer.asUint8List(),
    );

    Future<Uint8List?> loadAssetImage(String assetPath) async {
      try {
        ByteData data = await rootBundle.load(assetPath);
        return data.buffer.asUint8List();
      } catch (e) {
        print("❌ Image not found in assets: $assetPath");
        return null; // Return null if image is missing
      }
    }

    List<pw.Widget> programWidgets = [];
    if (recomendacion["images"] != null && recomendacion["images"].isNotEmpty) {
      programWidgets = await Future.wait(
        recomendacion["images"].map<Future<pw.Widget>>((program) async {
          Uint8List? programImageBytes;
          programImageBytes = await loadAssetImage('${program["image"]}');

          return pw.Container(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(program["name"],
                    style: pw.TextStyle(font: oswaldBoldFont, fontSize: 12.sp)),
                if (programImageBytes != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(
                      pw.MemoryImage(programImageBytes),
                      fit: pw.BoxFit.contain,
                    ),
                  )
                else
                  pw.Text("Imagen no disponible",
                      style: pw.TextStyle(
                          font: oswaldRegularFont, fontSize: 10.sp)),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String infoClienteText = tr(context, 'Información personal');
    String infoAddClienteText = tr(context, 'Información adicional');
    String recoClienteText = tr(context, 'Recomendaciones');
    String programasReco = tr(context, 'Programas sugeridos');
    String clienteText = tr(context, 'Nombre');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');
    String intro = tr(context,
        '''Entrenamiento sugerido\nPara optimizar tu sesión de 25 minutos utilizando los programas recomendados, te sugerimos seguir la siguiente estructura: ''');

    String encabezado1 = tr(context, '1.Calentamiento (4 minutos)');
    String encabezado2 = tr(context, '2.Entrenamiento (18 minutos)');
    String encabezado3 = tr(context, '3.Vuelta a la calma (3 minutos)');

    String calentamiento = tr(context,
        '''Comienza tu sesión con programas de baja frecuencia, como Cardio, Warm Up o Endurance.
Estos programas están diseñados para aumentar progresivamente la frecuencia cardíaca, activar la musculatura y preparar el cuerpo para el entrenamiento principal. Durante esta etapa, combina el uso del EMS con movimientos dinámicos suaves, como caminatas en el lugar, estiramientos dinámicos o movilidad articular.''');

// Extraer los nombres de los programas recomendados
    List<String> programNames = recomendacion["images"]
        ?.map<String>((program) => program["name"].toString())
        .toList() ??
        [];

// Convertir la lista en una cadena separada por comas
    String nombresProgramas = programNames.isNotEmpty
        ? programNames.join(", ")
        : "No hay programas disponibles";

// Crear la cadena con la interpolación
    String entrenamiento = tr(context,
        '''En esta parte central, enfócate en los programas seleccionados para fuerza e hipertrofia muscular, como $nombresProgramas. Estos están diseñados para maximizar la activación muscular y promover el desarrollo de fuerza y masa muscular. 
Asegúrate de ajustar la intensidad de acuerdo con tu nivel y objetivos, y acompaña los estímulos eléctricos con ejercicios funcionales o de resistencia según tu plan.''');

    String relax = tr(context,
        '''Finaliza la sesión con programas específicos para la relajación y recuperación, como Contracturas, Relax o Drenaje. Durante este tiempo, aprovecha para reducir gradualmente la frecuencia cardíaca, realizar estiramientos estáticos o simplemente relajarte. Estos programas ayudan a disminuir la tensión muscular, favorecer la circulación y preparar tu cuerpo para una recuperación óptima.''');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      fichaClienteText.toUpperCase(),
                      style: pw.TextStyle(
                        font: oswaldRegularFont,
                        fontSize: 28.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                    ),
                    pw.Image(logo, height: 70),
                  ],
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
                pw.SizedBox(height: 20),
                // Sección Información Personal (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(infoClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),

                // Cliente info + Imagen
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteText + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientName',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteEdad + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientAge',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteAltura + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientHeight cm',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clientePeso + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientWeight kg',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#020659'),
                        borderRadius:
                        pw.BorderRadius.circular(16), // Radio de 16
                      ),
                      width: 300,
                      height: 300,
                      child: pw.ClipRRect(
                        horizontalRadius: 16,
                        verticalRadius: 16,
                        child: pw.Image(image, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Sección Información Adicional (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(infoAddClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),
                // Lista de resumen
                ...resumen.map((entry) {
                  return pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '${entry["title"]!}: ',
                            style: pw.TextStyle(
                              font: oswaldBoldFont,
                              fontSize: 16.sp,
                              color: PdfColor.fromHex('#020659'),
                            ),
                          ),
                          pw.TextSpan(
                            text: entry["value"]!,
                            style: pw.TextStyle(
                              font: oswaldRegularFont,
                              fontSize: 14.sp,
                              color: PdfColor.fromHex('#020659'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                pw.SizedBox(height: 20),

// Sección Recomendaciones
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    recoClienteText,
                    style: pw.TextStyle(
                      font: oswaldBoldFont,
                      fontSize: 18.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      // Alineación a la izquierda
                      children: [
                        // Texto de programasReco
                        pw.Text(
                          programasReco,
                          style: pw.TextStyle(
                            font: oswaldBoldFont,
                            fontSize: 18.sp,
                            color: PdfColor.fromHex('#020659'),
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 10),
                        // Mostrar imágenes de programas recomendados
                        if (programWidgets.isNotEmpty) ...[
                          pw.Column(
                            children: [
                              for (int i = 0; i < programWidgets.length; i += 2)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  // Alineación a la izquierda
                                  children: [
                                    programWidgets[i],
                                    if (i + 1 < programWidgets.length)
                                      pw.SizedBox(width: 10),
                                    if (i + 1 < programWidgets.length)
                                      programWidgets[i + 1],
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              "Intensidades por músculo: ",
                              style: pw.TextStyle(
                                font: oswaldBoldFont,
                                fontSize: 18.sp,
                                // Texto más grande y en negrita
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                            pw.Text(
                              "${recomendacion["intensidad"]}",
                              style: pw.TextStyle(
                                font: oswaldRegularFont,
                                // Texto normal sin negrita
                                fontSize: 14.sp,
                                // Más pequeño
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Text(
                              "Duración: ",
                              style: pw.TextStyle(
                                font: oswaldBoldFont,
                                fontSize: 18.sp,
                                // Texto más grande y en negrita
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                            pw.Text(
                              "${recomendacion["duracion"]}",
                              style: pw.TextStyle(
                                font: oswaldRegularFont,
                                // Texto normal sin negrita
                                fontSize: 14.sp,
                                // Más pequeño
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'www.i-motiongroup.com',
                    style: pw.TextStyle(
                      font: oswaldRegularFont,
                      fontSize: 12.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
              ],
            ),
          );
        },
      ),
    );
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // TÍTULO PRINCIPAL
                pw.Text(
                  intro,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 16.sp, // Título más grande y llamativo
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 1: CALENTAMIENTO
                pw.Text(
                  encabezado1,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  calentamiento,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Un poco más pequeño y ordenado
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start, // Justificar el texto
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 2: ENTRENAMIENTO PRINCIPAL
                pw.Text(
                  encabezado2,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  entrenamiento,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Tamaño uniforme y legible
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start,
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 3: VUELTA A LA CALMA
                pw.Text(
                  encabezado3,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  relax,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Mismo formato
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start,
                ),

                pw.Spacer(),

                // PIE DE PÁGINA CON DIVISOR
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'www.i-motiongroup.com',
                    style: pw.TextStyle(
                      font: oswaldRegularFont,
                      fontSize: 12.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
              ],
            ),
          );
        },
      ),
    );

// Obtener el directorio correcto
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download'); // Carpeta de Descargas en Android
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory(); // Carpeta en iOS
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      directory = Directory('${Directory.systemTemp.path}/Downloads'); // Carpeta en PC
    }

    // Verificar si el directorio existe, si no, crearlo
    if (directory != null && !directory.existsSync()) {
      directory.createSync(recursive: true);
    }

// Función para obtener un nombre de archivo único si ya existe
    Future<String> getUniqueFileName(String baseName, Directory directory) async {
      int counter = 1;
      String fileNameWithoutExt = baseName.replaceFirst('.pdf', '');
      String newFileName = baseName;

      while (await File(path.join(directory.path, newFileName)).exists()) {
        newFileName = '$fileNameWithoutExt($counter).pdf';
        counter++;
      }

      return newFileName;
    }

// Verificar que directory no sea nulo antes de continuar
    if (directory == null) {
      print("❌ Error: No se pudo determinar el directorio para guardar el PDF.");
      return null;
    }

// Obtener un nombre único si el archivo ya existe
    final uniqueFileName = await getUniqueFileName(fileName, directory);
    final filePath = path.join(directory.path, uniqueFileName);
    final file = File(filePath);

// Guardar el archivo PDF con el nuevo nombre
    await file.writeAsBytes(await pdf.save());

    print("✅ PDF guardado en: $filePath");

    return file;

  }

  Future<void> generateAndOpenPdf(
    BuildContext context,
    String fileName,
    String? clientName,
    String? clientGender,
    String? clientAge,
    int? clientHeight,
    int? clientWeight,
    List<Map<String, String>> resumen,
    Map<String, dynamic> recomendacion,
    Uint8List imageBytes,
    Map<String, dynamic> imc,
  ) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    // Cargar fuentes
    final oswaldRegularFont =
    pw.Font.ttf(await rootBundle.load('assets/fonts/Oswald-Regular.ttf'));
    final oswaldBoldFont =
    pw.Font.ttf(await rootBundle.load('assets/fonts/Oswald-Bold.ttf'));

    // Cargar imágenes
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logopdf.png')).buffer.asUint8List(),
    );

    Future<Uint8List?> loadAssetImage(String assetPath) async {
      try {
        ByteData data = await rootBundle.load(assetPath);
        return data.buffer.asUint8List();
      } catch (e) {
        print("❌ Image not found in assets: $assetPath");
        return null; // Return null if image is missing
      }
    }

    List<pw.Widget> programWidgets = [];
    if (recomendacion["images"] != null && recomendacion["images"].isNotEmpty) {
      programWidgets = await Future.wait(
        recomendacion["images"].map<Future<pw.Widget>>((program) async {
          Uint8List? programImageBytes;
          programImageBytes = await loadAssetImage('${program["image"]}');

          return pw.Container(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(program["name"],
                    style: pw.TextStyle(font: oswaldBoldFont, fontSize: 12.sp)),
                if (programImageBytes != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(
                      pw.MemoryImage(programImageBytes),
                      fit: pw.BoxFit.contain,
                    ),
                  )
                else
                  pw.Text("Imagen no disponible",
                      style: pw.TextStyle(
                          font: oswaldRegularFont, fontSize: 10.sp)),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String infoClienteText = tr(context, 'Información personal');
    String infoAddClienteText = tr(context, 'Información adicional');
    String recoClienteText = tr(context, 'Recomendaciones');
    String programasReco = tr(context, 'Programas sugeridos');
    String clienteText = tr(context, 'Nombre');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');
    String intro = tr(context,
        '''Entrenamiento sugerido\nPara optimizar tu sesión de 25 minutos utilizando los programas recomendados, te sugerimos seguir la siguiente estructura: ''');

    String encabezado1 = tr(context, '1.Calentamiento (4 minutos)');
    String encabezado2 = tr(context, '2.Entrenamiento (18 minutos)');
    String encabezado3 = tr(context, '3.Vuelta a la calma (3 minutos)');

    String calentamiento = tr(context,
        '''Comienza tu sesión con programas de baja frecuencia, como Cardio, Warm Up o Endurance.
Estos programas están diseñados para aumentar progresivamente la frecuencia cardíaca, activar la musculatura y preparar el cuerpo para el entrenamiento principal. Durante esta etapa, combina el uso del EMS con movimientos dinámicos suaves, como caminatas en el lugar, estiramientos dinámicos o movilidad articular.''');

// Extraer los nombres de los programas recomendados
    List<String> programNames = recomendacion["images"]
            ?.map<String>((program) => program["name"].toString())
            .toList() ??
        [];

// Convertir la lista en una cadena separada por comas
    String nombresProgramas = programNames.isNotEmpty
        ? programNames.join(", ")
        : "No hay programas disponibles";

// Crear la cadena con la interpolación
    String entrenamiento = tr(context,
        '''En esta parte central, enfócate en los programas seleccionados para fuerza e hipertrofia muscular, como $nombresProgramas. Estos están diseñados para maximizar la activación muscular y promover el desarrollo de fuerza y masa muscular. 
Asegúrate de ajustar la intensidad de acuerdo con tu nivel y objetivos, y acompaña los estímulos eléctricos con ejercicios funcionales o de resistencia según tu plan.''');

    String relax = tr(context,
        '''Finaliza la sesión con programas específicos para la relajación y recuperación, como Contracturas, Relax o Drenaje. Durante este tiempo, aprovecha para reducir gradualmente la frecuencia cardíaca, realizar estiramientos estáticos o simplemente relajarte. Estos programas ayudan a disminuir la tensión muscular, favorecer la circulación y preparar tu cuerpo para una recuperación óptima.''');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      fichaClienteText.toUpperCase(),
                      style: pw.TextStyle(
                        font: oswaldRegularFont,
                        fontSize: 28.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                    ),
                    pw.Image(logo, height: 70),
                  ],
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
                pw.SizedBox(height: 20),
                // Sección Información Personal (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(infoClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),

                // Cliente info + Imagen
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteText + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientName',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteEdad + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientAge',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clienteAltura + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientHeight cm',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                clientePeso + " : ",
                                style: pw.TextStyle(
                                  font: oswaldBoldFont,
                                  fontSize: 16.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                              pw.Text(
                                '$clientWeight kg',
                                style: pw.TextStyle(
                                  font: oswaldRegularFont,
                                  fontSize: 14.sp,
                                  color: PdfColor.fromHex('#020659'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#020659'),
                        borderRadius:
                        pw.BorderRadius.circular(16), // Radio de 16
                      ),
                      width: 300,
                      height: 300,
                      child: pw.ClipRRect(
                        horizontalRadius: 16,
                        verticalRadius: 16,
                        child: pw.Image(image, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Sección Información Adicional (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(infoAddClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),
                // Lista de resumen
                ...resumen.map((entry) {
                  return pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '${entry["title"]!}: ',
                            style: pw.TextStyle(
                              font: oswaldBoldFont,
                              fontSize: 16.sp,
                              color: PdfColor.fromHex('#020659'),
                            ),
                          ),
                          pw.TextSpan(
                            text: entry["value"]!,
                            style: pw.TextStyle(
                              font: oswaldRegularFont,
                              fontSize: 14.sp,
                              color: PdfColor.fromHex('#020659'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                pw.SizedBox(height: 20),

// Sección Recomendaciones
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    recoClienteText,
                    style: pw.TextStyle(
                      font: oswaldBoldFont,
                      fontSize: 18.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      // Alineación a la izquierda
                      children: [
                        // Texto de programasReco
                        pw.Text(
                          programasReco,
                          style: pw.TextStyle(
                            font: oswaldBoldFont,
                            fontSize: 18.sp,
                            color: PdfColor.fromHex('#020659'),
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 10),
                        // Mostrar imágenes de programas recomendados
                        if (programWidgets.isNotEmpty) ...[
                          pw.Column(
                            children: [
                              for (int i = 0; i < programWidgets.length; i += 2)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  // Alineación a la izquierda
                                  children: [
                                    programWidgets[i],
                                    if (i + 1 < programWidgets.length)
                                      pw.SizedBox(width: 10),
                                    if (i + 1 < programWidgets.length)
                                      programWidgets[i + 1],
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              "Intensidades por músculo: ",
                              style: pw.TextStyle(
                                font: oswaldBoldFont,
                                fontSize: 18.sp,
                                // Texto más grande y en negrita
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                            pw.Text(
                              "${recomendacion["intensidad"]}",
                              style: pw.TextStyle(
                                font: oswaldRegularFont,
                                // Texto normal sin negrita
                                fontSize: 14.sp,
                                // Más pequeño
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Text(
                              "Duración: ",
                              style: pw.TextStyle(
                                font: oswaldBoldFont,
                                fontSize: 18.sp,
                                // Texto más grande y en negrita
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                            pw.Text(
                              "${recomendacion["duracion"]}",
                              style: pw.TextStyle(
                                font: oswaldRegularFont,
                                // Texto normal sin negrita
                                fontSize: 14.sp,
                                // Más pequeño
                                color: PdfColor.fromHex('#020659'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'www.i-motiongroup.com',
                    style: pw.TextStyle(
                      font: oswaldRegularFont,
                      fontSize: 12.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
              ],
            ),
          );
        },
      ),
    );
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // TÍTULO PRINCIPAL
                pw.Text(
                  intro,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 16.sp, // Título más grande y llamativo
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 1: CALENTAMIENTO
                pw.Text(
                  encabezado1,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  calentamiento,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Un poco más pequeño y ordenado
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start, // Justificar el texto
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 2: ENTRENAMIENTO PRINCIPAL
                pw.Text(
                  encabezado2,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  entrenamiento,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Tamaño uniforme y legible
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start,
                ),
                pw.SizedBox(height: 20),

                // SECCIÓN 3: VUELTA A LA CALMA
                pw.Text(
                  encabezado3,
                  style: pw.TextStyle(
                    font: oswaldBoldFont,
                    fontSize: 15.sp, // Negrita y más grande
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  relax,
                  style: pw.TextStyle(
                    font: oswaldRegularFont,
                    fontSize: 13.sp, // Mismo formato
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.start,
                ),

                pw.Spacer(),

                // PIE DE PÁGINA CON DIVISOR
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'www.i-motiongroup.com',
                    style: pw.TextStyle(
                      font: oswaldRegularFont,
                      fontSize: 12.sp,
                      color: PdfColor.fromHex('#020659'),
                    ),
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#020659')),
              ],
            ),
          );
        },
      ),
    );

    // Guardar el PDF en una ubicación temporal
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Abrir el archivo PDF directamente
    await OpenFile.open(file.path);
  }
}
