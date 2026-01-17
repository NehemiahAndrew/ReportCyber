import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_in_usecase.dart';
import '../../features/auth/domain/usecases/verify_2fa_usecase.dart';
import '../../features/auth/domain/usecases/setup_2fa_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/report/data/datasources/report_remote_data_source.dart';
import '../../features/report/data/datasources/report_local_data_source.dart';
import '../../features/report/data/repositories/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/domain/usecases/create_report_usecase.dart';
import '../../features/report/domain/usecases/get_my_reports_usecase.dart';
import '../../features/report/domain/usecases/get_report_by_id_usecase.dart';
import '../../features/report/domain/usecases/get_reports_usecase.dart';
import '../../features/report/domain/usecases/submit_report_usecase.dart';
import '../../features/report/domain/usecases/upload_evidence_usecase.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  // Google Sign In - using the singleton instance (v7.x API)
  sl.registerLazySingleton(() => GoogleSignIn.instance);

  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  sl.registerLazySingleton(() => dio);

  //! Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl(), sl()));

  // Add auth interceptor to Dio
  dio.interceptors.add(sl<AuthInterceptor>());

  //! Features - Auth
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl(),
      googleSignIn: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => Verify2FAUseCase(sl()));
  sl.registerLazySingleton(() => Setup2FAUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      googleSignInUseCase: sl(),
      verify2FAUseCase: sl(),
      setup2FAUseCase: sl(),
      getCurrentUserUseCase: sl(),
      forgotPasswordUseCase: sl(),
    ),
  );

  //! Features - Report
  // Data sources
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<ReportLocalDataSource>(
    () => ReportLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetReportByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReportUseCase(sl()));
  sl.registerLazySingleton(() => UploadEvidenceUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ReportBloc(
      getReportsUseCase: sl(),
      getMyReportsUseCase: sl(),
      getReportByIdUseCase: sl(),
      createReportUseCase: sl(),
      submitReportUseCase: sl(),
      uploadEvidenceUseCase: sl(),
      reportRepository: sl(),
    ),
  );
}
