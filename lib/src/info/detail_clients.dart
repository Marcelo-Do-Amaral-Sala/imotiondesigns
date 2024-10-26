import 'package:flutter/material.dart';

class DetailsView extends StatelessWidget {
  final Map<String, String> data;

  const DetailsView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${data['id']}', style: const TextStyle(color: Colors.white)),
            Text('Nombre: ${data['name']}', style: const TextStyle(color: Colors.white)),
            Text('Teléfono: ${data['phone']}', style: const TextStyle(color: Colors.white)),
            Text('Estado: ${data['status']}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}