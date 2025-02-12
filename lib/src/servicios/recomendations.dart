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
  ///PRINCIPIANTES
  FitnessRecommendation(
    experiencia: "Sí",
    condicion: "Principiante",
    diasEntrenamiento: 1,
    objetivo: "Tonificar",
    programas: "Strength 1, Strength 2, Body Building 1, Body Building 2",
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
      programas: "Strength 1, Body Building 1, Abdominal, Body Building 2",
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
      programas: "Suelo Pélvico, Strength 2, Strength 1, Abdominal",
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
      programas: "Abdominal, Strength 1, Body Building 1, Body Building 2",
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
      programas: "Suelo Pélvico, Body Building 2, Strength 1, Abdominal",
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
      programas: "Body Building 2, Suelo Pélvico, Body Building 1, Strength 1",
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
      programas: "Strength 1, Body Building 2, Abdominal, Strength 2",
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
      programas: "Strength 2, Body Building 1, Suelo Pélvico, Strength 1",
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
      programas: "Strength 1, Body Building 2, Abdominal, Suelo Pélvico",
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