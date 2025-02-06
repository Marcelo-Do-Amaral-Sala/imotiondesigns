import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class AutomaticProgramForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Function() onClose;

  const AutomaticProgramForm(
      {super.key, required this.onDataChanged, required this.onClose});

  @override
  AutomaticProgramFormState createState() => AutomaticProgramFormState();
}

class AutomaticProgramFormState extends State<AutomaticProgramForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _tiempoController = TextEditingController();
  final _ajusteController = TextEditingController();
  final _ordenController = TextEditingController();

  String? selectedEquipOption;
  String? selectedProgramOption;
  double scaleFactorTick = 1.0;
  List<Map<String, dynamic>> allPrograms = [];
  List<Map<String, dynamic>> secuencias = [];

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchAllPrograms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _tiempoController.dispose();
    _ajusteController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  void _addSecuenciaCallback(Map<String, dynamic> nuevaSecuencia) {
    setState(() {
      secuencias.add(nuevaSecuencia); // Agregar la secuencia a la lista
    });
  }

  void _eliminarElementoPorId(int idPrograma) {
    setState(() {
      // Eliminar la secuencia donde el id_programa coincida
      secuencias
          .removeWhere((elemento) => elemento['id_programa'] == idPrograma);

      // Después de eliminar, actualizar el orden de las secuencias
      _actualizarOrdenSecuencias();
    });
  }

  void _actualizarOrdenSecuencias() {
    // Primero, ordenar las secuencias por 'orden' de menor a mayor
    secuencias.sort((a, b) => a['orden'].compareTo(b['orden']));

    // Ajustar los 'orden' para que no haya huecos
    for (int i = 0; i < secuencias.length; i++) {
      secuencias[i]['orden'] = i + 1; // Reiniciar el orden de forma consecutiva
    }
  }

  Future<void> _fetchAllPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final programData = await DatabaseHelper().getAllPrograms();

      // Verifica el contenido de los datos obtenidos
      print('Programas obtenidos: $programData');

      // Actualizamos el estado con los programas obtenidos
      setState(() {
        allPrograms =
            programData; // Asignamos los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  Future<void> _crearProgramaAutomatico() async {
    if (_nameController.text.isEmpty ||
        _durationController.text.isEmpty ||
        selectedEquipOption == null ||
        secuencias.isEmpty) {
      // Verificación de '@' en el correo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context,
                  "Por favor, introduzca todos los campos y secuencias"),
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return; // Esto previene la ejecución del código posterior
    }

    // Datos del programa automático
    Map<String, dynamic> programaAuto = {
      'nombre': _nameController.text,
      'imagen': 'assets/images/programacreado.png',
      'descripcion': _descController.text,
      'duracionTotal': double.tryParse(_durationController.text) ?? 0.0,
      'tipo_equipamiento': selectedEquipOption ?? 'BIO-JACKET',
    };

    // Mostrar los datos del programa antes de insertar
    print("Datos del programa automático:");
    print(programaAuto);

    // Insertar el programa automático y obtener su ID
    int programaId = await dbHelper.insertarProgramaAutomatico(programaAuto);

    // Verificar si se insertó correctamente el programa
    if (programaId > 0) {
      print("Programa insertado con éxito, ID: $programaId");

      // Si el programa se insertó correctamente, ahora insertamos los subprogramas
      List<Map<String, dynamic>> subprogramas = secuencias.map((sec) {
        // Obtener el ID del programa seleccionado desde el dropdown
        int? idProgramaSeleccionado = sec[
            'id_programa']; // Asumiendo que en sec tienes el id del programa

        var subprograma = {
          'id_programa_automatico': programaId,
          'id_programa_relacionado': idProgramaSeleccionado,
          'orden': int.tryParse(sec['orden'].toString()) ?? 0,
          'ajuste': double.tryParse(sec['ajuste'].toString()) ?? 0.0,
          'duracion': double.tryParse(sec['duracion'].toString()) ?? 0.0,
        };

        print(
            "Subprograma creado: $subprograma"); // Mostrar cada subprograma creado
        return subprograma;
      }).toList();

      // Verificar el contenido de la lista de subprogramas
      print("Lista de subprogramas:");
      print(subprogramas);

      bool success =
          await dbHelper.insertAutomaticProgram(programaId, subprogramas);

      // Notificar al usuario sobre el resultado
      if (mounted) {
        if (success) {
          print("Subprogramas insertados con éxito.");
        } else {
          print("Error al insertar los subprogramas.");
        }
      }
    } else {
      print("Error al insertar el programa automático.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.05,
          horizontal: screenWidth * 0.05,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Fila 1: Campos ID, Nombre, Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                tr(context, 'Nombre del programa')
                                    .toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _nameController,
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context,
                                      'Introducir nombre del programa'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Duración').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _durationController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$')),
                                  // Permite números enteros y decimales
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context,
                                      'Introducir duración del programa'),
                                  enabled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Equipamiento').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text(tr(context, 'Seleccione'),
                                    style: _dropdownHintStyle),
                                value: selectedEquipOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BIO-JACKET',
                                    child: Text('BIO-JACKET',
                                        style: _dropdownItemStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'BIO-SHAPE',
                                    child: Text('BIO-SHAPE',
                                        style: _dropdownItemStyle),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedEquipOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon:  Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF2be4f3), size: screenHeight*0.05),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.5,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 46, 46, 46),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.01,
                                vertical: MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Column(
                                children: [
                                  // Encabezados de la tabla (no desplazables)
                                  Table(
                                    columnWidths: const {
                                      0: FractionColumnWidth(0.15),
                                      // 20% del ancho para la primera columna
                                      1: FractionColumnWidth(0.3),
                                      // 40% del ancho para la segunda columna
                                      2: FractionColumnWidth(0.2),
                                      // 20% del ancho para la tercera columna
                                      3: FractionColumnWidth(0.2),
                                      // 20% del ancho para la cuarta columna
                                      4: FractionColumnWidth(0.15),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.01,
                                              vertical: MediaQuery.of(context).size.height * 0.01,
                                            ),
                                            child: Center(
                                              child: Text(
                                                tr(context, 'Orden')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.01,
                                              vertical: MediaQuery.of(context).size.height * 0.01,
                                            ),
                                            child: Center(
                                              child: Text(
                                                tr(context, 'Programa')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.01,
                                              vertical: MediaQuery.of(context).size.height * 0.01,
                                            ),
                                            child: Center(
                                              child: Text(
                                                tr(context, 'Duración')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.01,
                                              vertical: MediaQuery.of(context).size.height * 0.01,
                                            ),
                                            child: Center(
                                              child: Text(
                                                tr(context, 'Ajuste')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.01,
                                              vertical: MediaQuery.of(context).size.height * 0.01,
                                            ),
                                            child: Center(
                                              child: Text(
                                                tr(context, 'Acción')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Filas dinámicas de la tabla (desplazables)
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: _ordenarSecuencias(secuencias)
                                            .map((secuencia) {
                                          return Table(
                                            columnWidths: const {
                                              0: FractionColumnWidth(0.15),
                                              // 20% del ancho para la primera columna
                                              1: FractionColumnWidth(0.3),
                                              // 40% del ancho para la segunda columna
                                              2: FractionColumnWidth(0.2),
                                              // 20% del ancho para la tercera columna
                                              3: FractionColumnWidth(0.2),
                                              // 20% del ancho para la cuarta columna
                                              4: FractionColumnWidth(0.15),
                                            },
                                            children: [
                                              TableRow(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.01,
                                                      vertical: MediaQuery.of(context).size.height * 0.01,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${secuencia['orden']}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.01,
                                                      vertical: MediaQuery.of(context).size.height * 0.01,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${secuencia['programa']}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.01,
                                                      vertical: MediaQuery.of(context).size.height * 0.01,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${secuencia['duracion']}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.01,
                                                      vertical: MediaQuery.of(context).size.height * 0.01,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${secuencia['ajuste']}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          // Acceder al id del programa de la secuencia
                                                          int idPrograma =
                                                              secuencia[
                                                                  'id_programa'];
                                                          _eliminarElementoPorId(
                                                              idPrograma); // Llamar a la función para eliminar por ID
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        OutlinedButton(
                          onPressed: () {
                            _addSecuencia(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.01,
                              vertical: MediaQuery.of(context).size.height * 0.01,
                            ),
                            side:  BorderSide(
                                width: screenWidth*0.001, color: Color(0xFF2be4f3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            tr(context, 'Crear secuencia').toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            SizedBox(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTapDown: (_) => setState(() => scaleFactorTick = 0.9),
                      onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                      onTap: () async {
                        if (_nameController.text.isEmpty ||
                            _durationController.text.isEmpty ||
                            selectedEquipOption == null ||
                            secuencias.isEmpty) {
                          // Verificación de '@' en el correo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr(context,
                                    "Por favor, introduzca todos los campos y secuencias").toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17.sp),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        await _addProgramaAuto(context);
                      },
                      child: AnimatedScale(
                        scale: scaleFactorTick,
                        duration: const Duration(milliseconds: 100),
                        child: SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.1,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/tick.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _ordenarSecuencias(
      List<Map<String, dynamic>> secuencias) {
    // Asegúrate de que 'orden' es un número entero
    for (var secuencia in secuencias) {
      secuencia['orden'] = int.tryParse(secuencia['orden'].toString()) ?? 0;
    }

    // Ordenar las secuencias por 'orden' de menor a mayor
    secuencias.sort((a, b) => a['orden'].compareTo(b['orden']));

    // Ajustar los 'orden' en caso de duplicados
    for (int i = 1; i < secuencias.length; i++) {
      if (secuencias[i]['orden'] == secuencias[i - 1]['orden']) {
        secuencias[i]['orden'] =
            secuencias[i - 1]['orden'] + 1; // Incrementar el orden
      }
    }

    return secuencias;
  }

  Future<void> _addProgramaAuto(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF494949),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF2be4f3), width: screenWidth * 0.001),
            borderRadius: BorderRadius.circular(7),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajuste dinámico
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: const Border(bottom: BorderSide(color: Color(0xFF2be4f3))),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          tr(context, 'Agregar programa automático').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2be4f3)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            _descController.clear();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close_sharp, color: Colors.white, size: screenHeight * 0.07),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        tr(context, "¡Estás a un paso de terminar! Solo falta añadir una descripción para guardar tu programa"),
                        style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        style: _inputTextStyle,
                        decoration: _inputDecorationStyle(hintText: tr(context, 'Añadir una descripción')),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      GestureDetector(
                        onTap: () async {
                          _crearProgramaAutomatico();
                          Navigator.pop(context);
                          await widget.onClose();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr(context, "Programa automático creado correctamente").toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 17.sp),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.1,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/tick.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _addSecuencia(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? localSelectedProgram = selectedProgramOption;
        int? localSelectedProgramId =
            null; // Variable para almacenar el ID del programa seleccionado

        return Dialog(
          backgroundColor: const Color(0xFF494949),
          shape: RoundedRectangleBorder(
            side:  BorderSide(color: Color(0xFF2be4f3), width: screenWidth*0.001),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.6,
              maxWidth: screenWidth * 0.6,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado del diálogo
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.1,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: const Border(
                          bottom: BorderSide(color: Color(0xFF2be4f3)),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              tr(context, 'Crear secuencia').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2be4f3),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              onPressed: () {
                                _descController.clear();
                                _ordenController.clear();
                                _tiempoController.clear();
                                _ajusteController.clear();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                                size: screenHeight*0.07,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                tr(context, 'Selección programa').toUpperCase(),
                                style: _labelStyle),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding:  EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.05),
                                  width: screenWidth * 0.3,
                                  alignment: Alignment.centerLeft,
                                  decoration: _inputDecoration(),
                                  child: DropdownButton<String>(
                                    value: localSelectedProgram,
                                    items: allPrograms.map((program) {
                                      return DropdownMenuItem<String>(
                                        value: program['nombre'],
                                        child: Text(
                                          '${program['id_programa']} - ${program['nombre']}',
                                          style: _dropdownItemStyle,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        localSelectedProgram = value;
                                        // Al seleccionar un programa, guardar su ID también
                                        localSelectedProgramId =
                                            allPrograms.firstWhere((program) =>
                                                program['nombre'] ==
                                                value)['id_programa'];
                                      });
                                    },
                                    dropdownColor: const Color(0xFF313030),
                                    icon:  Icon(Icons.arrow_drop_down,
                                        color: Color(0xFF2be4f3), size: screenHeight*0.05),
                                    hint: Text(
                                      tr(context, 'Seleccione un programa'),
                                      style: _dropdownHintStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tr(context, 'Orden').toUpperCase(),
                                          style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _ordenController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: ''),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${tr(context, 'Duración').toUpperCase()} (s)',
                                          style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _tiempoController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                            // Permite números enteros y decimales
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: '', enabled: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tr(context, 'Ajuste').toUpperCase(),
                                          style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _ajusteController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                            // Permite números enteros y decimales
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: '', enabled: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => scaleFactorTick = 0.9),
                                  onTapUp: (_) =>
                                      setState(() => scaleFactorTick = 1.0),
                                  onTap: () async {
                                    // Verificar los valores que se están recogiendo
                                    print(
                                        "Programa Seleccionado: $localSelectedProgram");
                                    print(
                                        "ID Programa Seleccionado: $localSelectedProgramId");
                                    print("Orden: ${_ordenController.text}");
                                    print(
                                        "Duración: ${_tiempoController.text}");
                                    print("Ajuste: ${_ajusteController.text}");

                                    // Guardar la secuencia y actualizar la UI
                                    if (localSelectedProgram != null &&
                                        localSelectedProgramId != null) {
                                      Map<String, dynamic> nuevaSecuencia = {
                                        'programa': localSelectedProgram,
                                        'id_programa': localSelectedProgramId,
                                        // Guardar el ID del programa
                                        'orden': _ordenController.text,
                                        'duracion': _tiempoController.text,
                                        'ajuste': _ajusteController.text,
                                      };

                                      _addSecuenciaCallback(
                                          nuevaSecuencia); // Actualiza el estado en el widget principal

                                      // Limpiar los campos
                                      _ordenController.clear();
                                      _tiempoController.clear();
                                      _ajusteController.clear();

                                      setState(
                                          () {}); // Asegúrate de que el diálogo se actualice

                                      Navigator.of(context)
                                          .pop(); // Cerrar el diálogo
                                    }
                                  },
                                  child: AnimatedScale(
                                    scale: scaleFactorTick,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
                                      width: screenWidth * 0.1,
                                      height: screenHeight * 0.1,
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/tick.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownHintStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownItemStyle =>
      TextStyle(color: Colors.white, fontSize: 15.sp);

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
