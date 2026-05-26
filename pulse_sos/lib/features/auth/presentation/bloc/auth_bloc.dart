import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthPhoneSubmitted extends AuthEvent {
  final String phoneNumber;
  AuthPhoneSubmitted(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOtpSubmitted extends AuthEvent {
  final String verificationId;
  final String otp;
  AuthOtpSubmitted(this.verificationId, this.otp);
  @override
  List<Object?> get props => [verificationId, otp];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthEmailSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthEmailRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  AuthEmailRegisterRequested(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final UserEntity user;
  AuthProfileUpdateRequested(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthSignOutRequested extends AuthEvent {}

// ─── States ──────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthOtpSent(this.verificationId, this.phoneNumber);
  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthNeedsProfile extends AuthState {
  final UserEntity user;
  AuthNeedsProfile(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthEmailRegisterRequested>(_onEmailRegister);
    on<AuthProfileUpdateRequested>(_onProfileUpdate);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (!isAuth) {
        emit(AuthUnauthenticated());
        return;
      }
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(AuthUnauthenticated());
      } else if (user.displayName.isEmpty) {
        emit(AuthNeedsProfile(user));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPhoneSubmitted(AuthPhoneSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final verificationId = await _authRepository.signInWithPhone(event.phoneNumber);
      emit(AuthOtpSent(verificationId, event.phoneNumber));
    } catch (e) {
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onOtpSubmitted(AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyOtp(event.verificationId, event.otp);
      if (user.displayName.isEmpty) {
        emit(AuthNeedsProfile(user));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Invalid OTP. Please try again.'));
    }
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user.displayName.isEmpty) {
        emit(AuthNeedsProfile(user));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Google sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onEmailSignIn(AuthEmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Login failed. Check your credentials.'));
    }
  }

  Future<void> _onEmailRegister(AuthEmailRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerWithEmail(event.email, event.password, event.name);
      emit(AuthNeedsProfile(user));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onProfileUpdate(AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final updated = await _authRepository.updateProfile(event.user);
      emit(AuthAuthenticated(updated));
    } catch (e) {
      emit(AuthError('Profile update failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
