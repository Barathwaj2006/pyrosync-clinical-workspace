class FeatureFlags {
  final bool enableNeuroLabSimulator;
  final bool enableVisualizationEngine;
  final bool enableCdssRuleEngine;
  final bool enableGuidedWorkflow;
  final bool enableDeveloperOverlay;
  final bool enableHardwareSimulation;
  final bool enableExperimentalDemyelinationAi;

  FeatureFlags({
    this.enableNeuroLabSimulator = true,
    this.enableVisualizationEngine = true,
    this.enableCdssRuleEngine = true,
    this.enableGuidedWorkflow = true,
    this.enableDeveloperOverlay = true,
    this.enableHardwareSimulation = true,
    this.enableExperimentalDemyelinationAi = false,
  });

  FeatureFlags copyWith({
    bool? enableNeuroLabSimulator,
    bool? enableVisualizationEngine,
    bool? enableCdssRuleEngine,
    bool? enableGuidedWorkflow,
    bool? enableDeveloperOverlay,
    bool? enableHardwareSimulation,
    bool? enableExperimentalDemyelinationAi,
  }) {
    return FeatureFlags(
      enableNeuroLabSimulator: enableNeuroLabSimulator ?? this.enableNeuroLabSimulator,
      enableVisualizationEngine: enableVisualizationEngine ?? this.enableVisualizationEngine,
      enableCdssRuleEngine: enableCdssRuleEngine ?? this.enableCdssRuleEngine,
      enableGuidedWorkflow: enableGuidedWorkflow ?? this.enableGuidedWorkflow,
      enableDeveloperOverlay: enableDeveloperOverlay ?? this.enableDeveloperOverlay,
      enableHardwareSimulation: enableHardwareSimulation ?? this.enableHardwareSimulation,
      enableExperimentalDemyelinationAi: enableExperimentalDemyelinationAi ?? this.enableExperimentalDemyelinationAi,
    );
  }
}

class FeatureFlagsManager {
  FeatureFlags _flags = FeatureFlags();

  FeatureFlags get flags => _flags;

  void toggleFlag(String key, bool val) {
    if (key == 'neurolab') _flags = _flags.copyWith(enableNeuroLabSimulator: val);
    if (key == 'visualization') _flags = _flags.copyWith(enableVisualizationEngine: val);
    if (key == 'cdss') _flags = _flags.copyWith(enableCdssRuleEngine: val);
    if (key == 'workflow') _flags = _flags.copyWith(enableGuidedWorkflow: val);
    if (key == 'developerOverlay') _flags = _flags.copyWith(enableDeveloperOverlay: val);
    if (key == 'experimentalAi') _flags = _flags.copyWith(enableExperimentalDemyelinationAi: val);
  }
}
