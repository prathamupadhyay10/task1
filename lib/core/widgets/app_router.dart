import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_scene.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String userDashboard = '/user-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String addQuery = '/add-query';
  static const String editQuery = '/edit-query';
  static const String queryDetail = '/query-detail';
  static const String adminOverride = '/admin-override';
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAuthCheck();
  }

  void _startAuthCheck() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(
            context,
            state.isAdmin ? AppRouter.adminDashboard : AppRouter.userDashboard,
          );
        } else if (state.status == AuthStatus.unauthenticated ||
            state.status == AuthStatus.error) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: AiSceneBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AI-Based Priority Resolver',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 18),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.9),
                      AppColors.primary.withOpacity(0.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.30),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ).animate().scale(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
