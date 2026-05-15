import 'package:flutter/material.dart';

enum ReportFilterMode { currentMonth, customRange }

class ReportFilter {
  final ReportFilterMode mode;
  final DateTime? from;
  final DateTime? to;

  const ReportFilter({required this.mode, this.from, this.to});

  factory ReportFilter.currentMonth() {
    return const ReportFilter(mode: ReportFilterMode.currentMonth);
  }

  DateTimeRange resolveRange({DateTime? now}) {
    final DateTime baseNow = now ?? DateTime.now();
    if (mode == ReportFilterMode.currentMonth) {
      final start = DateTime(baseNow.year, baseNow.month, 1);
      final end = DateTime(baseNow.year, baseNow.month + 1, 0, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    }

    if (from == null || to == null) {
      throw ArgumentError('For custom range, "from" and "to" are required.');
    }
    final start = DateTime(from!.year, from!.month, from!.day);
    final end = DateTime(to!.year, to!.month, to!.day, 23, 59, 59, 999);
    if (end.isBefore(start)) {
      throw ArgumentError('"to" date must be equal or after "from" date.');
    }
    return DateTimeRange(start: start, end: end);
  }
}

class ReportAnimalRow {
  final String animalId;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final String estadoAdopcion;
  final String estadoSalud;
  final String historialMedicoId;
  final String fechaIngresoRaw;
  final DateTime? fechaIngresoParsed;
  final bool fechaIngresoValida;
  final bool ingresoEnPeriodo;

  const ReportAnimalRow({
    required this.animalId,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.estadoAdopcion,
    required this.estadoSalud,
    required this.historialMedicoId,
    required this.fechaIngresoRaw,
    required this.fechaIngresoParsed,
    required this.fechaIngresoValida,
    required this.ingresoEnPeriodo,
  });
}

class ReportHealthRow {
  final String animalId;
  final String animalNombre;
  final String especie;
  final String historialId;
  final String castrado;
  final String peso;
  final String enfermedades;
  final String tratamiento;
  final String fechaRevisionRaw;
  final DateTime? fechaRevisionParsed;
  final bool fechaRevisionValida;
  final bool revisionEnPeriodo;

  const ReportHealthRow({
    required this.animalId,
    required this.animalNombre,
    required this.especie,
    required this.historialId,
    required this.castrado,
    required this.peso,
    required this.enfermedades,
    required this.tratamiento,
    required this.fechaRevisionRaw,
    required this.fechaRevisionParsed,
    required this.fechaRevisionValida,
    required this.revisionEnPeriodo,
  });
}

class ReportVaccineRow {
  final String animalId;
  final String animalNombre;
  final String especie;
  final String vacunaId;
  final String vacunaNombre;
  final String fechaAplicacionRaw;
  final DateTime? fechaAplicacionParsed;
  final bool fechaAplicacionValida;
  final bool aplicacionEnPeriodo;
  final String proximaFechaRaw;
  final DateTime? proximaFechaParsed;
  final bool proximaFechaValida;
  final String estadoVacuna;
  final String veterinario;
  final String lote;
  final String observaciones;

  const ReportVaccineRow({
    required this.animalId,
    required this.animalNombre,
    required this.especie,
    required this.vacunaId,
    required this.vacunaNombre,
    required this.fechaAplicacionRaw,
    required this.fechaAplicacionParsed,
    required this.fechaAplicacionValida,
    required this.aplicacionEnPeriodo,
    required this.proximaFechaRaw,
    required this.proximaFechaParsed,
    required this.proximaFechaValida,
    required this.estadoVacuna,
    required this.veterinario,
    required this.lote,
    required this.observaciones,
  });
}

class ReportDataset {
  final List<ReportAnimalRow> animales;
  final List<ReportHealthRow> salud;
  final List<ReportVaccineRow> vacunas;

  const ReportDataset({
    required this.animales,
    required this.salud,
    required this.vacunas,
  });
}

class ReportStats {
  final int totalAnimales;
  final int altasPeriodo;
  final int especiePerro;
  final int especieGato;
  final int especieOtros;
  final int adopcionDisponible;
  final int adopcionNoDisponible;
  final int casosEnfermedades;
  final double porcentajeEnfermedades;
  final int vacunasAplicadasPeriodo;
  final int vacunasVencidas;
  final int vacunasProximas;

  const ReportStats({
    required this.totalAnimales,
    required this.altasPeriodo,
    required this.especiePerro,
    required this.especieGato,
    required this.especieOtros,
    required this.adopcionDisponible,
    required this.adopcionNoDisponible,
    required this.casosEnfermedades,
    required this.porcentajeEnfermedades,
    required this.vacunasAplicadasPeriodo,
    required this.vacunasVencidas,
    required this.vacunasProximas,
  });
}

class ReportBuildResult {
  final String refugioId;
  final ReportFilter filter;
  final DateTimeRange range;
  final DateTime generatedAt;
  final ReportDataset dataset;
  final ReportStats stats;

  const ReportBuildResult({
    required this.refugioId,
    required this.filter,
    required this.range,
    required this.generatedAt,
    required this.dataset,
    required this.stats,
  });
}
