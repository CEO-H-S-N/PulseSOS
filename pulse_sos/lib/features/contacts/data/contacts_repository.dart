import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/incident_repository.dart';

/// Entity representing a trusted emergency contact
class TrustedContact {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final bool notifyViaSms;
  final bool notifyViaWhatsapp;

  TrustedContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email = '',
    this.notifyViaSms = true,
    this.notifyViaWhatsapp = false,
  });

  factory TrustedContact.fromMap(String id, Map<String, dynamic> map) {
    return TrustedContact(
      id: id,
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? 'Other',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      notifyViaSms: map['notifyViaSms'] ?? true,
      notifyViaWhatsapp: map['notifyViaWhatsapp'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'email': email,
    'notifyViaSms': notifyViaSms,
    'notifyViaWhatsapp': notifyViaWhatsapp,
  };
}

/// Repository interface for trusted contacts
abstract class ContactsRepository {
  Future<Either<Failure, List<TrustedContact>>> getContacts(String userId);
  Future<Either<Failure, TrustedContact>> addContact(String userId, TrustedContact contact);
  Future<Either<Failure, bool>> deleteContact(String userId, String contactId);
}

/// Firestore implementation of contacts repository
class ContactsRepositoryImpl implements ContactsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<TrustedContact>>> getContacts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trusted_contacts')
          .get();

      final contacts = snapshot.docs.map((doc) {
        return TrustedContact.fromMap(doc.id, doc.data());
      }).toList();

      return Either.right(contacts);
    } catch (e) {
      return Either.left(ServerFailure(message: 'Failed to load contacts: $e'));
    }
  }

  @override
  Future<Either<Failure, TrustedContact>> addContact(String userId, TrustedContact contact) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trusted_contacts')
          .add(contact.toMap());

      final saved = TrustedContact(
        id: docRef.id,
        name: contact.name,
        relationship: contact.relationship,
        phone: contact.phone,
        email: contact.email,
        notifyViaSms: contact.notifyViaSms,
        notifyViaWhatsapp: contact.notifyViaWhatsapp,
      );

      return Either.right(saved);
    } catch (e) {
      return Either.left(ServerFailure(message: 'Failed to add contact: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trusted_contacts')
          .doc(contactId)
          .delete();
      return Either.right(true);
    } catch (e) {
      return Either.left(ServerFailure(message: 'Failed to delete contact: $e'));
    }
  }
}
