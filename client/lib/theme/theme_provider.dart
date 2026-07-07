import 'package:flutter/material.dart';

import '../utils/state_provider.dart';

final themeModeProvider = StateProvider.autoDispose<ThemeMode>(
  (_) => ThemeMode.system,
);
