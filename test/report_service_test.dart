import 'package:admin_patitas/models/report_models.dart';
import 'package:admin_patitas/services/report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportFilter', () {
    test('resolves current month range correctly', () {
      final filter = ReportFilter.currentMonth();
      final range = filter.resolveRange(now: DateTime(2026, 5, 18, 10, 0, 0));

      expect(range.start, DateTime(2026, 5, 1));
      expect(range.end, DateTime(2026, 5, 31, 23, 59, 59, 999));
    });

    test('throws if custom range is invalid', () {
      final filter = ReportFilter(
        mode: ReportFilterMode.customRange,
        from: DateTime(2026, 5, 20),
        to: DateTime(2026, 5, 1),
      );

      expect(() => filter.resolveRange(), throwsArgumentError);
    });
  });

  group('ReportService helpers', () {
    test('detects meaningful diseases correctly', () {
      expect(ReportService.isMeaningfulDiseaseValue('ninguna'), isFalse);
      expect(ReportService.isMeaningfulDiseaseValue('  n/a '), isFalse);
      expect(ReportService.isMeaningfulDiseaseValue('otitis'), isTrue);
    });

    test('classifies vaccine status correctly', () {
      final now = DateTime(2026, 5, 20);
      expect(
        ReportService.classifyVaccineStatus(proximaFecha: null, now: now),
        'Sin fecha',
      );
      expect(
        ReportService.classifyVaccineStatus(
          proximaFecha: DateTime(2026, 5, 10),
          now: now,
        ),
        'Vencida',
      );
      expect(
        ReportService.classifyVaccineStatus(
          proximaFecha: DateTime(2026, 6, 5),
          now: now,
        ),
        'Próxima (<=30 días)',
      );
      expect(
        ReportService.classifyVaccineStatus(
          proximaFecha: DateTime(2026, 8, 1),
          now: now,
        ),
        'Al día',
      );
    });
  });

  group('ReportService KPI calculation', () {
    test('calculates stats from datasets', () {
      final animalRows = <ReportAnimalRow>[
        ReportAnimalRow(
          animalId: 'a1',
          nombre: 'Firulais',
          especie: 'Perro',
          raza: 'Criollo',
          sexo: 'Macho',
          estadoAdopcion: 'Disponible',
          estadoSalud: 'Estable',
          historialMedicoId: 'h1',
          fechaIngresoRaw: '2026-05-05',
          fechaIngresoParsed: DateTime(2026, 5, 5),
          fechaIngresoValida: true,
          ingresoEnPeriodo: true,
        ),
        ReportAnimalRow(
          animalId: 'a2',
          nombre: 'Mishi',
          especie: 'Gato',
          raza: 'Siames',
          sexo: 'Hembra',
          estadoAdopcion: 'No Disponible',
          estadoSalud: 'Observación',
          historialMedicoId: 'h2',
          fechaIngresoRaw: '2026-04-01',
          fechaIngresoParsed: DateTime(2026, 4, 1),
          fechaIngresoValida: true,
          ingresoEnPeriodo: false,
        ),
      ];

      final healthRows = <ReportHealthRow>[
        ReportHealthRow(
          animalId: 'a1',
          animalNombre: 'Firulais',
          especie: 'Perro',
          historialId: 'h1',
          castrado: 'Sí',
          peso: '12',
          enfermedades: 'Otitis',
          tratamiento: 'Antibiótico',
          fechaRevisionRaw: '2026-05-08',
          fechaRevisionParsed: DateTime(2026, 5, 8),
          fechaRevisionValida: true,
          revisionEnPeriodo: true,
        ),
        ReportHealthRow(
          animalId: 'a2',
          animalNombre: 'Mishi',
          especie: 'Gato',
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
      ];

      final vaccineRows = <ReportVaccineRow>[
        ReportVaccineRow(
          animalId: 'a1',
          animalNombre: 'Firulais',
          especie: 'Perro',
          vacunaId: 'v1',
          vacunaNombre: 'Rabia',
          fechaAplicacionRaw: '2026-05-01',
          fechaAplicacionParsed: DateTime(2026, 5, 1),
          fechaAplicacionValida: true,
          aplicacionEnPeriodo: true,
          proximaFechaRaw: '2026-05-18',
          proximaFechaParsed: DateTime(2026, 5, 18),
          proximaFechaValida: true,
          estadoVacuna: 'Vencida',
          veterinario: 'Dr. A',
          lote: 'L1',
          observaciones: '',
        ),
        ReportVaccineRow(
          animalId: 'a2',
          animalNombre: 'Mishi',
          especie: 'Gato',
          vacunaId: 'v2',
          vacunaNombre: 'Triple Felina',
          fechaAplicacionRaw: '2026-05-10',
          fechaAplicacionParsed: DateTime(2026, 5, 10),
          fechaAplicacionValida: true,
          aplicacionEnPeriodo: true,
          proximaFechaRaw: '2026-05-25',
          proximaFechaParsed: DateTime(2026, 5, 25),
          proximaFechaValida: true,
          estadoVacuna: 'Próxima (<=30 días)',
          veterinario: 'Dr. B',
          lote: 'L2',
          observaciones: '',
        ),
      ];

      final stats = ReportService.calculateStats(
        animalRows: animalRows,
        healthRows: healthRows,
        vaccineRows: vaccineRows,
        now: DateTime(2026, 5, 20),
      );

      expect(stats.totalAnimales, 2);
      expect(stats.altasPeriodo, 1);
      expect(stats.especiePerro, 1);
      expect(stats.especieGato, 1);
      expect(stats.especieOtros, 0);
      expect(stats.adopcionDisponible, 1);
      expect(stats.adopcionNoDisponible, 1);
      expect(stats.casosEnfermedades, 1);
      expect(stats.vacunasAplicadasPeriodo, 2);
      expect(stats.vacunasVencidas, 1);
      expect(stats.vacunasProximas, 1);
    });
  });
}
