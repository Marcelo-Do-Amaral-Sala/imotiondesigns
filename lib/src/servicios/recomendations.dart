import 'package:flutter/material.dart';

class FitnessRecommendation {
  final String experiencia;
  final String condicion;
  final int diasEntrenamiento;
  final String objetivo;
  final String programas;
  final String intensidad;
  final String duracion;

  FitnessRecommendation({
    required this.experiencia,
    required this.condicion,
    required this.diasEntrenamiento,
    required this.objetivo,
    required this.programas,
    required this.intensidad,
    required this.duracion,
  });

  @override
  String toString() {
    return "Para el objetivo '$objetivo' con experiencia '$experiencia', condición física '$condicion' y entrenamiento $diasEntrenamiento días a la semana, se recomienda los programas: $programas, con una intensidad de $intensidad y una duración de $duracion.";
  }
}

List<FitnessRecommendation> recommendations = [
  FitnessRecommendation(
    experiencia: "Sí",
    condicion: "Principiante",
    diasEntrenamiento: 1,
    objetivo: "Tonificar",
    programas: "Strength 1, Strength 2, Body Building 1, Body Building 2",
    intensidad: "10%-30%",
    duracion: "25 minutos por sesión",
  ),
];

FitnessRecommendation? getRecommendation(String experiencia, String condicion, int diasEntrenamiento, String objetivo) {
  return recommendations.firstWhere(
        (rec) => rec.experiencia.toLowerCase() == experiencia.toLowerCase() &&
        rec.condicion.toLowerCase() == condicion.toLowerCase() &&
        rec.diasEntrenamiento == diasEntrenamiento &&
        rec.objetivo.toLowerCase() == objetivo.toLowerCase(),
    orElse: () => FitnessRecommendation(
      experiencia: experiencia,
      condicion: condicion,
      diasEntrenamiento: diasEntrenamiento,
      objetivo: objetivo,
      programas: "No se encontraron programas recomendados",
      intensidad: "N/A",
      duracion: "N/A",
    ),
  );
}