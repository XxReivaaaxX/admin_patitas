import 'dart:typed_data';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/report_models.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:excel_community/excel_community.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportService {
  final AnimalsService _animalsService;
  final HistorialMedicoService _historialService;
  final VacunaService _vacunaService;

  ReportService({
    AnimalsService? animalsService,
    HistorialMedicoService? historialService,
    VacunaService? vacunaService,
  }) : _animalsService = animalsService ?? AnimalsService(),
       _historialService = historialService ?? HistorialMedicoService(),
       _vacunaService = vacunaService ?? VacunaService();

  Future<ReportBuildResult> buildReportData(
    String refugioId,
    ReportFilter filter,
  ) async {
    final DateTimeRange range = filter.resolveRange();
    final DateTime generatedAt = DateTime.now();
    final List<Animal> animals = await _animalsService.getAnimals(refugioId);

    final bundles = await Future.wait(
      animals.map((animal) => _buildBundle(refugioId, animal)),
    );

    final List<ReportAnimalRow> animalRows = [];
    final List<ReportHealthRow> healthRows = [];
    final List<ReportVaccineRow> vaccineRows = [];

    for (final bundle in bundles) {
      final ingreso = _dateInfo(bundle.animal.fechaIngreso, range);

      animalRows.add(
        ReportAnimalRow(
          animalId: bundle.animal.id,
          nombre: bundle.animal.nombre,
          especie: bundle.animal.especie,
          raza: bundle.animal.raza,
          sexo: bundle.animal.genero,
          estadoAdopcion: bundle.animal.estadoAdopcion,
          estadoSalud: bundle.animal.estadoSalud,
          historialMedicoId: bundle.animal.historialMedicoId,
          fechaIngresoRaw: bundle.animal.fechaIngreso,
          fechaIngresoParsed: ingreso.parsed,
          fechaIngresoValida: ingreso.isValid,
          ingresoEnPeriodo: ingreso.inRange,
        ),
      );

      if (bundle.historial != null) {
        final review = _dateInfo(bundle.historial!.fechaRevision, range);
        healthRows.add(
          ReportHealthRow(
            animalId: bundle.animal.id,
            animalNombre: bundle.animal.nombre,
            especie: bundle.animal.especie,
            historialId: bundle.historial!.id,
            castrado: bundle.historial!.castrado,
            peso: bundle.historial!.peso,
            enfermedades: bundle.historial!.enfermedades,
            tratamiento: bundle.historial!.tratamiento,
            fechaRevisionRaw: bundle.historial!.fechaRevision,
            fechaRevisionParsed: review.parsed,
            fechaRevisionValida: review.isValid,
            revisionEnPeriodo: review.inRange,
          ),
        );
      } else {
        healthRows.add(
          ReportHealthRow(
            animalId: bundle.animal.id,
            animalNombre: bundle.animal.nombre,
            especie: bundle.animal.especie,
            historialId: 'N/A',
            castrado: 'N/A',
            peso: 'N/A',
            enfermedades: 'N/A',
            tratamiento: 'N/A',
            fechaRevisionRaw: '',
            fechaRevisionParsed: null,
            fechaRevisionValida: false,
            revisionEnPeriodo: false,
          ),
        );
      }

      if (bundle.vacunas.isEmpty) {
        vaccineRows.add(
          ReportVaccineRow(
            animalId: bundle.animal.id,
            animalNombre: bundle.animal.nombre,
            especie: bundle.animal.especie,
            vacunaId: 'N/A',
            vacunaNombre: 'N/A',
            fechaAplicacionRaw: '',
            fechaAplicacionParsed: null,
            fechaAplicacionValida: false,
            aplicacionEnPeriodo: false,
            proximaFechaRaw: '',
            proximaFechaParsed: null,
            proximaFechaValida: false,
            estadoVacuna: 'N/A',
            veterinario: 'N/A',
            lote: 'N/A',
            observaciones: 'N/A',
          ),
        );
      } else {
        for (final vacuna in bundle.vacunas) {
          final aplicacion = _dateInfo(vacuna.fecha, range);
          final proxima = _tryParseDate(vacuna.proximaFecha);
          vaccineRows.add(
            ReportVaccineRow(
              animalId: bundle.animal.id,
              animalNombre: bundle.animal.nombre,
              especie: bundle.animal.especie,
              vacunaId: vacuna.id,
              vacunaNombre: vacuna.nombre,
              fechaAplicacionRaw: vacuna.fecha,
              fechaAplicacionParsed: aplicacion.parsed,
              fechaAplicacionValida: aplicacion.isValid,
              aplicacionEnPeriodo: aplicacion.inRange,
              proximaFechaRaw: vacuna.proximaFecha,
              proximaFechaParsed: proxima,
              proximaFechaValida: proxima != null,
              estadoVacuna: ReportService.classifyVaccineStatus(
                proximaFecha: proxima,
                now: generatedAt,
              ),
              veterinario: vacuna.veterinario,
              lote: vacuna.lote,
              observaciones: vacuna.observaciones,
            ),
          );
        }
      }
    }

    final stats = ReportService.calculateStats(
      animalRows: animalRows,
      healthRows: healthRows,
      vaccineRows: vaccineRows,
      now: generatedAt,
    );

    return ReportBuildResult(
      refugioId: refugioId,
      filter: filter,
      range: range,
      generatedAt: generatedAt,
      dataset: ReportDataset(
        animales: animalRows,
        salud: healthRows,
        vacunas: vaccineRows,
      ),
      stats: stats,
    );
  }

  static ReportStats calculateStats({
    required List<ReportAnimalRow> animalRows,
    required List<ReportHealthRow> healthRows,
    required List<ReportVaccineRow> vaccineRows,
    required DateTime now,
  }) {
    int perros = 0;
    int gatos = 0;
    int otros = 0;
    int disponible = 0;
    int noDisponible = 0;
    int altasPeriodo = 0;

    for (final row in animalRows) {
      final especie = row.especie.toLowerCase().trim();
      if (especie == 'perro' || especie == 'canino') {
        perros++;
      } else if (especie == 'gato' || especie == 'felino') {
        gatos++;
      } else {
        otros++;
      }

      final adopcion = row.estadoAdopcion.toLowerCase().trim();
      if (adopcion == 'disponible') {
        disponible++;
      } else {
        noDisponible++;
      }

      if (row.ingresoEnPeriodo) {
        altasPeriodo++;
      }
    }

    final meaningfulDiseaseCases = healthRows
        .where(
          (row) =>
              row.historialId != 'N/A' &&
              ReportService.isMeaningfulDiseaseValue(row.enfermedades),
        )
        .length;

    final vacunasAplicadasPeriodo = vaccineRows
        .where(
          (v) =>
              v.vacunaId != 'N/A' &&
              v.fechaAplicacionValida &&
              v.aplicacionEnPeriodo,
        )
        .length;
    final vacunasVencidas = vaccineRows
        .where((v) => v.vacunaId != 'N/A' && v.estadoVacuna == 'Vencida')
        .length;
    final vacunasProximas = vaccineRows
        .where(
          (v) => v.vacunaId != 'N/A' && v.estadoVacuna == 'Próxima (<=30 días)',
        )
        .length;

    final totalAnimales = animalRows.length;
    final porcentajeEnfermedades = totalAnimales == 0
        ? 0.0
        : (meaningfulDiseaseCases / totalAnimales) * 100;

    return ReportStats(
      totalAnimales: totalAnimales,
      altasPeriodo: altasPeriodo,
      especiePerro: perros,
      especieGato: gatos,
      especieOtros: otros,
      adopcionDisponible: disponible,
      adopcionNoDisponible: noDisponible,
      casosEnfermedades: meaningfulDiseaseCases,
      porcentajeEnfermedades: porcentajeEnfermedades,
      vacunasAplicadasPeriodo: vacunasAplicadasPeriodo,
      vacunasVencidas: vacunasVencidas,
      vacunasProximas: vacunasProximas,
    );
  }

  Future<Uint8List> buildExcel(ReportBuildResult data) async {
    final excel = Excel.createExcel();
    final String? defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'Resumen');
    }

    _fillSummarySheet(excel, data);
    _fillAnimalsSheet(excel, data);
    _fillHealthSheet(excel, data);
    _fillVaccinesSheet(excel, data);

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('No fue posible generar el archivo Excel.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<void> saveExcel(Uint8List bytes, String fileName) async {
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  String buildFileName(String refugioId, DateTime now) {
    final stamp = DateFormat('yyyyMMdd_HHmm').format(now);
    return 'reporte_refugio_${refugioId}_$stamp';
  }

  static String classifyVaccineStatus({
    required DateTime? proximaFecha,
    required DateTime now,
  }) {
    if (proximaFecha == null) return 'Sin fecha';
    final days = proximaFecha.difference(now).inDays;
    if (days < 0) return 'Vencida';
    if (days <= 30) return 'Próxima (<=30 días)';
    return 'Al día';
  }

  static bool isMeaningfulDiseaseValue(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.isEmpty) return false;
    const excluded = <String>[
      'ninguna',
      'ninguno',
      'sin datos',
      'sin enfermedad',
      'sin enfermedades',
      'vacio',
      'vacío',
      'n/a',
      'na',
      'no aplica',
      'no tiene',
      'sano',
      'saludable',
      '-',
    ];
    return !excluded.contains(value);
  }

  _DateInfo _dateInfo(String raw, DateTimeRange range) {
    final parsed = _tryParseDate(raw);
    if (parsed == null) {
      return const _DateInfo(parsed: null, isValid: false, inRange: false);
    }
    final inRange = !parsed.isBefore(range.start) && !parsed.isAfter(range.end);
    return _DateInfo(parsed: parsed, isValid: true, inRange: inRange);
  }

  DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _fillSummarySheet(Excel excel, ReportBuildResult data) {
    final sheet = excel['Resumen'];
    final f = DateFormat('dd/MM/yyyy');
    final dtf = DateFormat('dd/MM/yyyy HH:mm');
    final stats = data.stats;

    final rows = <List<String>>[
      ['Reporte', 'Animales + Salud + Vacunas'],
      ['Refugio', data.refugioId],
      ['Generado', dtf.format(data.generatedAt)],
      ['Rango', '${f.format(data.range.start)} - ${f.format(data.range.end)}'],
      ['', ''],
      ['KPI', 'Valor'],
      ['Total animales', '${stats.totalAnimales}'],
      ['Altas en período', '${stats.altasPeriodo}'],
      ['Perros', '${stats.especiePerro}'],
      ['Gatos', '${stats.especieGato}'],
      ['Otros', '${stats.especieOtros}'],
      ['Disponibles adopción', '${stats.adopcionDisponible}'],
      ['No disponibles adopción', '${stats.adopcionNoDisponible}'],
      ['Casos con enfermedades', '${stats.casosEnfermedades}'],
      [
        'Porcentaje con enfermedades',
        '${stats.porcentajeEnfermedades.toStringAsFixed(2)}%',
      ],
      ['Vacunas aplicadas en período', '${stats.vacunasAplicadasPeriodo}'],
      ['Vacunas vencidas', '${stats.vacunasVencidas}'],
      ['Vacunas próximas (<=30 días)', '${stats.vacunasProximas}'],
    ];

    for (final row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e)).toList());
    }
  }

  void _fillAnimalsSheet(Excel excel, ReportBuildResult data) {
    final sheet = excel['Animales'];
    final headers = [
      'nombre',
      'especie',
      'raza',
      'sexo',
      'estado_adopcion',
      'estado_salud',
      'fecha_ingreso',
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final row in data.dataset.animales) {
      sheet.appendRow([
        TextCellValue(row.nombre),
        TextCellValue(row.especie),
        TextCellValue(row.raza),
        TextCellValue(row.sexo),
        TextCellValue(row.estadoAdopcion),
        TextCellValue(row.estadoSalud),
        TextCellValue(_formatDate(row.fechaIngresoParsed)),
      ]);
    }
  }

  void _fillHealthSheet(Excel excel, ReportBuildResult data) {
    final sheet = excel['Salud'];
    final headers = [
      'animal_nombre',
      'especie',
      'castrado',
      'peso',
      'enfermedades',
      'tratamiento',
      'fecha_revision',
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final row in data.dataset.salud) {
      sheet.appendRow([
        TextCellValue(row.animalNombre),
        TextCellValue(row.especie),
        TextCellValue(row.castrado),
        TextCellValue(row.peso),
        TextCellValue(row.enfermedades),
        TextCellValue(row.tratamiento),
        TextCellValue(_formatDate(row.fechaRevisionParsed)),
      ]);
    }
  }

  void _fillVaccinesSheet(Excel excel, ReportBuildResult data) {
    final sheet = excel['Vacunas'];
    final headers = [
      'animal_nombre',
      'especie',
      'vacuna_nombre',
      'fecha_aplicacion',
      'proxima_fecha',
      'estado_vacuna',
      'veterinario',
      'lote',
      'observaciones',
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final row in data.dataset.vacunas) {
      sheet.appendRow([
        TextCellValue(row.animalNombre),
        TextCellValue(row.especie),
        TextCellValue(row.vacunaNombre),
        TextCellValue(_formatDate(row.fechaAplicacionParsed)),
        TextCellValue(_formatDate(row.proximaFechaParsed)),
        TextCellValue(row.estadoVacuna),
        TextCellValue(row.veterinario),
        TextCellValue(row.lote),
        TextCellValue(row.observaciones),
      ]);
    }
  }

  Future<_AnimalBundle> _buildBundle(String refugioId, Animal animal) async {
    final futures = <Future<dynamic>>[
      _getHistorialSafe(animal.historialMedicoId),
      _vacunaService.getVacunas(refugioId, animal.id),
    ];
    final results = await Future.wait(futures);
    return _AnimalBundle(
      animal: animal,
      historial: results[0] as HistorialMedico?,
      vacunas: results[1] as List<Vacuna>,
    );
  }

  Future<HistorialMedico?> _getHistorialSafe(String historialId) async {
    if (historialId.trim().isEmpty) return null;
    try {
      return await _historialService.getHistorialMedico(historialId);
    } catch (_) {
      return null;
    }
  }
}

class _AnimalBundle {
  final Animal animal;
  final HistorialMedico? historial;
  final List<Vacuna> vacunas;

  const _AnimalBundle({
    required this.animal,
    required this.historial,
    required this.vacunas,
  });
}

class _DateInfo {
  final DateTime? parsed;
  final bool isValid;
  final bool inRange;

  const _DateInfo({
    required this.parsed,
    required this.isValid,
    required this.inRange,
  });
}
