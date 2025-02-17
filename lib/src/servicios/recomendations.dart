import 'package:flutter/material.dart';

import '../../utils/translation_utils.dart';

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

  FitnessRecommendation translated(BuildContext context) {
    return FitnessRecommendation(
      experiencia: tr(context,experiencia),
      condicion: tr(context,condicion),
      diasEntrenamiento: diasEntrenamiento,
      objetivo: tr(context,objetivo),
      programas: programas,
      intensidad: intensidad, // No es necesario traducir si es un rango numérico
      duracion: tr(context,duracion),
    );
  }

  @override
  String toString() {
    return "Para el objetivo '$objetivo' con experiencia '$experiencia', condición física '$condicion' y entrenamiento $diasEntrenamiento días a la semana, se recomienda los programas: $programas, con una intensidad de $intensidad y una duración de $duracion.";
  }
}


List<FitnessRecommendation> recommendations = [
  ///PRINCIPIANTES
  FitnessRecommendation(
    experiencia: "Sí",
    condicion: "Principiante",
    diasEntrenamiento: 1,
    objetivo: "Tonificar",
    programas: "Fuerza 1, Fuerza 2, Body Building 1, Body Building 2",
    intensidad: "10%-30%",
    duracion: "25 minutos por sesión",
  ),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 1,
      objetivo: "Perder grasa",
      programas: "Definición, Celulitis, Resistencia, Slim",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 1,
      objetivo: "Mejorar resistencia",
      programas: "Cardio, Resistencia, Definición, Abdominal",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 1,
      objetivo: "Mejorar todo",
      programas: "Slim, Drenaje, Resistencia, Relax",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 1,
      objetivo: "Recuperación muscular",
      programas: "Contracturas, Drenaje, Relax, Metabolic",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 2,
      objetivo: "Tonificar",
      programas: "Fuerza 1, Body Building 1, Abdominal, Body Building 2",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 2,
      objetivo: "Perder grasa",
      programas: "Slim, Celulitis, Definición, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 2,
      objetivo: "Mejorar resistencia",
      programas: "Abdominal, Cardio, Definición, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 2,
      objetivo: "Mejorar todo",
      programas: "Drenaje, Body Building 1, Relax, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 2,
      objetivo: "Recuperación muscular",
      programas: "Drenaje, Contracturas, Relax, Metabolic",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 3,
      objetivo: "Tonificar",
      programas: "Suelo Pélvico, Fuerza 2, Fuerza 1, Abdominal",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 3,
      objetivo: "Perder grasa",
      programas: "Celulitis, Fitness, Definición, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 3,
      objetivo: "Mejorar resistencia",
      programas: "Definición, Cardio, Abdominal, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 3,
      objetivo: "Mejorar todo",
      programas: "Definición, Bodybuilding 1, Slim, Resistencia",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Principiante",
      diasEntrenamiento: 3,
      objetivo: "Recuperación muscular",
      programas: "Capillary, Contracturas, Metabolic, Drenaje",
      intensidad: "10%-30%",
      duracion: "25 minutos por sesión"),

  ///INTERMEDIOS
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 1,
      objetivo: "Tonificar",
      programas: "Abdominal, Fuerza 1, Body Building 1, Body Building 2",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 1,
      objetivo: "Perder grasa",
      programas: "Resistencia, Celulitis, Slim, Definición",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 1,
      objetivo: "Mejorar resistencia",
      programas: "Cardio, Abdominal, Definición, Resistencia",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 1,
      objetivo: "Mejorar todo",
      programas: "Drenaje, Definición, Slim, Body Building 1",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 1,
      objetivo: "Recuperación muscular",
      programas: "Contracturas, Capillary, Metabolic, Relax",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 2,
      objetivo: "Tonificar",
      programas: "Suelo Pélvico, Body Building 2, Fuerza 1, Abdominal",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 2,
      objetivo: "Perder peso",
      programas: "Celulitis, Definición, Resistencia, Slim",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 2,
      objetivo: "Mejorar resistencia",
      programas: "Abdominal, Resistencia, Definición, Cardio",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 2,
      objetivo: "Mejorar todo",
      programas: "Slim, Resistencia, Body Building 1, Relax",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 2,
      objetivo: "Recuperación musuclar",
      programas: "Capillary, Drenaje, Relax, Contracturas",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 3,
      objetivo: "Tonificar",
      programas: "Body Building 2, Suelo Pélvico, Body Building 1, Fuerza 1",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 3,
      objetivo: "Perder grasa",
      programas: "Resistencia, Celulitis, Slim, Fitness",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 3,
      objetivo: "Mejorar resistencia",
      programas: "Cardio, Resistencia, Abdominal, Definición",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 3,
      objetivo: "Mejorar todo",
      programas: "Slim, Definición, Resistencia, Body Building 1",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Intermedio",
      diasEntrenamiento: 3,
      objetivo: "Recuperación muscular",
      programas: "Metabolic, Relax, Drenaje, Capillary",
      intensidad: "20%-40%",
      duracion: "25 minutos por sesión"),

  ///AVANZADOS
  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 1,
      objetivo: "Tonificar",
      programas: "Fuerza 1, Body Building 2, Abdominal, Fuerza 2",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 1,
      objetivo: "Perder grasa",
      programas: "Resistencia, Fitness, Celulitis, Definición",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 1,
      objetivo: "Mejorar resistencia",
      programas: "Cardio, Abdominal, Definición, Resistencia",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 1,
      objetivo: "Mejorar todo",
      programas: "Definición, Relax, Body Building 1, Slim",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 1,
      objetivo: "Recuperación muscular",
      programas: "Metabolic, Drenaje, Capillary, Relax",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 2,
      objetivo: "Tonificar",
      programas: "Fuerza 2, Body Building 1, Suelo Pélvico, Fuerza 1",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 2,
      objetivo: "Perder grasa",
      programas: "Resistencia, Fitness, Definición, Slim",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 2,
      objetivo: "Mejorar resistencia",
      programas: "Definición, Abdominal, Resistencia, Cardio",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 2,
      objetivo: "Mejorar todo",
      programas: "Body Building 1, Slim, Resistencia, Relax",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 2,
      objetivo: "Recuperación muscular",
      programas: "Capillary, Contracturas, Metabolic, Drenaje",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 3,
      objetivo: "Tonificar",
      programas: "Fuerza 1, Body Building 2, Abdominal, Suelo Pélvico",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 3,
      objetivo: "Perder grasa",
      programas: "Celulitis, Definición, Fitness, Resistencia",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 3,
      objetivo: "Mejorar resistencia",
      programas: "Abdominal, Cardio, Resistencia, Definición",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 3,
      objetivo: "Mejorar todo",
      programas: "Body Building 1, Definición, Drenaje, Slim",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),

  FitnessRecommendation(
      experiencia: "Sí",
      condicion: "Avanzado",
      diasEntrenamiento: 3,
      objetivo: "Recuperación muscular",
      programas: "Capillary, Metabolic, Contracturas, Relax",
      intensidad: "40%-70%",
      duracion: "25 minutos por sesión"),
];

/// 🔹 Nueva función para traducir todas las recomendaciones antes de buscar
List<FitnessRecommendation> getTranslatedRecommendations(BuildContext context) {
  return recommendations.map((rec) => rec.translated(context)).toList();
}

/// 🔹 Obtener recomendación buscando en la lista traducida
FitnessRecommendation? getRecommendation(
    BuildContext context,
    String experiencia,
    String condicion,
    int diasEntrenamiento,
    String objetivo,
    ) {
  // Si experiencia es "No", se ignoran los demás campos y se retorna la primera recomendación.
  if (experiencia.toLowerCase() == "no") {
    print("Experiencia es 'No': se retorna la recomendación por defecto.");
    return getTranslatedRecommendations(context).first;
  }

  List<FitnessRecommendation> translatedRecommendations = getTranslatedRecommendations(context);

  print("🔍 Buscando recomendación en lista traducida con los valores:");
  print("Experiencia: $experiencia");
  print("Condición: $condicion");
  print("Días de entrenamiento: $diasEntrenamiento");
  print("Objetivo: $objetivo");

  FitnessRecommendation? recomendacion = translatedRecommendations.firstWhere(
        (rec) =>
    rec.experiencia.toLowerCase() == experiencia.toLowerCase() &&
        rec.condicion.toLowerCase() == condicion.toLowerCase() &&
        rec.diasEntrenamiento == diasEntrenamiento &&
        rec.objetivo.toLowerCase() == objetivo.toLowerCase(),
    orElse: () {
      print("⚠️ No se encontró ninguna recomendación para los valores dados.");
      return FitnessRecommendation(
        experiencia: experiencia,
        condicion: condicion,
        diasEntrenamiento: diasEntrenamiento,
        objetivo: objetivo,
        programas: tr(context, "No se encontraron programas recomendados"),
        intensidad: "N/A",
        duracion: "N/A",
      );
    },
  );

  print("✅ Recomendación encontrada:");
  print(recomendacion.toString());

  return recomendacion;
}

