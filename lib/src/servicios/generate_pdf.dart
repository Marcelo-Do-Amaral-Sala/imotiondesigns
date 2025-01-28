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
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    final background = pw.MemoryImage(
      (await rootBundle.load('assets/images/fondo.jpg')).buffer.asUint8List(),
    );

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String clienteText = tr(context, 'Cliente');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(background, fit: pw.BoxFit.cover),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Image(logo, height: 100),
                        pw.Text(
                          fichaClienteText.toUpperCase(),
                          style: pw.TextStyle(
                            font: oswaldBoldFont,
                            decoration: pw.TextDecoration.underline,
                            decorationColor: PdfColor.fromInt(0xFF2be4f3),
                            fontSize: 30.sp,
                            color: PdfColor.fromInt(0xFF2be4f3),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteText + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientName',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteEdad + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientAge',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteAltura + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientHeight cm',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clientePeso + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientWeight kg',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.Spacer(),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 300,
                              height: 300,
                              child: pw.Image(image, fit: pw.BoxFit.contain),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.black,
                        width: 0.5,
                      ),
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(1),
                      },
                      children: [
                        ...resumen.map((entry) {
                          return pw.TableRow(
                            children: [
                              pw.Container(
                                alignment: pw.Alignment.center,
                                color: PdfColor.fromInt(0xFF2be4f3),
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  entry["title"]!,
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.center,
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  entry["value"]!,
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 14.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        '${context.pageNumber} / ${context.pagesCount}',
                        style: pw.TextStyle(
                          font: oswaldRegularFont,
                          fontSize: 10.sp,
                          color: PdfColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    final background = pw.MemoryImage(
      (await rootBundle.load('assets/images/fondo.jpg')).buffer.asUint8List(),
    );

    // Traducir los textos antes de generar el PDF
    String fichaClienteText = tr(context, 'Ficha de cliente');
    String clienteText = tr(context, 'Cliente');
    String clienteEdad = tr(context, 'Edad');
    String clienteAltura = tr(context, 'Altura (cm)');
    String clientePeso = tr(context, 'Peso (kg)');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(background, fit: pw.BoxFit.cover),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Image(logo, height: 100),
                        pw.Text(
                          fichaClienteText.toUpperCase(),
                          style: pw.TextStyle(
                            font: oswaldBoldFont,
                            decoration: pw.TextDecoration.underline,
                            decorationColor: PdfColor.fromInt(0xFF2be4f3),
                            fontSize: 30.sp,
                            color: PdfColor.fromInt(0xFF2be4f3),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteText + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientName',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteEdad + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientAge',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clienteAltura + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientHeight cm',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  clientePeso + " :",
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 18.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  '$clientWeight kg',
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.Spacer(),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 300,
                              height: 300,
                              child: pw.Image(image, fit: pw.BoxFit.contain),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.black,
                        width: 0.5,
                      ),
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(1),
                      },
                      children: [
                        ...resumen.map((entry) {
                          return pw.TableRow(
                            children: [
                              pw.Container(
                                alignment: pw.Alignment.center,
                                color: PdfColor.fromInt(0xFF2be4f3),
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  entry["title"]!,
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: oswaldBoldFont,
                                    fontSize: 16.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.center,
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  entry["value"]!,
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: oswaldRegularFont,
                                    fontSize: 14.sp,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        '${context.pageNumber} / ${context.pagesCount}',
                        style: pw.TextStyle(
                          font: oswaldRegularFont,
                          fontSize: 10.sp,
                          color: PdfColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
