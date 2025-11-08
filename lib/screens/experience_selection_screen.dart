import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience.dart';
import '../providers/experience_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/wavy_progress_bar.dart';
import '../widgets/experience_card.dart';
import '../widgets/background_pattern.dart';
import '../screens/onboarding_question_screen.dart';

/// Experience Type Selection Screen
class ExperienceSelectionScreen extends ConsumerStatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  ConsumerState<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends ConsumerState<ExperienceSelectionScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final int maxCharacters = 250;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final selectionState = ref.read(experienceSelectionProvider);
    final description = _descriptionController.text.trim();

    // Validation
    if (selectionState.selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one experience')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your perfect hotspot')),
      );
      return;
    }

    // Update description in state
    ref
        .read(experienceSelectionProvider.notifier)
        .updateDescription(description);

    // Log the state
    print('Selected Experience IDs: ${selectionState.selectedIds}');
    print('Description: $description');

    // Navigate to onboarding question screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingQuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final selectionState = ref.watch(experienceSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      body: BackgroundPattern(
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress bar
              _buildHeader(context),
              // Main content - push to bottom
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Step number
                            Text(
                              '01',
                              style: AppTextStyles.s1Regular(
                                context,
                              ).copyWith(color: AppColors.text3),
                            ),
                            const SizedBox(height: 8),
                            // Question
                            Text(
                              'What kind of hotspots do you want to host?',
                              style: AppTextStyles.h1Regular(context),
                            ),
                            const SizedBox(height: 24),
                            // Experiences list
                            experiencesAsync.when(
                              data: (experiences) => _buildExperiencesList(
                                context,
                                experiences,
                                selectionState.selectedIds,
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stack) => Center(
                                child: Text(
                                  'Error loading experiences: $error',
                                  style: AppTextStyles.b1Regular(
                                    context,
                                  ).copyWith(color: AppColors.negative),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Description textfield
                            _buildDescriptionField(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Next button
              _buildNextButton(context, selectionState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button - disabled on first page
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.text1.withOpacity(0.5),
            ),
            onPressed: null, // Disabled on first page
          ),
          // Progress bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WavyProgressBar(currentStep: 1, totalSteps: 2, height: 4),
            ),
          ),
          // Close button - disabled on first page
          IconButton(
            icon: Icon(Icons.close, color: AppColors.text1.withOpacity(0.5)),
            onPressed: null, // Disabled on first page
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencesList(
    BuildContext context,
    List<Experience> experiences,
    List<int> selectedIds,
  ) {
    // Sort experiences: selected ones first (newly selected at index 0), then unselected
    final sortedExperiences = List<Experience>.from(experiences);
    sortedExperiences.sort((a, b) {
      final aSelected = selectedIds.contains(a.id);
      final bSelected = selectedIds.contains(b.id);
      if (aSelected && !bSelected) {
        // Newly selected items go to the front
        // Check which was selected more recently by checking selection order
        final aIndex = selectedIds.indexOf(a.id);
        final bIndex = selectedIds.indexOf(b.id);
        if (aIndex != -1 && bIndex != -1) {
          return aIndex.compareTo(bIndex); // Earlier selection comes first
        }
        return -1;
      }
      if (!aSelected && bSelected) return 1;
      // Maintain original order within each group
      return experiences.indexOf(a).compareTo(experiences.indexOf(b));
    });

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedExperiences.length,
        itemBuilder: (context, index) {
          final experience = sortedExperiences[index];
          final isSelected = selectedIds.contains(experience.id);

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: ExperienceCard(
                key: ValueKey(experience.id),
                experience: experience,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(experienceSelectionProvider.notifier)
                      .toggleSelection(experience.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border1, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: maxCharacters,
            style: AppTextStyles.b1Regular(context),
            decoration: InputDecoration(
              hintText: '/ Describe your perfect hotspot',
              hintStyle: AppTextStyles.b1Regular(
                context,
              ).copyWith(color: AppColors.text3),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${_descriptionController.text.length}/$maxCharacters',
            style: AppTextStyles.s1Regular(
              context,
            ).copyWith(color: AppColors.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    ExperienceSelectionState selectionState,
  ) {
    final canProceed = selectionState.selectedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canProceed ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.base2,
            disabledBackgroundColor: AppColors.base2.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: AppTextStyles.b1Bold(context).copyWith(
                  color: canProceed ? AppColors.text1 : AppColors.text3,
                ),
              ),
              const SizedBox(width: 8),
              // Double arrow icon (arrow + chevron)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: canProceed ? AppColors.text1 : AppColors.text3,
                    size: 18,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: canProceed ? AppColors.text1 : AppColors.text3,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
