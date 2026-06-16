import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

class MarketingHomeScreen extends StatelessWidget {
  const MarketingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF6),
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xEEFBFCF6),
              title: const _BrandMark(),
              actions: [
                _HeaderLink(
                  label: 'Prototype',
                  onTap: () => context.go(AppRoutes.prototype),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.prototype),
                    child: const Text('Open prototype'),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 70),
                    child: Column(
                      children: [
                        _HeroSection(theme: theme),
                        const SizedBox(height: 72),
                        const _SectionIntro(
                          eyebrow: 'Who we are',
                          title: 'A calmer way to buy food from nearby people.',
                          body:
                              'FreshNearby is a local marketplace concept for farmers, small producers, and customers who want fresh food without messy messaging, hidden stock, or unclear pickup steps.',
                        ),
                        const SizedBox(height: 28),
                        const _ValueGrid(),
                        const SizedBox(height: 78),
                        const _HowItWorksSection(),
                        const SizedBox(height: 78),
                        _PrototypeSection(
                          onOpenPrototype: () =>
                              context.go(AppRoutes.prototype),
                          onOpenCustomer: () => context.go(
                            AppRoutes.farmerPublicProfile('farmer-1'),
                          ),
                        ),
                        const SizedBox(height: 78),
                        const _RoadmapSection(),
                        const SizedBox(height: 54),
                        const _Footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF2F6B45), Color(0xFF9EC89A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        const Text(
          'FreshNearby',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.4),
        ),
      ],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(label));
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 820;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Pill('Local food marketplace prototype'),
        const SizedBox(height: 18),
        Text(
          'Fresh food, directly from nearby producers.',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 0.96,
            letterSpacing: -2.2,
            color: const Color(0xFF173F2A),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'FreshNearby helps farmers list what is available, accept requests, manage stock, and share a beautiful farm page customers can order from.',
          style: theme.textTheme.titleMedium?.copyWith(
            height: 1.45,
            color: const Color(0xFF526054),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.prototype),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open prototype'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.customerHome),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Customer demo'),
            ),
          ],
        ),
      ],
    );

    final visual = const _HeroVisual();

    return narrow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 34), visual],
          )
        : Row(
            children: [
              Expanded(flex: 11, child: copy),
              const SizedBox(width: 46),
              Expanded(flex: 10, child: visual),
            ],
          );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A173F2A),
            blurRadius: 45,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/home/hero_market.png',
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.52),
                      Colors.transparent,
                      const Color(0xFF173F2A).withValues(alpha: 0.62),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'North Field Farm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('New potatoes, honey, carrots and more.'),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        _MiniMetric(value: '24 kg', label: 'live stock'),
                        SizedBox(width: 10),
                        _MiniMetric(value: '4.9', label: 'rating'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3E7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2F6B45),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Pill(eyebrow),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
            color: const Color(0xFF173F2A),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              height: 1.5,
              color: const Color(0xFF526054),
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueGrid extends StatelessWidget {
  const _ValueGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _ValueCard(
        icon: Icons.storefront_outlined,
        title: 'For farmers',
        body:
            'Create listings, update stock, accept requests, share a farm link, and see monthly sales.',
      ),
      const _ValueCard(
        icon: Icons.shopping_bag_outlined,
        title: 'For customers',
        body:
            'Follow farms, add products to cart, request orders, track milestones, and review after delivery.',
      ),
      const _ValueCard(
        icon: Icons.local_shipping_outlined,
        title: 'For local logistics',
        body:
            'Keep pickup simple while supporting courier delivery as the marketplace scales.',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 780;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E9DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEAF3E7),
            foregroundColor: const Color(0xFF2F6B45),
            child: Icon(icon),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: const Color(0xFF526054),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF173F2A),
        borderRadius: BorderRadius.circular(34),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 760;
          final steps = [
            const _StepCard(
              '1',
              'List',
              'Farmers add product, price and stock.',
            ),
            const _StepCard(
              '2',
              'Request',
              'Customers choose quantity and request an order.',
            ),
            const _StepCard(
              '3',
              'Fulfil',
              'Farmers accept, prepare, and mark delivery status.',
            ),
            const _StepCard(
              '4',
              'Learn',
              'Reviews and sales insights help the farm improve.',
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Pill('What we do'),
              const SizedBox(height: 16),
              Text(
                'One simple flow from live stock to delivered order.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 24),
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      steps[i],
                    ],
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: steps[i]),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard(this.number, this.title, this.body);

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFFB8DFAF),
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _PrototypeSection extends StatelessWidget {
  const _PrototypeSection({
    required this.onOpenPrototype,
    required this.onOpenCustomer,
  });

  final VoidCallback onOpenPrototype;
  final VoidCallback onOpenCustomer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E7),
        borderRadius: BorderRadius.circular(34),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 820;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Pill('Prototype section'),
              const SizedBox(height: 16),
              Text(
                'Try the working farmer and customer demo.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: const Color(0xFF173F2A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The current prototype includes live-feeling order flow, stock reduction, cart, payment authorization, reviews, insights, and multilingual UI.',
                style: TextStyle(height: 1.5, color: Color(0xFF526054)),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenPrototype,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open prototype'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenCustomer,
                    icon: const Icon(Icons.person_search_outlined),
                    label: const Text('View farm page'),
                  ),
                ],
              ),
            ],
          );

          const preview = _PrototypePreview();
          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 24), preview],
                )
              : Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 28),
                    const Expanded(child: preview),
                  ],
                );
        },
      ),
    );
  }
}

class _PrototypePreview extends StatelessWidget {
  const _PrototypePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          _PreviewRow(
            icon: Icons.inventory_2_outlined,
            title: 'Product stock',
            body: 'New potato - 24 kg live',
          ),
          _PreviewRow(
            icon: Icons.receipt_long_outlined,
            title: 'Order status',
            body: 'Accepted - ready next',
          ),
          _PreviewRow(
            icon: Icons.insights_rounded,
            title: 'Monthly insight',
            body: 'Top product and sales trend',
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEAF3E7),
            foregroundColor: const Color(0xFF2F6B45),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapSection extends StatelessWidget {
  const _RoadmapSection();

  @override
  Widget build(BuildContext context) {
    final items = [
      'Supabase auth, database, storage and realtime updates',
      'Real payment authorization and refunds',
      'Courier dispatch and delivery tracking',
      'Farmer verification and admin tools',
      'Responsive web dashboard and public marketing site',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roadmap',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF173F2A),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              Chip(
                avatar: const Icon(Icons.check_circle_outline, size: 18),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(item),
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE1E9DE)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Divider(),
        SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_BrandMark(), Text('Prototype for local food ordering.')],
        ),
      ],
    );
  }
}
