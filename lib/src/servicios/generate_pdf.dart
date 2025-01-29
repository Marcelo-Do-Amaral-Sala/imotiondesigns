import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../utils/translation_utils.dart';

class CustomPdfGenerator {
  Future<File> generateAndSavePdf(
    BuildContext context,
    String fileName,
    String? clientName,
    String? clientGender,
    String? clientAge,
    int? clientHeight,
    int? clientWeight,
    List<Map<String, String>> resumen,
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

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String infoClienteText = tr(context, 'Información personal');
    String infoAddClienteText = tr(context, 'Información adicional');
    String recoClienteText = tr(context, 'Recomendaciones');
    String clienteText = tr(context, 'Nombre');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');

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

                // Sección Recomendaciones (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(recoClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),
                // Footer
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

    Future<String> getUniqueFileName(
        String baseName, Directory directory) async {
      int counter = 1;
      String newFileName = baseName;

      // Comprobar si el archivo ya existe
      while (await File(path.join(directory.path, newFileName)).exists()) {
        newFileName = '${baseName.replaceFirst('.pdf', '')}($counter).pdf';
        counter++;
      }

      return newFileName;
    }

    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!directory!.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Usar getUniqueFileName para obtener un nombre único para el archivo
    final uniqueFileName = await getUniqueFileName(fileName, directory);

    final file = File(path.join(directory.path, uniqueFileName));
    await file.writeAsBytes(await pdf.save());
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

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String infoClienteText = tr(context, 'Información personal');
    String infoAddClienteText = tr(context, 'Información adicional');
    String recoClienteText = tr(context, 'Recomendaciones');
    String clienteText = tr(context, 'Nombre');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');

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

                // Sección Recomendaciones (Ocupando todo el ancho)
                pw.Container(
                  width: double.infinity, // Hace que ocupe todo el ancho
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E0E0E0'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(recoClienteText,
                      style: pw.TextStyle(
                        font: oswaldBoldFont,
                        fontSize: 18.sp,
                        color: PdfColor.fromHex('#020659'),
                      ),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 10),
                // Footer
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


    // Guardar el PDF en una ubicación temporal
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Abrir el archivo PDF directamente
    await OpenFile.open(file.path);
  }
}
