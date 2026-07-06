import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import 'marketing_tokens.dart';

class PrototypeHomeScreen extends StatelessWidget {
  const PrototypeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 860;

    return Scaffold(
      backgroundColor: LandingColors.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: _RolePanel(
                            onFarmer: () =>
                                context.go(AppRoutes.farmerDashboard),
                            onConsumer: () =>
                                context.go(AppRoutes.customerHome),
                          ),
                        ),
                        const SizedBox(width: 22),
                        const Expanded(flex: 10, child: _PreviewPanel()),
                      ],
                    )
                  : ListView(
                      children: [
                        _RolePanel(
                          onFarmer: () => context.go(AppRoutes.farmerDashboard),
                          onConsumer: () => context.go(AppRoutes.customerHome),
                        ),
                        const SizedBox(height: 18),
                        const _PreviewPanel(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RolePanel extends StatelessWidget {
  const _RolePanel({required this.onFarmer, required this.onConsumer});

  final VoidCallback onFarmer;
  final VoidCallback onConsumer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _PrototypeBrandStrip(),
        const SizedBox(height: 34),
        Text(
          l10n.prototypeChooserTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: LandingColors.ink,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.prototypeChooserSubtitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: LandingColors.muted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 26),
        _RoleButton(
          title: l10n.farmerModeLabel,
          subtitle: l10n.prototypeFarmerHint,
          icon: Icons.agriculture_rounded,
          color: LandingColors.green,
          onTap: onFarmer,
        ),
        const SizedBox(height: 12),
        _RoleButton(
          title: l10n.consumerModeLabel,
          subtitle: l10n.prototypeConsumerHint,
          icon: Icons.shopping_basket_rounded,
          color: LandingColors.olive,
          onTap: onConsumer,
        ),
      ],
    );
  }
}

class _PrototypeBrandStrip extends StatelessWidget {
  const _PrototypeBrandStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [SvgPicture.asset('assets/images/logo/logo.svg', height: 42)],
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: LandingColors.muted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 520;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/home/hero_market.png',
            width: double.infinity,
            height: narrow ? 300 : 560,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _PreviewStats(),
          ),
        ],
      ),
    );
  }
}

class _PreviewStats extends StatelessWidget {
  const _PreviewStats();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _StatChip(label: '12 listings live', icon: Icons.storefront_rounded),
        _StatChip(label: '4 active orders', icon: Icons.receipt_long_rounded),
        _StatChip(label: 'Local pickup', icon: Icons.place_rounded),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: LandingColors.green),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: LandingColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
