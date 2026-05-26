import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Firebase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final Logger _logger = Logger();

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference get _usersRef => _firestore.collection('users');

  @override
  Future<String> signInWithPhone(String phoneNumber) async {
    String verificationId = '';
    final completer = Future<String>.value('');

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _logger.e('Phone verification failed: ${e.message}');
        throw e;
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );

    // Wait for codeSent callback
    await Future.delayed(const Duration(seconds: 2));
    return verificationId;
  }

  @override
  Future<UserEntity> verifyOtp(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return _getOrCreateUser(userCredential);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _getOrCreateUser(userCredential);
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getOrCreateUser(userCredential);
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(name);
    return _getOrCreateUser(userCredential, displayName: name);
  }

  Future<UserEntity> _getOrCreateUser(
    UserCredential userCredential, {
    String? displayName,
  }) async {
    final user = userCredential.user!;
    final doc = await _usersRef.doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    // Create new user document
    final newUser = UserModel(
      uid: user.uid,
      displayName: displayName ?? user.displayName ?? '',
      phone: user.phoneNumber ?? '',
      email: user.email,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _usersRef.doc(user.uid).set(newUser.toFirestore());
    return newUser;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _usersRef.doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _usersRef.doc(user.uid).update(model.toFirestore());
    return user;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  @override
  Future<void> bindDevice(String deviceToken) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _usersRef.doc(user.uid).update({
      'deviceTokens': FieldValue.arrayUnion([deviceToken]),
    });
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _usersRef.doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
