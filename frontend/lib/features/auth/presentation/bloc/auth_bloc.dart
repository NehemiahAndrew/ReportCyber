import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/setup_2fa_usecase.dart';
import '../../domain/usecases/verify_2fa_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final Verify2FAUseCase verify2FAUseCase;
  final Setup2FAUseCase setup2FAUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.googleSignInUseCase,
    required this.verify2FAUseCase,
    required this.setup2FAUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
  }) : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GitHubSignInRequested>(_onGitHubSignInRequested);
    on<Verify2FARequested>(_onVerify2FARequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<Setup2FARequested>(_onSetup2FARequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        totpCode: event.totpCode,
      );

      if (result.requires2FA && result.tempUserId != null) {
        emit(state.requires2FA(tempUserId: result.tempUserId!));
      } else if (result.success && result.user != null) {
        emit(
          state.authenticated(
            user: result.user!,
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          ),
        );
      } else {
        emit(state.error(message: result.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      final result = await registerUseCase(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      if (result.success) {
        emit(state.registrationSuccess(message: result.message));
      } else {
        emit(state.error(message: result.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      final result = await googleSignInUseCase();

      if (result.success && result.user != null) {
        emit(
          state.authenticated(
            user: result.user!,
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          ),
        );
      } else {
        emit(state.error(message: result.message ?? 'Google sign in failed'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onGitHubSignInRequested(
    GitHubSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    emit(state.error(message: 'GitHub sign in not implemented for mobile'));
  }

  Future<void> _onVerify2FARequested(
    Verify2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      final result = await verify2FAUseCase(
        userId: event.userId,
        totpCode: event.totpCode,
      );

      if (result.success && result.user != null) {
        emit(
          state.authenticated(
            user: result.user!,
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          ),
        );
      } else {
        emit(state.error(message: result.message ?? '2FA verification failed'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      await logoutUseCase();
      emit(state.unauthenticated());
    } catch (e) {
      // Even if logout fails on server, clear local state
      emit(state.unauthenticated());
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await getCurrentUserUseCase();

      if (user != null) {
        emit(state.authenticated(user: user));
      } else {
        emit(state.unauthenticated());
      }
    } catch (e) {
      emit(state.unauthenticated());
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      await forgotPasswordUseCase(email: event.email);
      emit(state.passwordResetSent());
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onSetup2FARequested(
    Setup2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      final result = await setup2FAUseCase();

      if (result.success && result.qrCodeUrl != null) {
        emit(
          state.with2FASetup(
            setup: TwoFactorSetupData(
              secret: result.secret,
              qrCodeUrl: result.qrCodeUrl!,
              backupCodes: result.backupCodes,
            ),
          ),
        );
      } else {
        emit(state.error(message: result.message ?? '2FA setup failed'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onAuthErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
