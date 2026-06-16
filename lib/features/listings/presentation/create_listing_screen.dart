import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/forms/app_validators.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/device_image_picker.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../catalog/domain/catalog_suggestion.dart';
import '../domain/listing_draft.dart';
import '../domain/product_detail_labels.dart';
import 'listing_controller.dart';
import 'listing_form_components.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalogController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmingMethodController = TextEditingController();
  final _storageController = TextEditingController();

  CatalogSuggestion? _selectedSuggestion;
  List<CatalogSuggestion> _suggestions = [];
  String _unit = 'kg';
  String? _photo;
  DateTime? _harvestDate;
  DateTime? _bestBeforeDate;

  @override
  void dispose() {
    _catalogController.dispose();
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
    final detailLabels = productDetailLabels(
      _selectedSuggestion?.product?.categoryId ?? '',
    );

    if (!authState.canAccessFarmerMode) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.createListingTitle)),
        body: ErrorState(
          title: l10n.unauthorizedTitle,
          message: l10n.verifiedFarmerRequiredMessage,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createListingTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListingSectionTitle(
                l10n.productSectionTitle,
                description: l10n.productSectionDescription,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _catalogController,
                decoration: InputDecoration(labelText: l10n.whatAreYouSelling),
                onChanged: _searchCatalog,
              ),
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._suggestions.map(
                  (suggestion) => ListTile(
                    title: Text(suggestion.displayName),
                    leading: const Icon(Icons.eco_outlined),
                    onTap: () {
                      setState(() {
                        _selectedSuggestion = suggestion;
                        _catalogController.text = suggestion.displayName;
                        _suggestions = [];
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ListingSectionTitle(
                l10n.stockAndPriceTitle,
                description: l10n.stockAndPriceDescription,
              ),
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
              _PhotoPicker(
                photo: _photo,
                label: l10n.listingPhotoPlaceholderLabel,
                onTap: _pickPhoto,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.addProductButton,
                icon: Icons.add_rounded,
                isLoading: listingState.isSaving,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final draft = _buildDraft();
                  if (!draft.canSave) {
                    return;
                  }
                  await ref
                      .read(listingControllerProvider.notifier)
                      .createListing(draft);
                  if (context.mounted) {
                    context.go(AppRoutes.farmerDashboard);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.productAddedMessage)),
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

  Future<void> _searchCatalog(String query) async {
    final locale = Localizations.localeOf(context).languageCode;
    final repository = ref.read(catalogRepositoryProvider);
    final suggestions = await repository.searchSuggestions(
      query: query,
      locale: locale,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedSuggestion = null;
      _suggestions = suggestions
          .where(
            (suggestion) =>
                suggestion.product != null || suggestion.variant != null,
          )
          .toList();
    });
  }

  ListingDraft _buildDraft() {
    final initial = ref.read(listingControllerProvider.notifier).initialDraft();
    return ListingDraft(
      catalogSuggestion: _selectedSuggestion,
      quantity: double.tryParse(_quantityController.text),
      unit: _unit,
      price: double.tryParse(_priceController.text),
      latitude: initial.latitude,
      longitude: initial.longitude,
      description: _descriptionController.text,
      photoPlaceholder: _photo,
      harvestDate: _harvestDate,
      farmingMethod: _farmingMethodController.text,
      bestBeforeDate: _bestBeforeDate,
      storageInstructions: _storageController.text,
    );
  }

  Future<void> _pickPhoto() async {
    final image = await pickDeviceImage();
    if (image != null && mounted) setState(() => _photo = image);
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.label,
    required this.onTap,
  });

  final String? photo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: photo == null
            ? Center(
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
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(photo!, fit: BoxFit.cover),
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
    );
  }
}
