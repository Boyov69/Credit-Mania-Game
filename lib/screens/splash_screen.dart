import 'package:flutter/material.dart';
import 'package:credit_mania/constants/app_colors.dart';
import 'package:credit_mania/utils/asset_images.dart';
import 'package:credit_mania/blocs/auth/auth_bloc.dart';
import 'package:credit_mania/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _loadingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Start loading sequence
    _startLoadingSequence();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _startLoadingSequence() async {
    // Start animation
    _animationController.forward();
    
    // Simulate loading progress
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _loadingProgress = (i + 1) / 10;
        });
      }
    }
    
    // Delay for animation to complete
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
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
              
              // Logo animation
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Image.asset(
                  AssetImages.logo,
                  width: 300,
                  height: 200,
                ),
              ),
              
              const Spacer(),
              
              // Loading progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: _loadingProgress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
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
