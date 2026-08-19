import 'package:bridge_view_client/theme/theme_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeInput extends ConsumerWidget {
  const ThemeInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode),
        ),
        ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.devices)),
        ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode)),
      ],
      showSelectedIcon: false,
      selected: {ref.watch(themeModeProvider)},
      onSelectionChanged: (value) {
        ref.read(themeModeProvider.notifier).state = value.single;
      },
    );
  }
}
