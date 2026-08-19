import 'package:material_ui/material_ui.dart';

import '../utils/state_provider.dart';

final themeModeProvider = StateProvider.autoDispose<ThemeMode>(
  (_) => ThemeMode.system,
);
