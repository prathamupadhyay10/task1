import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_scene.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/query_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/query_bloc.dart';
import '../bloc/query_event.dart';
import '../bloc/query_state.dart';

class AddEditQueryScreen extends StatefulWidget {
  final bool isEditing;
  final QueryModel? query;

  const AddEditQueryScreen({
    super.key,
    this.isEditing = false,
    this.query,
  });

  @override
  State<AddEditQueryScreen> createState() => _AddEditQueryScreenState();
}

class _AddEditQueryScreenState extends State<AddEditQueryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _jitterKey = GlobalKey<JitterFieldState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.isEditing ? widget.query?.title ?? '' : '',
    );
    _descriptionController = TextEditingController(
      text: widget.isEditing ? widget.query?.description ?? '' : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;

      if (widget.isEditing && widget.query != null) {
        context.read<QueryBloc>().add(
              QueryUpdateRequested(
                queryId: widget.query!.id,
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
              ),
            );
      } else {
        context.read<QueryBloc>().add(
              QueryCreateRequested(
                userId: authState.user!.uid,
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
              ),
            );
      }
    } else {
      _jitterKey.currentState?.trigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat('dd MMM yyyy').format(
      widget.query?.createdAt ?? DateTime.now(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF021224),
              Color(0xFF00060F),
            ],
          ),
        ),
        child: BlocListener<QueryBloc, QueryState>(
          listener: (context, state) {
            if (state.status == QueryStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isEditing
                        ? 'Query updated successfully'
                        : 'Query created successfully',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            } else if (state.status == QueryStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to save query'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 16,
                  child: AiGhostIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'AI-Based Priority Resolver',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ).animate().fadeIn(
                                  duration: const Duration(milliseconds: 450),
                                ),
                            const SizedBox(height: 82),
                            JitterField(
                              key: _jitterKey,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A223C).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: const Color(0xFF56B8FF).withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _titleController,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Title is required';
                                        }
                                        return null;
                                      },
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                      decoration: InputDecoration.collapsed(
                                        hintText: 'Query Title',
                                        hintStyle: AppTextStyles.headlineSmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _descriptionController,
                                      maxLines: 4,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Description is required';
                                        }
                                        return null;
                                      },
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 18,
                                      ),
                                      decoration: InputDecoration.collapsed(
                                        hintText: 'Query Description',
                                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary.withOpacity(0.6),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      height: 1.5,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF56B8FF).withOpacity(0.0),
                                            const Color(0xFF56B8FF).withOpacity(0.3),
                                            const Color(0xFF56B8FF).withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          displayDate,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().slideY(
                                    begin: 0.16,
                                    duration: const Duration(milliseconds: 460),
                                    curve: Curves.easeOutCubic,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: BlocBuilder<QueryBloc, QueryState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state.status == QueryStatus.creating ||
                                          state.status == QueryStatus.updating;
                                  return PrimaryButton(
                                    text: widget.isEditing
                                        ? 'Update query'
                                        : 'Add query',
                                    width: 210,
                                    onPressed: _submit,
                                    isLoading: isLoading,
                                  ).animate().fadeIn(
                                        delay: const Duration(milliseconds: 220),
                                        duration: const Duration(milliseconds: 420),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(height: 240),
                          ],
                        ),
                      ),
                    ),
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
