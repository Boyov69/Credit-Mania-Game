import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:credit_mania/repositories/auth_repository.dart';
import 'package:credit_mania/repositories/game_repository.dart';

// App-level bloc for managing global application state
class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository authRepository;
  final GameRepository gameRepository;

  AppBloc({
    required this.authRepository,
    required this.gameRepository,
  }) : super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppThemeChanged>(_onThemeChanged);
    on<AppLanguageChanged>(_onLanguageChanged);
  }

  void _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(AppLoading());
    try {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        emit(AppAuthenticated(user: currentUser));
      } else {
        emit(AppUnauthenticated());
      }
    } catch (e) {
      emit(AppError(message: e.toString()));
    }
  }

  void _onUserChanged(AppUserChanged event, Emitter<AppState> emit) {
    if (event.user != null) {
      emit(AppAuthenticated(user: event.user!));
    } else {
      emit(AppUnauthenticated());
    }
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) async {
    try {
      await authRepository.signOut();
      emit(AppUnauthenticated());
    } catch (e) {
      emit(AppError(message: e.toString()));
    }
  }

  void _onThemeChanged(AppThemeChanged event, Emitter<AppState> emit) {
    if (state is AppAuthenticated) {
      emit(AppAuthenticated(
        user: (state as AppAuthenticated).user,
        isDarkMode: event.isDarkMode,
      ));
    }
  }

  void _onLanguageChanged(AppLanguageChanged event, Emitter<AppState> emit) {
    if (state is AppAuthenticated) {
      emit(AppAuthenticated(
        user: (state as AppAuthenticated).user,
        isDarkMode: (state as AppAuthenticated).isDarkMode,
        language: event.language,
      ));
    }
  }
}

// Events
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {}

class AppUserChanged extends AppEvent {
  final dynamic user;

  const AppUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}

class AppLogoutRequested extends AppEvent {}

class AppThemeChanged extends AppEvent {
  final bool isDarkMode;

  const AppThemeChanged({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

class AppLanguageChanged extends AppEvent {
  final String language;

  const AppLanguageChanged({required this.language});

  @override
  List<Object> get props => [language];
}

// States
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppAuthenticated extends AppState {
  final dynamic user;
  final bool isDarkMode;
  final String language;

  const AppAuthenticated({
    required this.user,
    this.isDarkMode = false,
    this.language = 'en',
  });

  @override
  List<Object?> get props => [user, isDarkMode, language];

  AppAuthenticated copyWith({
    dynamic user,
    bool? isDarkMode,
    String? language,
  }) {
    return AppAuthenticated(
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }
}

class AppUnauthenticated extends AppState {}

class AppError extends AppState {
  final String message;

  const AppError({required this.message});

  @override
  List<Object> get props => [message];
}
