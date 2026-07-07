import 'package:bridge_view_client/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/connection_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(ProviderScope(child: const BridgeView()));
}

class BridgeView extends ConsumerWidget {
  const BridgeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Bridge View',
      themeMode: ref.watch(themeModeProvider),
      theme: getTheme(Brightness.light),
      darkTheme: getTheme(Brightness.dark),
      home: const ConnectionScreen(),
    );
  }
}
