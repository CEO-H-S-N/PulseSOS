import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final ApiClient apiClient;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  IncidentRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, IncidentEntity>> triggerSOS({
    required EmergencyType type,
    required bool isSilent,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final response = await apiClient.post(
        '/incidents',
        data: {
          'type': type.name,
          'isSilent': isSilent,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final incident = IncidentEntity(
          id: data['id'],
          victimId: data['victimId'],
          type: type,
          isSilent: isSilent,
          status: IncidentStatus.active,
          latitude: latitude,
          longitude: longitude,
          address: data['location']['address'],
          responderCount: 0,
          responders: [],
          createdAt: DateTime.parse(data['createdAt']),
        );
        return Either.right(incident);
      }
      return Either.left(ServerFailure(message: 'Invalid server response: ${response.statusCode}'));
    } catch (e) {
      // Local Firestore Fallback if backend API is unreachable
      try {
        final incidentId = firestore.collection('incidents').doc().id;
        final mockIncident = {
          'id': incidentId,
          'victimId': 'mock-offline-victim',
          'type': type.name,
          'isSilent': isSilent,
          'status': 'active',
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'address': address ?? 'Unknown Offline Location',
            'geohash': '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}'
          },
          'responderCount': 0,
          'responders': [],
          'createdAt': DateTime.now().toIso8601String(),
        };

        await firestore.collection('incidents').doc(incidentId).set(mockIncident);

        final entity = IncidentEntity(
          id: incidentId,
          victimId: 'mock-offline-victim',
          type: type,
          isSilent: isSilent,
          status: IncidentStatus.active,
          latitude: latitude,
          longitude: longitude,
          address: address ?? 'Unknown Offline Location',
          responderCount: 0,
          responders: [],
          createdAt: DateTime.now(),
        );

        return Either.right(entity);
      } catch (firestoreErr) {
        return Either.left(ServerFailure(message: 'SOS trigger failed on all channels: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> resolveSOS(String incidentId) async {
    try {
      final response = await apiClient.put('/incidents/$incidentId/resolve');
      if (response.statusCode == 200) {
        return Either.right(true);
      }
      return Either.left(ServerFailure(message: 'Resolution failed: ${response.statusCode}'));
    } catch (e) {
      try {
        await firestore.collection('incidents').doc(incidentId).update({'status': 'resolved'});
        return Either.right(true);
      } catch (err) {
        return Either.left(ServerFailure(message: 'Failed to resolve emergency: $err'));
      }
    }
  }

  @override
  Future<Either<Failure, List<IncidentEntity>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final response = await apiClient.get(
        '/incidents/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusInKm,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        final list = data.map((json) {
          return IncidentEntity(
            id: json['id'],
            victimId: json['victimId'],
            type: EmergencyType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => EmergencyType.other,
            ),
            isSilent: json['isSilent'] ?? false,
            status: IncidentStatus.active,
            latitude: json['location']['latitude'],
            longitude: json['location']['longitude'],
            address: json['location']['address'],
            responderCount: json['responderCount'] ?? 0,
            responders: [],
            createdAt: DateTime.parse(json['createdAt']),
          );
        }).toList();
        return Either.right(list);
      }
      return Either.left(ServerFailure(message: 'Scanning nearby active alerts failed'));
    } catch (e) {
      return Either.left(ServerFailure(message: 'Network error retrieving local mesh: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IncidentEntity>>> getIncidentHistory() async {
    try {
      final response = await apiClient.get('/incidents/history');
      if (response.statusCode == 200) {
        final List data = response.data;
        final list = data.map((json) {
          return IncidentEntity(
            id: json['id'],
            victimId: json['victimId'],
            type: EmergencyType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => EmergencyType.other,
            ),
            isSilent: json['isSilent'] ?? false,
            status: IncidentStatus.resolved,
            latitude: json['location']['latitude'],
            longitude: json['location']['longitude'],
            address: json['location']['address'],
            responderCount: json['responderCount'] ?? 0,
            responders: [],
            createdAt: DateTime.parse(json['createdAt']),
          );
        }).toList();
        return Either.right(list);
      }
      return Either.left(ServerFailure(message: 'Retrieving incident logs failed'));
    } catch (e) {
      return Either.left(ServerFailure(message: 'Server error retrieving history: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAIInsights(String incidentId) async {
    try {
      final response = await apiClient.get('/ai/insights/$incidentId');
      if (response.statusCode == 200) {
        return Either.right(response.data as Map<String, dynamic>);
      }
      return Either.left(ServerFailure(message: 'Failed to retrieve AI insights'));
    } catch (e) {
      return Either.left(ServerFailure(message: 'AI Service currently unavailable'));
    }
  }
}
