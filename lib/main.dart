import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/theme/pyro_theme.dart';
import 'modules/shell/desktop_layout_shell.dart';
import 'core_engines/developer/developer_engine.dart';
import 'core_engines/theme/theme_engine_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PyroSyncApp(),
    ),
  );
}

class PyroSyncApp extends ConsumerWidget {
  const PyroSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeEngineProvider);

    return MaterialApp(
      title: 'PyroSync Clinical Workspace',
      debugShowCheckedModeBanner: false,
      theme: PyroTheme.getThemeData(themeMode),
      home: const DeveloperShortcutListener(
        child: DesktopLayoutShell(),
      ),
    );
  }
}
