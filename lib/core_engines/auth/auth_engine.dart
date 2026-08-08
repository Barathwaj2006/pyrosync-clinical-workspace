import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  doctor,
  technician,
  administrator,
  researcher,
  patient,
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
      case UserRole.patient:
        return const UserPermissions(
          canAcquireSignal: false,
          canModifyProtocols: false,
          canSignReports: false,
          canManageUsers: false,
          canExportData: false,
        );
    }
  }
}

class UserSession {
  final String userId;
  final String fullName;
  final String email;
  final UserRole role;
  final UserPermissions permissions;
  final DateTime loginTime;

  UserSession({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.permissions,
    required this.loginTime,
  });
}

class AuthState {
  final bool isAuthenticated;
  final UserSession? currentSession;

  AuthState({required this.isAuthenticated, this.currentSession});

  factory AuthState.initial() {
    final defaultRole = UserRole.doctor;
    return AuthState(
      isAuthenticated: true,
      currentSession: UserSession(
        userId: 'DR-88902',
        fullName: 'Dr. Elena Vance',
        email: 'e.vance@pyromaticsbio.com',
        role: defaultRole,
        permissions: UserPermissions.fromRole(defaultRole),
        loginTime: DateTime.now(),
      ),
    );
  }
}

final authEngineProvider = StateNotifierProvider<AuthEngineNotifier, AuthState>((ref) {
  return AuthEngineNotifier();
});

class AuthEngineNotifier extends StateNotifier<AuthState> {
  AuthEngineNotifier() : super(AuthState.initial());

  void login(String email, String password, UserRole role) {
    state = AuthState(
      isAuthenticated: true,
      currentSession: UserSession(
        userId: 'USER-${DateTime.now().millisecondsSinceEpoch}',
        fullName: role == UserRole.doctor ? 'Dr. Elena Vance' : 'J. Miller (Tech)',
        email: email,
        role: role,
        permissions: UserPermissions.fromRole(role),
        loginTime: DateTime.now(),
      ),
    );
  }

  void logout() {
    state = AuthState(isAuthenticated: false, currentSession: null);
  }

  void switchRole(UserRole role) {
    if (state.currentSession == null) return;
    state = AuthState(
      isAuthenticated: true,
      currentSession: UserSession(
        userId: state.currentSession!.userId,
        fullName: state.currentSession!.fullName,
        email: state.currentSession!.email,
        role: role,
        permissions: UserPermissions.fromRole(role),
        loginTime: state.currentSession!.loginTime,
      ),
    );
  }
}
