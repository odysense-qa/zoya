
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class ZoyaMdns {
  static const String serviceType = '_zoya._tcp';
}

const Map<String, dynamic> _rtcConfig = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
  ]
};

const Map<String, dynamic> _offerConstraints = {
  'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
  'optional': [],
};

Future<void> _waitIceComplete(RTCPeerConnection pc) async {
  if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) return;
  final c = Completer<void>();
  pc.onIceGatheringState = (s) {
    if (s == RTCIceGatheringState.RTCIceGatheringStateComplete && !c.isCompleted) c.complete();
  };
  await c.future.timeout(const Duration(seconds: 8), onTimeout: () {});
}

Future<MediaStream> createLocalStream() async {
  final mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'environment',
      'width': {'ideal': 1280},
      'height': {'ideal': 720},
      'frameRate': {'ideal': 15},
    }
  };
  return await navigator.mediaDevices.getUserMedia(mediaConstraints);
}

class BabyServer {
  HttpServer? _server;
  BonsoirBroadcast? _broadcast;
  final MediaStream localStream;
  BabyServer(this.localStream);
  int? get port => _server?.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_handle);
    _broadcast = BonsoirBroadcast(service: BonsoirService(name: 'Zoya Baby', type: ZoyaMdns.serviceType, port: _server!.port, attributes: {'role': 'baby'}));
    await _broadcast!.ready;
    await _broadcast!.start();
  }

  Future<void> stop() async {
    await _broadcast?.stop();
    await _server?.close(force: true);
  }

  Future<void> _handle(HttpRequest req) async {
    if (req.method == 'POST' && req.uri.path == '/offer') {
      final data = await utf8.decoder.bind(req).join();
      final Map<String, dynamic> offerJson = json.decode(data);
      final pc = await createPeerConnection(_rtcConfig);
      for (var track in localStream.getTracks()) {
        await pc.addTrack(track, localStream);
      }
      final remoteDesc = RTCSessionDescription(offerJson['sdp'], offerJson['type']);
      await pc.setRemoteDescription(remoteDesc);
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      await _waitIceComplete(pc);
      final ld = await pc.getLocalDescription();
      final resp = {'sdp': ld?.sdp, 'type': ld?.type};
      req.response..headers.contentType = ContentType.json..write(json.encode(resp))..close();
    } else {
      req.response.statusCode = 404;
      req.response.close();
    }
  }
}

class ParentClient {
  final String host;
  final int port;
  RTCPeerConnection? pc;
  final RTCVideoRenderer remoteRenderer;
  ParentClient({required this.host, required this.port, required this.remoteRenderer});

  Future<void> connect() async {
    pc = await createPeerConnection(_rtcConfig);
    pc!.onTrack = (event) {
      if (event.track.kind == 'video') {
        remoteRenderer.srcObject = event.streams.first;
      }
    };
    final offer = await pc!.createOffer(_offerConstraints);
    await pc!.setLocalDescription(offer);
    await _waitIceComplete(pc!);
    final uri = Uri.parse('http://$host:$port/offer');
    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'sdp': offer.sdp, 'type': offer.type}));
    final ans = json.decode(resp.body);
    final answer = RTCSessionDescription(ans['sdp'], ans['type']);
    await pc!.setRemoteDescription(answer);
  }

  Future<void> dispose() async {
    await pc?.close();
    await remoteRenderer.dispose();
  }
}

class Discovery {
  final BonsoirDiscovery _discovery = BonsoirDiscovery(type: ZoyaMdns.serviceType);
  final StreamController<BonsoirService> _controller = StreamController.broadcast();
  Stream<BonsoirService> get services => _controller.stream;

  Future<void> start() async {
    _discovery.eventStream!.listen((event) async {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        final service = event.service!;
        await service.resolve(discovery: _discovery);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        final service = event.service!;
        _controller.add(service);
      }
    });
    await _discovery.ready;
    await _discovery.start();
  }

  Future<void> stop() async {
    await _discovery.stop();
  }
}
