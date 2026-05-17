import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';
import 'package:urban_smart_farming/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:urban_smart_farming/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:urban_smart_farming/features/analytics/presentation/bloc/analytics_state.dart';

/// Pantalla de analíticas para un cultivo específico
class AnalyticsScreen extends StatelessWidget {
  final String cropId;

  const AnalyticsScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AnalyticsBloc>(param1: cropId)..add(const LoadAnalyticsData()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  // Rango actual del estado (para mantener SegmentedButton sincronizado)
  String _rangeFromState(AnalyticsState state) {
    if (state is AnalyticsLoaded) return state.range;
    if (state is AnalyticsEmpty) return state.range;
    if (state is AnalyticsError) return state.range;
    return 'day';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        final currentRange = _rangeFromState(state);

        return Column(
          children: [
            // Selector de rango
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Día')),
                  ButtonSegment(value: 'week', label: Text('Semana')),
                  ButtonSegment(value: 'month', label: Text('Mes')),
                ],
                selected: {currentRange},
                onSelectionChanged: (Set<String> selected) {
                  context
                      .read<AnalyticsBloc>()
                      .add(ChangeRange(selected.first));
                },
              ),
            ),

            // Contenido principal
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AnalyticsState state) {
    if (state is AnalyticsInitial || state is AnalyticsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnalyticsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context
                    .read<AnalyticsBloc>()
                    .add(LoadAnalyticsData(range: state.range)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AnalyticsEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Sin datos históricos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'No hay lecturas registradas para el período seleccionado.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AnalyticsLoaded) {
      return _ChartsListView(readings: state.readings, range: state.range);
    }

    return const SizedBox();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista de gráficos
// ─────────────────────────────────────────────────────────────────────────────

class _ChartsListView extends StatelessWidget {
  final List<SensorReadingHistoryEntity> readings;
  final String range;

  const _ChartsListView({required this.readings, required this.range});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChartCard(
          title: 'Temperatura',
          unit: '°C',
          color: Colors.orange,
          icon: Icons.thermostat,
          readings: readings,
          range: range,
          getValue: (r) => r.temperature,
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Humedad del suelo',
          unit: '%',
          color: Colors.blue,
          icon: Icons.water_drop,
          readings: readings,
          range: range,
          getValue: (r) => r.humidity,
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Luz',
          unit: 'Lux',
          color: Colors.amber,
          icon: Icons.wb_sunny,
          readings: readings,
          range: range,
          getValue: (r) => r.lightLevel,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta con gráfico de una métrica
// ─────────────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final Color color;
  final IconData icon;
  final List<SensorReadingHistoryEntity> readings;
  final String range;
  final double? Function(SensorReadingHistoryEntity) getValue;

  const _ChartCard({
    required this.title,
    required this.unit,
    required this.color,
    required this.icon,
    required this.readings,
    required this.range,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar puntos con valor disponible
    final indexedReadings = readings
        .asMap()
        .entries
        .where((e) => getValue(e.value) != null)
        .toList();

    final spots = indexedReadings
        .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)!))
        .toList();

    final hasData = spots.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$title ($unit)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfico o placeholder vacío
            SizedBox(
              height: 160,
              child: hasData
                  ? LineChart(_buildChartData(spots, indexedReadings))
                  : Center(
                      child: Text(
                        'Sin datos',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData(
    List<FlSpot> spots,
    List<MapEntry<int, SensorReadingHistoryEntity>> indexedReadings,
  ) {
    final interval = max(1, (readings.length / 5).round()).toDouble();

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= readings.length) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTimestamp(readings[idx].timestamp, range),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  String _formatTimestamp(DateTime t, String range) {
    if (range == 'day') return DateFormat('HH:mm').format(t);
    return DateFormat('dd/MM').format(t);
  }
}
