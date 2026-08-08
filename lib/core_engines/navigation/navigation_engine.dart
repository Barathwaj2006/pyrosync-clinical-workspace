import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WorkspaceModule {
  dashboard,
  patients,
  sessions,
  recording,
  analysis,
  aiWorkspace,
  reports,
  neurolab,
  settings,
  help,
}

class NavigationState {
  final WorkspaceModule currentModule;
  final List<WorkspaceModule> historyStack;

  NavigationState({
    required this.currentModule,
    required this.historyStack,
  });
}

final navigationEngineProvider = StateNotifierProvider<NavigationEngineNotifier, NavigationState>((ref) {
  return NavigationEngineNotifier();
});

class NavigationEngineNotifier extends StateNotifier<NavigationState> {
  NavigationEngineNotifier()
      : super(
          NavigationState(
            currentModule: WorkspaceModule.dashboard,
            historyStack: [WorkspaceModule.dashboard],
          ),
        );

  void navigateTo(WorkspaceModule module) {
    if (state.currentModule == module) return;
    state = NavigationState(
      currentModule: module,
      historyStack: [...state.historyStack, module],
    );
  }

  void pop() {
    if (state.historyStack.length <= 1) return;
    final newStack = List<WorkspaceModule>.from(state.historyStack)..removeLast();
    state = NavigationState(
      currentModule: newStack.last,
      historyStack: newStack,
    );
  }
}
