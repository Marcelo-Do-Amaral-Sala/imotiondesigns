import 'package:flutter/material.dart';

class ClientsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _selectedClients = [];

  // Obtiene la lista de clientes seleccionados
  List<Map<String, dynamic>> get selectedClients => _selectedClients;

  // Agrega un cliente si no está ya en la lista
  void addClient(Map<String, dynamic> client) {
    if (!_selectedClients.any((c) => c['id'] == client['id'])) {
      _selectedClients.add(client);
      notifyListeners(); // Notifica a los widgets que están escuchando
    }
  }

  // Elimina un cliente por su ID
  void removeClient(Map<String, dynamic> client) {
    _selectedClients.removeWhere((c) => c['id'] == client['id']);
    notifyListeners(); // Notifica después de eliminar
  }

  // Limpia todos los clientes seleccionados sin notificar
  void clearSelectedClientsSilently() {
    _selectedClients.clear(); // Limpia los datos sin notificar
  }
}