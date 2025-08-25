
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme.dart';
import 'screens/onboarding.dart';
import 'screens/role_select.dart';
import 'screens/baby_screen.dart';
import 'screens/parent_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZoyaApp());
}
class ZoyaApp extends StatefulWidget {
  const ZoyaApp({super.key});
  @override
  State<ZoyaApp> createState() => _ZoyaAppState();
}
class _ZoyaAppState extends State<ZoyaApp> {
  bool _seenOnboarding = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoya',
      debugShowCheckedModeBanner: false,
      theme: ZoyaTheme.light,
      home: _seenOnboarding ? _Home() : OnboardingScreen(onFinish: () => setState(() => _seenOnboarding = true)),
    );
  }
}
class _Home extends StatefulWidget { @override State<_Home> createState() => _HomeState(); }
class _HomeState extends State<_Home> {
  bool _permissionsGranted = false;
  @override
  void initState() { super.initState(); _askPermissions(); }
  Future<void> _askPermissions() async {
    await [Permission.microphone, Permission.camera].request();
    setState(() => _permissionsGranted = true);
  }
  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Requesting camera & mic permissions…', style: Theme.of(context).textTheme.bodyLarge),
          ]),
        ),
      );
    }
    return RoleSelectScreen(
      onParent: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentScreen())),
      onBaby: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BabyScreen())),
    );
  }
}
