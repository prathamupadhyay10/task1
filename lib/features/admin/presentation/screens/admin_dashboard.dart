import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_scene.dart';
import '../../../../models/query_model.dart';
import '../../../query/presentation/bloc/query_bloc.dart';
import '../../../query/presentation/bloc/query_event.dart';
import '../../../query/presentation/bloc/query_state.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Priority _selectedFilter = Priority.HIGH;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QueryBloc>().add(
            QueryFilterByPriority(priority: _selectedFilter),
          );
      context.read<QueryBloc>().add(QueryFetchAllRequested());
    });
  }

  void _onFilterChanged(Priority value) {
    if (_selectedFilter == value) return;
    setState(() {
      _selectedFilter = value;
    });
    context.read<QueryBloc>().add(
          QueryFilterByPriority(priority: value),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AiSceneBackground(
        child: SafeArea(
          child: RepaintBoundary(
            child: Column(
              children: [
                const SizedBox(height: 62),
                Text(
                  'AI-Based Priority Resolver',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AiSegmentedControl<Priority>(
                    values: const [
                      Priority.HIGH,
                      Priority.MEDIUM,
                      Priority.LOW,
                    ],
                    selected: _selectedFilter,
                    labelBuilder: (value) =>
                        value.name[0] + value.name.substring(1).toLowerCase(),
                    onChanged: _onFilterChanged,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: BlocBuilder<QueryBloc, QueryState>(
                    buildWhen: (previous, current) =>
                        previous.status != current.status ||
                        previous.queries != current.queries ||
                        previous.errorMessage != current.errorMessage ||
                        previous.filterPriority != current.filterPriority,
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: _AdminBody(
                          key: ValueKey<String>(
                            '${state.status.name}-${state.queries.length}-${state.filterPriority?.name ?? 'none'}-${state.errorMessage ?? ''}',
                          ),
                          state: state,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminBody extends StatelessWidget {
  final QueryState state;

  const _AdminBody({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == QueryStatus.loading) {
      return const _AdminLoadingState();
    }

    if (state.status == QueryStatus.error) {
      return _AdminErrorState(
        message: state.errorMessage ?? 'Failed to load queries',
        queries: state.queries,
      );
    }

    if (state.queries.isEmpty) {
      return const SizedBox.expand();
    }

    return _AdminLoadedState(queries: state.queries);
  }
}

class _AdminLoadingState extends StatelessWidget {
  const _AdminLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 18),
          child: const _AdminLoadingCard(),
        );
      },
    );
  }
}

class _AdminLoadedState extends StatelessWidget {
  final List<QueryModel> queries;

  const _AdminLoadedState({
    required this.queries,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 260 + (index * 120)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 22),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: index == queries.length - 1 ? 0 : 18),
            child: _AdminQueryCard(query: queries[index]),
          ),
        );
      },
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final String message;
  final List<QueryModel> queries;

  const _AdminErrorState({
    required this.message,
    required this.queries,
  });

  @override
  Widget build(BuildContext context) {
    final visibleQueries = queries.take(2).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.96 + (value * 0.04),
                child: child,
              ),
            );
          },
          child: _AdminErrorCard(message: message),
        ),
        for (int i = 0; i < visibleQueries.length; i++) ...[
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (i * 110)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 18),
                  child: child,
                ),
              );
            },
            child: _AdminQueryCard(query: visibleQueries[i]),
          ),
        ],
      ],
    );
  }
}

class _AdminLoadingCard extends StatelessWidget {
  const _AdminLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase.withValues(alpha: 0.84),
      highlightColor: AppColors.shimmerHighlight.withValues(alpha: 0.95),
      period: const Duration(milliseconds: 1400),
      child: _AdminCardFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 130,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 84,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminErrorCard extends StatelessWidget {
  final String message;

  const _AdminErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminCardFrame(
      accent: AppColors.primaryLight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 122,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 92,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 54,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.30),
                          blurRadius: 24,
                          spreadRadius: -10,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Text(
                      'ERROR',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminQueryCard extends StatelessWidget {
  final QueryModel query;

  const _AdminQueryCard({
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            query.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            query.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.34,
            ),
          ),
          const Spacer(),
          Container(
            height: 1,
            color: AppColors.glassBorder.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                _buildDateLabel(query),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDateLabel(QueryModel query) {
    final created = query.createdAt;
    final updated = query.updatedAt;

    if (updated.isAfter(created.add(const Duration(days: 1)))) {
      return '${DateFormat('dd').format(created)}-${DateFormat('dd MMMM').format(updated)}';
    }

    return DateFormat('dd MMMM').format(created);
  }
}

class _AdminCardFrame extends StatelessWidget {
  final Widget child;
  final Color? accent;

  const _AdminCardFrame({
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = accent ?? AppColors.primaryLight;

    return Container(
      height: 162,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xE6152D49),
            const Color(0xE6081629),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.78),
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -34,
            right: -34,
            bottom: -54,
            child: IgnorePointer(
              child: Container(
                height: 124,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.9),
                    radius: 0.92,
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.30),
                      AppColors.primary.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
