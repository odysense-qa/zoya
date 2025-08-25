
import 'package:flutter/material.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  final pages = const [
    _Onb(title: 'Welcome to Zoya', body: 'A private, local-only baby monitor for your family.', emoji: '🍼'),
    _Onb(title: 'Two Roles', body: 'Choose “Baby” on the device in the room. Choose “Parent” on the device you carry.', emoji: '👶👩‍👦'),
    _Onb(title: 'Same Wi‑Fi', body: 'Both devices should be on the same Wi‑Fi for best performance.', emoji: '📶'),
    _Onb(title: 'Permissions', body: 'Zoya needs access to camera, mic, and local network discovery.', emoji: '🎥🎙️'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == i ? Colors.black87 : Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_index == pages.length - 1) {
                        widget.onFinish();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_index == pages.length - 1 ? 'Get Started' : 'Next'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
class _Onb extends StatelessWidget {
  final String title, body, emoji;
  const _Onb({required this.title, required this.body, required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(body, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
