import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_scene.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/query_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../models/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/query_bloc.dart';
import '../bloc/query_event.dart';
import '../bloc/query_state.dart';
import '../../../../core/widgets/ai_loading_animation.dart';
import '../../../../core/widgets/ai_error_animation.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        context.read<QueryBloc>().add(
              QueryFetchUserRequested(userId: authState.user!.uid),
            );
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Sign Out',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Sign Out',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AiSceneBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    AiGhostIconButton(
                      icon: Icons.logout_rounded,
                      onTap: _showLogoutDialog,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'AI-Based Priority Resolver',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hello, ${_firstName(user)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AiGhostIconButton(
                      icon: Icons.add_rounded,
                      onTap: () => Navigator.pushNamed(context, '/add-query'),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 420),
                  ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocBuilder<QueryBloc, QueryState>(
                  builder: (context, state) {
                    if (state.status == QueryStatus.loading &&
                        state.queries.isEmpty) {
                      return const AiLoadingAnimation();
                    }

                    if (state.status == QueryStatus.error &&
                        state.queries.isEmpty) {
                      return AiErrorAnimation(
                        message: state.errorMessage ?? 'Failed to load queries',
                      );
                    }

                    if (state.queries.isEmpty) {
                      return EmptyState(
                        title: 'No Queries Yet',
                        subtitle: 'Create your first query to start AI prioritization',
                        icon: Icons.note_add_outlined,
                        action: PrimaryButton(
                          text: 'Add query',
                          width: 200,
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-query');
                          },
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (user != null) {
                          context.read<QueryBloc>().add(
                                QueryFetchUserRequested(userId: user.uid),
                              );
                        }
                      },
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                        itemCount: state.queries.length,
                        itemBuilder: (context, index) {
                          final query = state.queries[index];
                          return QueryCard(
                            query: query,
                            index: index,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/query-detail',
                                arguments: query,
                              );
                            },
                          ).animate().fadeIn(
                                delay: (index * 80).ms,
                                duration: 400.ms,
                              ).slideY(begin: 0.1, end: 0);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          text: 'Add query',
          onPressed: () => Navigator.pushNamed(context, '/add-query'),
        ).animate().fadeIn(
              delay: const Duration(milliseconds: 180),
              duration: const Duration(milliseconds: 420),
            ),
      ),
    );
  }

  String _firstName(AppUser? user) {
    if (user == null || user.name.trim().isEmpty) return 'User';
    return user.name.trim().split(' ').first;
  }
}
