import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/bridge_view_client.dart';
import '../connection/connection_providers.dart';
import '../connection/connection_state.dart';
import '../widgets/theme_input.dart';
import 'display_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectionStatus>(statusProvider, (previous, next) {
      if (next == ConnectionStatus.connected &&
          previous != ConnectionStatus.connected &&
          mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const DisplayScreen()));
      }
    });

    final client = ref.watch(bridgeViewClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge View'),

        actions: const [ThemeInput()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _StatusBanner(),
          const SizedBox(height: 24),
          const _ConnectionForm(),
          const SizedBox(height: 16),
          const _ActionButton(),
          if (client.errorMessage != null) ...const [
            SizedBox(height: 16),
            _ErrorCard(),
          ],
          if (client.displayConfig != null) ...const [
            SizedBox(height: 24),
            _InfoCard(),
          ],
          if (client.framesReceived > 0) ...const [
            SizedBox(height: 16),
            _StatsCard(),
          ],
        ],
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(bridgeViewClientProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bar_chart),
            const SizedBox(width: 8),
            Text('Frames received: ${client.framesReceived}'),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends ConsumerWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(bridgeViewClientProvider).displayConfig;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Configuration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Session: ${config?.sessionId}'),
            Text(
              'Resolution: ${config?.displayWidth} x ${config?.displayHeight}',
            ),
            Text('Framerate: ${config?.framerate} fps'),
            Text('Codec: ${config?.codec.name}'),
            if (config?.hasPosition() ?? false)
              Text(
                'Position: (${config?.position.xOffset}, ${config?.position.yOffset})',
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(bridgeViewClientProvider);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                client.errorMessage ?? '',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends ConsumerWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    final (color, icon, label) = switch (status) {
      ConnectionStatus.disconnected => (
        Theme.of(context).colorScheme.error,
        Icons.cloud_off,
        'Disconnected',
      ),
      ConnectionStatus.connecting => (
        Theme.of(context).colorScheme.secondary,
        Icons.sync,
        'Connecting...',
      ),
      ConnectionStatus.registering => (
        Theme.of(context).colorScheme.secondary,
        Icons.app_registration,
        'Registering...',
      ),
      ConnectionStatus.connected => (
        Theme.of(context).colorScheme.primary,
        Icons.cloud_done,
        'Connected',
      ),
      ConnectionStatus.reconnecting => (
        Theme.of(context).colorScheme.secondary,
        Icons.refresh,
        'Reconnecting (${ref.watch(bridgeViewClientProvider).reconnectAttempts})...',
        // 'Reconnecting...',
      ),
    };

    return Card(
      color: color.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionForm extends ConsumerStatefulWidget {
  const _ConnectionForm();

  @override
  ConsumerState<_ConnectionForm> createState() => __ConnectionFormState();
}

class __ConnectionFormState extends ConsumerState<_ConnectionForm> {
  final _portController = TextEditingController(text: '9876');
  late final TextEditingController _hostController;

  @override
  void initState() {
    super.initState();
    final host = ref.read(hostProvider);
    _hostController = TextEditingController(text: host);
    _hostController.addListener(
      () => ref.read(hostProvider.notifier).state = _hostController.text.trim(),
    );
    _portController.addListener(() {
      final port = int.tryParse(_portController.text.trim()) ?? 9876;
      ref.read(portProvider.notifier).state = port;
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(statusProvider);
    final isDisconnected = status == ConnectionStatus.disconnected;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _hostController,
            enabled: isDisconnected,
            decoration: const InputDecoration(
              labelText: 'Server Host',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dns),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _portController,
            enabled: isDisconnected,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton();

  void _connect(WidgetRef ref) {
    ref.read(bridgeViewClientProvider.notifier).connect();
  }

  void _disconnect(WidgetRef ref) {
    ref.read(bridgeViewClientProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    final isDisconnected = status == ConnectionStatus.disconnected;
    if (isDisconnected) {
      return FilledButton.icon(
        onPressed: () => _connect(ref),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Connect'),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => _disconnect(ref),
      icon: const Icon(Icons.stop),
      label: const Text('Disconnect'),
    );
  }
}
