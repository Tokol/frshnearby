import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../data/early_access_submission.dart';
import 'marketing_tokens.dart';
import 'widgets/about_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/interested_section.dart';
import 'widgets/landing_footer.dart';
import 'widgets/landing_top_bar.dart';
import 'widgets/reveal_on_scroll.dart';

/// Animated farm-themed landing page. All copy comes from AppLocalizations,
/// so the flag picker in the top bar re-localizes the whole page (and the
/// prototype behind it) instantly.
class MarketingHomeScreen extends ConsumerStatefulWidget {
  const MarketingHomeScreen({super.key});

  @override
  ConsumerState<MarketingHomeScreen> createState() =>
      _MarketingHomeScreenState();
}

class _MarketingHomeScreenState extends ConsumerState<MarketingHomeScreen> {
  final _emailController = TextEditingController();
  final _countryController = TextEditingController(text: 'Finland');
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _aboutKey = GlobalKey();
  final _formKey = GlobalKey();

  EarlyAccessRole _role = EarlyAccessRole.consumer;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _joinEarlyAccess() {
    FocusScope.of(context).unfocus();
    // Fire and forget; the sheet gets English role labels for easy filtering.
    EarlyAccessSubmission.submit(
      email: _emailController.text.trim(),
      role: switch (_role) {
        EarlyAccessRole.consumer => 'Consumer',
        EarlyAccessRole.farmer => 'Food producer',
        EarlyAccessRole.restaurant => 'Restaurant / Shop',
      },
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
      message: _messageController.text.trim(),
    );
    setState(() => _submitted = true);
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  void _openPrototype() => context.go(AppRoutes.prototype);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingColors.paper,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 42),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LandingTopBar(
                          onAbout: () => _scrollTo(_aboutKey),
                          onInterested: () => _scrollTo(_formKey),
                          onPrototype: _openPrototype,
                        ),
                        const SizedBox(height: 18),
                        HeroSection(
                          onJoin: () => _scrollTo(_formKey),
                          onPrototype: _openPrototype,
                        ),
                        const SizedBox(height: 64),
                        RevealOnScroll(
                          key: _aboutKey,
                          child: const AboutSection(),
                        ),
                        const SizedBox(height: 64),
                        RevealOnScroll(
                          key: _formKey,
                          child: InterestedSection(
                            emailController: _emailController,
                            countryController: _countryController,
                            phoneController: _phoneController,
                            messageController: _messageController,
                            role: _role,
                            submitted: _submitted,
                            onRoleChanged: (value) {
                              if (value != null) setState(() => _role = value);
                            },
                            onSubmit: _joinEarlyAccess,
                          ),
                        ),
                        const SizedBox(height: 48),
                        const RevealOnScroll(child: LandingFooter()),
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
