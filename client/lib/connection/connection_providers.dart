import 'package:bridge_view_client/connection/bridge_view_client.dart';
import 'package:bridge_view_client/proto/proto/display.pb.dart';
import 'package:bridge_view_client/utils/state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';

import 'connection_state.dart';

final statusProvider = Provider.autoDispose<ConnectionStatus>(
  (ref) => ref.watch(bridgeViewClientProvider).status,
  dependencies: [bridgeViewClientProvider],
);

final hostProvider = StateProvider.autoDispose<String>((_) => 'localhost');

final portProvider = StateProvider.autoDispose<int>((_) => 9876);

final webSocketUrlProvider = Provider.autoDispose<String>((ref) {
  final host = ref.watch(hostProvider);
  final port = ref.watch(portProvider);
  return 'ws://$host:$port';
}, dependencies: [hostProvider, portProvider]);

final socketChannelProvider = FutureProvider(
  (ref) async {
    final url = ref.watch(webSocketUrlProvider);
    final channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      pingInterval: const Duration(seconds: 5),
    );
    await channel.ready;
  },
  isAutoDispose: true,
  dependencies: [webSocketUrlProvider],
);

final frameStreamProvider = StreamProvider.autoDispose<VideoFrame>((ref) {
  final client = ref.read(bridgeViewClientProvider.notifier);
  return client.frameStream;
}, dependencies: [bridgeViewClientProvider]);
