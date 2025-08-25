
import 'package:flutter/material.dart';
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key, required this.onParent, required this.onBaby});
  final VoidCallback onParent;
  final VoidCallback onBaby;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoya')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who are you today?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _RoleCard(title: 'Parent', subtitle: 'Discover nearby baby devices and watch the live stream.', icon: Icons.monitor_heart_rounded, onTap: onParent),
            _RoleCard(title: 'Baby', subtitle: 'Stream camera & microphone for monitoring.', icon: Icons.child_friendly_rounded, onTap: onBaby),
            const Spacer(),
            Text('Tip: keep both devices on the same Wi‑Fi.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
class _RoleCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.04), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded)
            ],
          ),
        ),
      ),
    );
  }
}
