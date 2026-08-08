import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  doctor,
  technician,
  administrator,
  researcher,
}

class UserPermissions {
  final bool canAcquireSignal;
  final bool canModifyProtocols;
  final bool canSignReports;
  final bool canManageUsers;
  final bool canExportData;

  const UserPermissions({
    required this.canAcquireSignal,
    required this.canModifyProtocols,
    required this.canSignReports,
    required this.canManageUsers,
    required this.canExportData,
  });

  factory UserPermissions.fromRole(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return const UserPermissions(
          canAcquireSignal: true,
          canModifyProtocols: true,
          canSignReports: true,
          canManageUsers: false,
          canExportData: true,
        );
      case UserRole.technician:
        return const UserPermissions(
          canAcquireSignal: true,
          canModifyProtocols: false,
          canSignReports: false,
          canManageUsers: false,
          canExportData: true,
        );
      case UserRole.administrator:
        return const UserPermissions(
          canAcquireSignal: false,
          canModifyProtocols: true,
          canSignReports: false,
          canManageUsers: true,
          canExportData: true,
        );
      case UserRole.researcher:
        return const UserPermissions(
          canAcquireSignal: true,
          canModifyProtocols: true,
          canSignReports: false,
          canManageUsers: false,
          canExportData: true,
        );
    }
  }
}

class ClinicianProfile {
  final String fullName;
  final String title;
  final String institution;
  final String credentials;
  final String email;

  const ClinicianProfile({
    required this.fullName,
    required this.title,
    required this.institution,
    required this.credentials,
    required this.email,
  });

  bool get isConfigured => fullName != 'Unconfigured Clinician' && fullName.trim().isNotEmpty;

  ClinicianProfile copyWith({
    String? fullName,
    String? title,
    String? institution,
    String? credentials,
    String? email,
  }) {
    return ClinicianProfile(
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      institution: institution ?? this.institution,
      credentials: credentials ?? this.credentials,
      email: email ?? this.email,
    );
  }

  factory ClinicianProfile.defaultProfile() {
    return const ClinicianProfile(
      fullName: 'Unconfigured Clinician',
      title: 'Attending Neurologist',
      institution: 'Pyromatics Medical Center',
      credentials: 'MD, PhD',
      email: 'clinician@pyromaticsbio.com',
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final ClinicianProfile profile;
  final UserRole role;
  final UserPermissions permissions;

  AuthState({
    required this.isAuthenticated,
    required this.profile,
    required this.role,
    required this.permissions,
  });

  factory AuthState.initial() {
    final defaultRole = UserRole.doctor;
    return AuthState(
      isAuthenticated: true,
      profile: ClinicianProfile.defaultProfile(),
      role: defaultRole,
      permissions: UserPermissions.fromRole(defaultRole),
    );
  }
}

final authEngineProvider = StateNotifierProvider<AuthEngineNotifier, AuthState>((ref) {
  return AuthEngineNotifier();
});

class AuthEngineNotifier extends StateNotifier<AuthState> {
  AuthEngineNotifier() : super(AuthState.initial());

  void updateProfile({
    String? fullName,
    String? title,
    String? institution,
    String? credentials,
    String? email,
  }) {
    final updatedProfile = state.profile.copyWith(
      fullName: fullName,
      title: title,
      institution: institution,
      credentials: credentials,
      email: email,
    );
    state = AuthState(
      isAuthenticated: state.isAuthenticated,
      profile: updatedProfile,
      role: state.role,
      permissions: state.permissions,
    );
  }

  void switchRole(UserRole newRole) {
    state = AuthState(
      isAuthenticated: state.isAuthenticated,
      profile: state.profile,
      role: newRole,
      permissions: UserPermissions.fromRole(newRole),
    );
  }
}
