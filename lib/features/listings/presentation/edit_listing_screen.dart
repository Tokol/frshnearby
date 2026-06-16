import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/forms/app_validators.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/device_image_picker.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/listing.dart';
import '../domain/product_detail_labels.dart';
import 'listing_controller.dart';
import 'listing_form_components.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmingMethodController = TextEditingController();
  final _storageController = TextEditingController();

  bool _initialized = false;
  String _unit = 'kg';
  String? _photo;
  DateTime? _harvestDate;
  DateTime? _bestBeforeDate;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _farmingMethodController.dispose();
    _storageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listingState = ref.watch(listingControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profile = authState.user?.farmerProfile;
    final listing = ref
        .read(listingControllerProvider.notifier)
        .listingById(widget.listingId);

    if (!authState.canAccessFarmerMode) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editListingTitle)),
        body: ErrorState(
          title: l10n.unauthorizedTitle,
          message: l10n.verifiedFarmerRequiredMessage,
        ),
      );
    }

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editListingTitle)),
        body: ErrorState(
          title: l10n.genericErrorTitle,
          message: l10n.listingNotFoundMessage,
        ),
      );
    }

    _initialize(listing);
    final detailLabels = productDetailLabels(listing.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editListingTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.updateChangedFieldsHint,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ListingSectionTitle(l10n.stockAndPriceTitle),
              const SizedBox(height: 12),
              SellingUnitField(
                value: _unit,
                onChanged: (unit) => setState(() => _unit = unit),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => AppValidators.positiveNumber(l10n, value),
                decoration: InputDecoration(
                  labelText: l10n.availableNowLabel,
                  suffixText: _unit,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 12),
              PricePerUnitField(
                controller: _priceController,
                unit: _unit,
                validator: (value) => AppValidators.positiveNumber(l10n, value),
              ),
              const SizedBox(height: 24),
              ListingSectionTitle(
                l10n.productDetailsTitle,
                description: l10n.productDetailsDescription,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.listingDescriptionLabel,
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              HarvestDateField(
                value: _harvestDate,
                label: l10n.producedDateOptionalLabel,
                onChanged: (value) => setState(() => _harvestDate = value),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.productionDetailsLabel,
                controller: _farmingMethodController,
              ),
              if (detailLabels.showBestBefore) ...[
                const SizedBox(height: 16),
                HarvestDateField(
                  value: _bestBeforeDate,
                  label: l10n.bestBeforeOptionalLabel,
                  onChanged: (value) => setState(() => _bestBeforeDate = value),
                ),
              ],
              if (detailLabels.showStorage) ...[
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.storageInstructionsOptionalLabel,
                  controller: _storageController,
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _photo == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_a_photo_outlined),
                              const SizedBox(height: 8),
                              Text(l10n.addProductPhotoLabel),
                            ],
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(_photo!, fit: BoxFit.cover),
                            const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircleAvatar(
                                  child: Icon(Icons.photo_camera_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.saveChangesButton,
                icon: Icons.save_outlined,
                isLoading: listingState.isSaving,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final updatedListing = listing.copyWith(
                    quantity: double.tryParse(_quantityController.text),
                    unit: _unit,
                    price: double.tryParse(_priceController.text),
                    description: _descriptionController.text,
                    farmingMethod: _farmingMethodController.text,
                    photoPlaceholder: _photo,
                    harvestDate: _harvestDate,
                    clearHarvestDate: _harvestDate == null,
                    bestBeforeDate: _bestBeforeDate,
                    clearBestBeforeDate: _bestBeforeDate == null,
                    storageInstructions: _storageController.text,
                  );
                  await ref
                      .read(listingControllerProvider.notifier)
                      .updateListing(updatedListing);
                  if (context.mounted) {
                    context.go(AppRoutes.farmerDashboard);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.productUpdatedMessage)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initialize(Listing listing) {
    if (_initialized) {
      return;
    }
    _quantityController.text = listing.quantity.toString();
    _unit = listing.unit;
    _priceController.text = listing.price.toStringAsFixed(2);
    _descriptionController.text = listing.description;
    _farmingMethodController.text = listing.farmingMethod ?? '';
    _photo = listing.photoPlaceholder;
    _harvestDate = listing.harvestDate;
    _bestBeforeDate = listing.bestBeforeDate;
    _storageController.text = listing.storageInstructions ?? '';
    _initialized = true;
  }

  Future<void> _pickPhoto() async {
    final image = await pickDeviceImage();
    if (image != null && mounted) setState(() => _photo = image);
  }
}
