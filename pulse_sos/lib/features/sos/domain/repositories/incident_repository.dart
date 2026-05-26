import '../../../../core/errors/failures.dart';
import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  /// Reports and broadcasts a new active emergency incident
  Future<Either<Failure, IncidentEntity>> triggerSOS({
    required EmergencyType type,
    required bool isSilent,
    required double latitude,
    required double longitude,
    String? address,
  });

  /// Resolves an ongoing active emergency incident
  Future<Either<Failure, bool>> resolveSOS(String incidentId);

  /// Retrieves a list of active emergencies within the user's scan radius
  Future<Either<Failure, List<IncidentEntity>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  /// Fetches logs of completed SOS actions
  Future<Either<Failure, List<IncidentEntity>>> getIncidentHistory();

  /// Retrieves real-time AI orchestrator insights for an incident
  Future<Either<Failure, Map<String, dynamic>>> getAIInsights(String incidentId);
}

/// Simple functional Either implementation for decoupled clean architecture
class Either<L, R> {
  final L? left;
  final R? right;

  Either._(this.left, this.right);

  factory Either.left(L left) => Either._(left, null);
  factory Either.right(R right) => Either._(null, right);

  bool get isLeft => left != null;
  bool get isRight => right != null;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (isLeft) return onLeft(left!);
    return onRight(right!);
  }
}
