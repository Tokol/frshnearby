import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';

class FarmerReviewsScreen extends ConsumerWidget {
  const FarmerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(authControllerProvider).user?.farmerProfile;
    return Scaffold(
      appBar: AppBar(title: const Text('Your farm')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Container(
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/home/hero_market.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: Color(0xFF2F6B45),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Verified farm',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EEDC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 5,
                      ),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 38,
                      color: Color(0xFF2F6B45),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Column(
                  children: [
                    Text(
                      profile?.farmName ?? 'North Field Farm',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile?.city ?? 'Vaasa'}, ${profile?.country ?? 'Finland'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Seasonal vegetables grown with care. Fresh harvests, honest quantities, and simple local pickup.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const _FarmStats(),
              const SizedBox(height: 22),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.go(AppRoutes.farmerPublicProfile('farmer-1')),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview customer profile'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit farm details'),
              ),
              const SizedBox(height: 28),
              Text(
                'Farm details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _DetailTile(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: profile?.phone ?? '+358 40 123 4567',
              ),
              _DetailTile(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                value: profile?.email ?? 'farmer@example.com',
              ),
              const _DetailTile(
                icon: Icons.schedule_rounded,
                title: 'Pickup hours',
                value: 'Mon-Sat, 10:00-18:00',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmStats extends StatelessWidget {
  const _FarmStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _Stat(value: '4.8', label: 'Rating'),
          ),
          SizedBox(height: 34, child: VerticalDivider()),
          Expanded(
            child: _Stat(value: '124', label: 'Reviews'),
          ),
          SizedBox(height: 34, child: VerticalDivider()),
          Expanded(
            child: _Stat(value: '4', label: 'Products'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8EEE6),
        foregroundColor: const Color(0xFF2F6B45),
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
