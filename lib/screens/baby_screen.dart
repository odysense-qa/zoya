
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../webrtc/signaling.dart';

class BabyScreen extends StatefulWidget {
  const BabyScreen({super.key});
  @override
  State<BabyScreen> createState() => _BabyScreenState();
}
class _BabyScreenState extends State<BabyScreen> {
  final _renderer = RTCVideoRenderer();
  BabyServer? _server;
  bool _dim = false;
  String _ipInfo = '';

  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    await _renderer.initialize();
    await [Permission.camera, Permission.microphone].request();
    final stream = await createLocalStream();
    _renderer.srcObject = stream;
    _server = BabyServer(stream);
    await _server!.start();
    final addrs = await NetworkInterface.list(type: InternetAddressType.IPv4);
    setState(() { _ipInfo = addrs.expand((e) => e.addresses.map((a) => a.address)).join(', '); });
  }
  @override
  void dispose() {
    _renderer.dispose();
    _server?.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final port = _server?.port ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Mode')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.wifi_rounded, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(child: Text('Advertising on LAN (Bonjour). IP: $_ipInfo • Port: $port', style: const TextStyle(color: Colors.black54))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: RTCVideoView(_renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      setState(() => _dim = !_dim);
                      if (_dim) { await WakelockPlus.enable(); } else { await WakelockPlus.disable(); }
                    },
                    icon: Icon(_dim ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    label: Text(_dim ? 'Keep Awake (Dimmed)' : 'Dim & Keep Awake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
