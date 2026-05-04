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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/shimmer_gradient.dart';
import '../../../../core/widgets/ai_loading_animation.dart';
import '../../../../core/widgets/ai_error_animation.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Priority _selectedFilter = Priority.HIGH;
  int _filterIndex = 0;

  static const _priorities = [Priority.HIGH, Priority.MEDIUM, Priority.LOW];

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
    final newIndex = _priorities.indexOf(value);
    setState(() {
      _filterIndex = newIndex;
      _selectedFilter = value;
    });
    context.read<QueryBloc>().add(QueryFilterByPriority(priority: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AiSceneBackground(
        child: SafeArea(
          child: RepaintBoundary(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AiGhostIconButton(
                        icon: Icons.logout_rounded,
                        onTap: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                      Expanded(
                        child: Text(
                          'AI-Based Priority Resolver',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AiGhostIconButton(
                        icon: Icons.admin_panel_settings_rounded,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin-override'),
                      ),
                    ],
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
                      return _SwipePageView(
                        pageIndex: _filterIndex,
                        child: _AdminBody(
                          key: ValueKey<String>(
                            '${state.filterPriority?.name ?? 'none'}-${state.status.name}',
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

class _SwipePageView extends StatefulWidget {
  final int pageIndex;
  final Widget child;
  const _SwipePageView({required this.pageIndex, required this.child});

  @override
  State<_SwipePageView> createState() => _SwipePageViewState();
}

class _SwipePageViewState extends State<_SwipePageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position;

  Widget? _currentChild;
  Widget? _previousChild;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _position = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _SwipePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _isForward = widget.pageIndex > oldWidget.pageIndex;
      _previousChild = _currentChild;
      _currentChild = widget.child;
      _controller.forward(from: 0);
    } else if (oldWidget.child.key != widget.child.key) {
      _currentChild = widget.child;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _position.value;
        final inOffset = _isForward ? (1.0 - t) : -(1.0 - t);
        final outOffset = _isForward ? -t : t;

        return Stack(
          children: [
            if (_previousChild != null && t < 1.0)
              FractionalTranslation(
                translation: Offset(outOffset, 0),
                child: Opacity(
                  opacity: (1.0 - t).clamp(0.0, 1.0),
                  child: _previousChild!,
                ),
              ),
            FractionalTranslation(
              translation: Offset(t < 1.0 ? inOffset : 0, 0),
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: _currentChild!),
            ),
          ],
        );
      },
    );
  }
}

class _AdminBody extends StatelessWidget {
  final QueryState state;

  const _AdminBody({super.key, required this.state});

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
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: const _AdminLoadingCard(),
        );
      },
    );
  }
}

class _AdminLoadedState extends StatelessWidget {
  final List<QueryModel> queries;

  const _AdminLoadedState({required this.queries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        final bool isEven = index % 2 == 0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == queries.length - 1 ? 0 : 18,
          ),
          child: _AdminQueryCard(query: queries[index]),
        )
            .animate()
            .fadeIn(
          duration: 600.ms,
          curve: Curves.easeOut,
        )
            .slideX(
          begin: isEven ? 1.0 : -1.0,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutCubic,
          delay: (index * 100).ms,
        );
      },
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final String message;
  final List<QueryModel> queries;

  const _AdminErrorState({required this.message, required this.queries});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _AdminErrorCard(message: message)
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shake(
        hz: 4,
        duration: 1200.ms,
        curve: Curves.easeInOut,
        rotation: 0.02,
      )
          .fadeIn(duration: 500.ms),
    );
  }
}

class _AdminLoadingCard extends StatelessWidget {
  const _AdminLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase.withValues(alpha: 0.3),
      highlightColor: AppColors.shimmerHighlight.withValues(alpha: 0.1),
      period: const Duration(milliseconds: 1500),
      child: _AdminCardFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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

  const _AdminErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _AdminCardFrame(
      accent: AppColors.error,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'ERROR',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminQueryCard extends StatelessWidget {
  final QueryModel query;

  const _AdminQueryCard({required this.query});

  @override
  Widget build(BuildContext context) {
    return _AdminCardFrame(
      child: IntrinsicHeight( // આ વિજેટ કન્ટેન્ટ મુજબ હાઈટ એડજસ્ટ કરશે
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              query.title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              query.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.34,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: AppColors.glassBorder.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 12),
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

  const _AdminCardFrame({required this.child, this.accent});

  @override
  Widget build(BuildContext context) {
    final borderColor = accent ?? AppColors.primaryLight;

    return Container(
      // અહીં ફિક્સ હાઈટ (162) દૂર કરી છે જેથી ડાયનામિક રહે
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6152D49), Color(0xE6081629)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}