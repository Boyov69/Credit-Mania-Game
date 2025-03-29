import 'package:flutter/material.dart';
import 'package:credit_mania/blocs/app_bloc.dart';
import 'package:credit_mania/screens/splash_screen.dart';
import 'package:credit_mania/constants/theme.dart';
import 'package:credit_mania/repositories/game_repository.dart';
import 'package:credit_mania/repositories/auth_repository.dart';
import 'package:credit_mania/repositories/storage_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  // registerAdapters();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for offline mode
  }
  
  // Initialize repositories
  final authRepository = AuthRepository();
  final gameRepository = GameRepository();
  final storageRepository = StorageRepository();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<GameRepository>(
          create: (context) => gameRepository,
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => storageRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => AppBloc(
          authRepository: authRepository,
          gameRepository: gameRepository,
        ),
        child: const CreditManiaApp(),
      ),
    ),
  );
}

class CreditManiaApp extends StatelessWidget {
  const CreditManiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Mania',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
