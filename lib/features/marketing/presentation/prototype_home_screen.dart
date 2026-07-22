import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';

/// Enters the interactive prototype without showing an additional role gate.
///
/// The demo farmer identity can access both sides of the prototype, so the
/// Farmer/Consumer switch inside the app remains the single role control.
class PrototypeHomeScreen extends ConsumerStatefulWidget {
  const PrototypeHomeScreen({super.key});

  @override
  ConsumerState<PrototypeHomeScreen> createState() =>
      _PrototypeHomeScreenState();
}

class _PrototypeHomeScreenState extends ConsumerState<PrototypeHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = ref.read(authControllerProvider);
      if (!authState.canAccessFarmerMode) {
        ref.read(authControllerProvider.notifier).enterFarmerPrototype();
        return;
      }
      context.go(AppRoutes.customerHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
