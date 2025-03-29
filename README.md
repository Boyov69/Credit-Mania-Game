# Credit-Mania Game Implementation Guide

This document provides a comprehensive guide to the Credit-Mania game implementation, including setup instructions, architecture overview, and deployment guidelines.

## Project Overview

Credit-Mania is a digital implementation of a board game focused on financial management, credit scores, and strategic asset acquisition. The game has been implemented as a cross-platform application for Android, iOS, and web using Flutter.

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / Xcode (for mobile deployment)
- Firebase account (for multiplayer functionality)

### Installation

1. Clone the repository:
```
git clone https://github.com/your-repository/credit-mania.git
cd credit-mania
```

2. Install dependencies:
```
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android, iOS, and Web apps to your Firebase project
   - Download and place the configuration files:
     - `google-services.json` in `android/app/`
     - `GoogleService-Info.plist` in `ios/Runner/`
     - Configure web app in `web/index.html`

4. Run the application:
```
flutter run
```

## Architecture Overview

The application follows a clean architecture approach with BLoC pattern for state management:

### Core Layers

1. **Models**: Data structures representing game entities
   - `Player`: Player information and stats
   - `Card`: Base class for all cards
   - `AssetCard`, `EventCard`, `LifeCard`, `AvatarCard`: Specific card types
   - `GameSession`: Multiplayer game session data

2. **Repositories**: Data access layer
   - `GameRepository`: Handles game data persistence and multiplayer synchronization

3. **Services**: Business logic
   - `GameLogic`: Core game mechanics and rules
   - `AudioManager`: Sound effects and music management

4. **BLoCs**: State management
   - `GameBloc`: Manages game state and events
   - `AppBloc`: Manages application-level state

5. **UI Components**: User interface
   - Screens: Main UI pages
   - Widgets: Reusable UI components
   - Animations: Enhanced visual effects

### Key Features

1. **Game Mechanics**
   - Turn-based gameplay
   - Card management
   - Resource tracking (Credit Points, Money, Income, Debt)
   - Dice rolling for income generation
   - Asset purchasing and management

2. **Multiplayer**
   - Create and join game sessions
   - Real-time game state synchronization
   - Player lobbies

3. **Audio**
   - Background music
   - Sound effects for game actions
   - Audio settings management

4. **Animations**
   - Card animations (flip, deal)
   - Dice rolling animations
   - Player dashboard animations
   - Game board animations

## Deployment Guidelines

### Android

1. Update `android/app/build.gradle` with your application details
2. Create a keystore for signing:
```
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```
3. Configure signing in `android/app/build.gradle`
4. Build the APK:
```
flutter build apk --release
```

### iOS

1. Update `ios/Runner/Info.plist` with your application details
2. Configure signing in Xcode
3. Build the IPA:
```
flutter build ios --release
```

### Web

1. Build the web application:
```
flutter build web --release
```
2. Deploy to hosting service (Firebase Hosting, GitHub Pages, etc.)

## Testing

The application includes comprehensive tests:

1. **Unit Tests**: Test individual components
   - `game_logic_test.dart`: Tests game mechanics
   - `game_bloc_test.dart`: Tests state management

2. **Widget Tests**: Test UI components
   - `animated_card_display_test.dart`: Tests card display widget

3. **Integration Tests**: Test feature workflows
   - Run with: `flutter test integration_test`

## Customization

### Adding New Cards

1. Create new card instances in `lib/services/game_logic.dart`
2. Add card images to `assets/images/`
3. Update card decks in the `_initializeCardDecks` method

### Modifying Game Rules

Game rules are implemented in the `GameLogic` class. Key methods to modify:

- `_startPhase`: Controls phase progression
- `_checkGameEnd`: Determines when the game ends
- `buyAssetCard`: Handles asset purchasing logic

## Troubleshooting

### Common Issues

1. **Firebase Connection Issues**
   - Check Firebase configuration files
   - Verify internet connectivity
   - Check Firebase console for service status

2. **Audio Not Playing**
   - Ensure audio files are correctly placed in assets
   - Check audio permissions on device
   - Verify audio is enabled in settings

3. **Performance Issues**
   - Reduce animation complexity
   - Optimize asset sizes
   - Check for memory leaks using Flutter DevTools

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- Game concept and assets: Credit-Mania board game
- Implementation: Your Company Name
