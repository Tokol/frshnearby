import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/device_image_picker.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/domain/farmer_profile.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';

class EditFarmProfileScreen extends ConsumerStatefulWidget {
  const EditFarmProfileScreen({super.key});

  @override
  ConsumerState<EditFarmProfileScreen> createState() =>
      _EditFarmProfileScreenState();
}

class _EditFarmProfileScreenState extends ConsumerState<EditFarmProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pickupController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  String? _profilePhoto;
  String _coverPhoto = 'assets/images/home/hero_market.png';
  bool _pickupAvailable = true;
  bool _pickupAtFarm = true;
  bool _initialized = false;

  @override
  void dispose() {
    _farmNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _pickupAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final profile = authState.user?.farmerProfile;
    if (profile == null) {
      return Scaffold(
        body: Center(child: Text(l10n.farmProfileNotFoundMessage)),
      );
    }
    _initialize(profile);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editFarmProfileTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppRoutes.farmerSettings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            _PhotoHeader(
              coverPhoto: _coverPhoto,
              profilePhoto: _profilePhoto,
              farmName: _farmNameController.text.isEmpty
                  ? profile.farmName
                  : _farmNameController.text,
              onCoverTap: () => _pickPhoto(isCover: true),
              onProfileTap: () => _pickPhoto(isCover: false),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(isCover: false),
                    icon: const Icon(Icons.account_circle_outlined),
                    label: Text(l10n.changeProfilePhotoLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(isCover: true),
                    icon: const Icon(Icons.landscape_outlined),
                    label: Text(l10n.changeCoverPhotoLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _farmNameController,
              validator: _required,
              decoration: InputDecoration(
                labelText: l10n.farmNameLabel,
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              validator: _required,
              maxLines: 3,
              maxLength: 140,
              decoration: InputDecoration(
                labelText: l10n.shortIntroductionLabel,
                hintText: l10n.farmIntroductionHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.customerContactNumberLabel,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                l10n.farmPickupLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(l10n.farmPickupDescription),
              value: _pickupAvailable,
              onChanged: (value) => setState(() => _pickupAvailable = value),
            ),
            if (_pickupAvailable) ...[
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  l10n.pickupAtFarmLocationLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(l10n.pickupAtFarmLocationDescription),
                value: _pickupAtFarm,
                onChanged: (value) => setState(() => _pickupAtFarm = value),
              ),
              const SizedBox(height: 12),
              if (_pickupAtFarm)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${profile.city}, ${profile.country}\n${l10n.exactLocationAfterAcceptance}',
                        ),
                      ),
                    ],
                  ),
                )
              else
                TextFormField(
                  controller: _pickupAddressController,
                  validator: (value) =>
                      !_pickupAtFarm && (value == null || value.trim().isEmpty)
                      ? l10n.pickupAddressRequired
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.setPickupLocationLabel,
                    hintText: l10n.pickupLocationHint,
                    prefixIcon: const Icon(Icons.add_location_alt_outlined),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pickupController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.pickupNoteLabel,
                  hintText: l10n.pickupNoteHint,
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.farmLocationLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text('${profile.city}, ${profile.country}'),
                        Text(
                          l10n.confirmedGpsLocationLabel,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: authState.isLoading ? null : () => _save(profile),
              child: authState.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.savePublicProfileLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _initialize(FarmerProfile profile) {
    if (_initialized) return;
    _farmNameController.text = profile.farmName;
    _descriptionController.text = profile.shortDescription ?? '';
    _phoneController.text = profile.phone ?? '';
    _pickupController.text = profile.pickupNote ?? '';
    _pickupAvailable = profile.pickupAvailable;
    _pickupAtFarm = profile.pickupAtFarm;
    _pickupAddressController.text = profile.pickupAddress ?? '';
    _profilePhoto = profile.profilePhotoPlaceholder;
    _coverPhoto =
        profile.coverPhotoPlaceholder ?? 'assets/images/home/hero_market.png';
    _initialized = true;
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Please enter this information.'
      : null;

  Future<void> _save(FarmerProfile profile) async {
    if (!_formKey.currentState!.validate()) return;
    final updated = profile.copyWith(
      farmName: _farmNameController.text.trim(),
      displayName: _farmNameController.text.trim(),
      shortDescription: _descriptionController.text.trim(),
      phone: _phoneController.text.trim(),
      profilePhotoPlaceholder: _profilePhoto,
      coverPhotoPlaceholder: _coverPhoto,
      pickupNote: _pickupController.text.trim(),
      pickupAvailable: _pickupAvailable,
      pickupAtFarm: _pickupAtFarm,
      pickupAddress: _pickupAddressController.text.trim(),
    );
    await ref
        .read(authControllerProvider.notifier)
        .updateFarmerProfile(updated);
    await ref
        .read(customerMarketplaceRepositoryProvider)
        .updateFarmerProfile(updated);
    ref.invalidate(farmerPublicProfileProvider(updated.id));
    if (mounted) context.pop();
  }

  Future<void> _pickPhoto({required bool isCover}) async {
    final image = await pickDeviceImage();
    if (image == null || !mounted) return;
    setState(() {
      if (isCover) {
        _coverPhoto = image;
      } else {
        _profilePhoto = image;
      }
    });
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({
    required this.coverPhoto,
    required this.profilePhoto,
    required this.farmName,
    required this.onCoverTap,
    required this.onProfileTap,
  });

  final String coverPhoto;
  final String? profilePhoto;
  final String farmName;
  final VoidCallback onCoverTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(coverPhoto, fit: BoxFit.cover),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: FilledButton.tonalIcon(
                      onPressed: onCoverTap,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Cover'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 0,
            child: GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                children: [
                  FarmAvatar(
                    farmName: farmName,
                    radius: 43,
                    borderWidth: 5,
                    photo: profilePhoto,
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 2,
                    child: CircleAvatar(
                      radius: 15,
                      child: Icon(Icons.camera_alt_outlined, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
