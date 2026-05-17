import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/features/control/data/datasources/control_remote_datasource.dart';
import 'package:urban_smart_farming/features/control/domain/repositories/control_repository.dart';

class ControlRepositoryImpl implements ControlRepository {
  final ControlRemoteDataSource remoteDataSource;

  ControlRepositoryImpl({required this.remoteDataSource});

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<String?> getDeviceId(String cropId) async {
    final rows = await _supabase
        .from('Device')
        .select('id')
        .eq('crop_id', cropId)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows[0]['id'] as String;
  }

  @override
  Future<({bool isPumpOn, bool isLightOn})> getActuatorStates(
    String deviceId,
  ) async {
    final results = await Future.wait([
      _supabase
          .from('ActuationEvent')
          .select('action')
          .eq('device_id', deviceId)
          .eq('actuator_type', 'pump')
          .order('started_at', ascending: false)
          .limit(1),
      _supabase
          .from('ActuationEvent')
          .select('action')
          .eq('device_id', deviceId)
          .eq('actuator_type', 'light')
          .order('started_at', ascending: false)
          .limit(1),
    ]);

    final isPumpOn = results[0].isNotEmpty && results[0][0]['action'] == 'on';
    final isLightOn = results[1].isNotEmpty && results[1][0]['action'] == 'on';

    return (isPumpOn: isPumpOn, isLightOn: isLightOn);
  }

  @override
  Future<void> actuate(
    String deviceId,
    String actuatorType,
    String action,
  ) async {
    await remoteDataSource.actuate(deviceId, actuatorType, action);
  }
}
