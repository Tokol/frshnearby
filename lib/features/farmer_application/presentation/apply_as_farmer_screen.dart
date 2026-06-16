import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/forms/app_validators.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/farmer_application.dart';
import 'farmer_application_controller.dart';

class ApplyAsFarmerScreen extends ConsumerStatefulWidget {
  const ApplyAsFarmerScreen({super.key});

  @override
  ConsumerState<ApplyAsFarmerScreen> createState() =>
      _ApplyAsFarmerScreenState();
}

class _ApplyAsFarmerScreenState extends ConsumerState<ApplyAsFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  FarmerProfileType _profileType = FarmerProfileType.individual;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    final draft = ref.read(farmerApplicationControllerProvider).draft;
    _profileType = draft.profileType;
    _displayNameController.text = draft.displayName.isEmpty
        ? user?.name ?? ''
        : draft.displayName;
    _farmNameController.text = draft.farmName;
    _phoneController.text = draft.phone;
    _emailController.text = draft.email.isEmpty
        ? user?.email ?? ''
        : draft.email;
    _descriptionController.text = draft.shortDescription;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);

    if (!authState.canApplyAsFarmer) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.applyAsFarmerTitle)),
        body: ErrorState(
          title: l10n.unauthorizedTitle,
          message: authState.canAccessFarmerMode
              ? l10n.verifiedFarmerRequiredMessage
              : l10n.farmerPendingMessage,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applyAsFarmerTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.applyAsFarmerIntro,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.profileTypeLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<FarmerProfileType>(
                segments: [
                  ButtonSegment(
                    value: FarmerProfileType.individual,
                    label: Text(l10n.profileTypeIndividual),
                  ),
                  ButtonSegment(
                    value: FarmerProfileType.farm,
                    label: Text(l10n.profileTypeFarm),
                  ),
                  ButtonSegment(
                    value: FarmerProfileType.cooperative,
                    label: Text(l10n.profileTypeCooperative),
                  ),
                ],
                selected: {_profileType},
                onSelectionChanged: (selection) {
                  setState(() => _profileType = selection.first);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.displayNameLabel,
                controller: _displayNameController,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.required(l10n, value),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.farmNameLabel,
                controller: _farmNameController,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.required(l10n, value),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.phoneLabel,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.required(l10n, value),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.emailLabel,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.email(l10n, value),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.shortDescriptionLabel,
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) => AppValidators.required(l10n, value),
              ),
              const SizedBox(height: 16),
              _PhotoPlaceholder(label: l10n.profilePhotoPlaceholderLabel),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.continueButton,
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  ref
                      .read(farmerApplicationControllerProvider.notifier)
                      .updateProfile(
                        profileType: _profileType,
                        displayName: _displayNameController.text,
                        farmName: _farmNameController.text,
                        phone: _phoneController.text,
                        email: _emailController.text,
                        shortDescription: _descriptionController.text,
                        profilePhotoPlaceholder: 'placeholder',
                      );
                  context.go(AppRoutes.farmerLocation);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 96,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
