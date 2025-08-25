
import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../webrtc/signaling.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}
class _ParentScreenState extends State<ParentScreen> {
  final Discovery _discovery = Discovery();
  final List<BonsoirService> _services = [];
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }
  Future<void> _startDiscovery() async {
    await _discovery.start();
    _sub = _discovery.services.listen((s) {
      if (!_services.any((e) => e.name == s.name && e.port == s.port)) {
        setState(() => _services.add(s));
      }
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    _discovery.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Mode')),
      body: ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, i) {
          final s = _services[i];
          final host = (s is ResolvedBonsoirService) ? (s as ResolvedBonsoirService).host : 'Unknown';
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.videocam_rounded)),
              title: Text(s.name.isNotEmpty ? s.name : 'Zoya Baby'),
              subtitle: Text('Host: $host  •  Port: ${s.port}'),
              trailing: FilledButton(
                onPressed: host == 'Unknown' ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveView(host: host, port: s.port))),
                child: const Text('Connect'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiveView extends StatefulWidget {
  final String host;
  final int port;
  const LiveView({super.key, required this.host, required this.port});
  @override
  State<LiveView> createState() => _LiveViewState();
}
class _LiveViewState extends State<LiveView> {
  final _remote = RTCVideoRenderer();
  ParentClient? _client;
  @override
  void initState() { super.initState(); _init(); }
  Future<void> _init() async {
    await _remote.initialize();
    _client = ParentClient(host: widget.host, port: widget.port, remoteRenderer: _remote);
    await _client!.connect();
    setState(() {});
  }
  @override
  void dispose() { _client?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream')),
      body: _client == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(child: RTCVideoView(_remote, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
                Positioned(
                  bottom: 24, left: 24, right: 24,
                  child: Row(
                    children: [
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.volume_up_rounded), label: const Text('Audio')),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), label: const Text('Disconnect')),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
