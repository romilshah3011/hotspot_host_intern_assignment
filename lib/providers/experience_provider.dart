import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience.dart';
import '../services/api_service.dart';

/// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provider for experiences list
final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getExperiences();
});

/// State model for experience selection
class ExperienceSelectionState {
  final List<int> selectedIds;
  final String description;

  ExperienceSelectionState({
    this.selectedIds = const [],
    this.description = '',
  });

  ExperienceSelectionState copyWith({
    List<int>? selectedIds,
    String? description,
  }) {
    return ExperienceSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      description: description ?? this.description,
    );
  }
}

/// Provider for experience selection state
final experienceSelectionProvider =
    StateNotifierProvider<
      ExperienceSelectionNotifier,
      ExperienceSelectionState
    >((ref) => ExperienceSelectionNotifier());

class ExperienceSelectionNotifier
    extends StateNotifier<ExperienceSelectionState> {
  ExperienceSelectionNotifier() : super(ExperienceSelectionState());

  void toggleSelection(int experienceId) {
    final currentIds = List<int>.from(state.selectedIds);
    if (currentIds.contains(experienceId)) {
      currentIds.remove(experienceId);
    } else {
      currentIds.add(experienceId);
    }
    state = state.copyWith(selectedIds: currentIds);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void reset() {
    state = ExperienceSelectionState();
  }
}
