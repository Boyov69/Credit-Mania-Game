import 'package:flutter/material.dart';
import 'package:credit_mania/screens/home_screen.dart';
import 'package:credit_mania/services/game_service.dart';
import 'package:credit_mania/utils/asset_images.dart';
import 'package:provider/provider.dart';

// This is a modified main.dart file that includes a splash screen
// to demonstrate the loading screen functionality

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CreditManiaApp());
}

class CreditManiaApp extends StatelessWidget {
  const CreditManiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameService()),
      ],
      child: MaterialApp(
        title: 'Credit Mania',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'CreditMania',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _loadingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }
  
  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_loadingProgress < 1.0) {
        setState(() {
          _loadingProgress += 0.1;
        });
        _simulateLoading();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetImages.loadingScreen),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo is already part of the loading screen image
              
              const Spacer(),
              
              // Loading progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.amber.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
                  minHeight: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Loading text
              Text(
                'Loading... ${(_loadingProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.brown,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
