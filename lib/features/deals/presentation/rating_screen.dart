import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import 'deal_controller.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({required this.dealId, super.key});

  final String dealId;

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  final _textController = TextEditingController();
  int _stars = 5;
  final Set<String> _tags = {};

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tags = [
      l10n.ratingTagFresh,
      l10n.ratingTagFriendly,
      l10n.ratingTagOnTime,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rateDealTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.ratingSoftPromptMessage),
          const SizedBox(height: 6),
          Text(
            l10n.reviewOptionalHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  icon: Icon(i <= _stars ? Icons.star : Icons.star_border),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final tag in tags)
                FilterChip(
                  label: Text(tag),
                  selected: _tags.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.ratingTextLabel),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: l10n.submitRatingButton,
            icon: Icons.star,
            onPressed: () async {
              await ref
                  .read(dealControllerProvider.notifier)
                  .submitRating(
                    dealId: widget.dealId,
                    stars: _stars,
                    tags: _tags.toList(),
                    text: _textController.text,
                  );
              if (context.mounted) {
                context.go(AppRoutes.customerDeals);
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRoutes.customerDeals),
            child: Text(l10n.notNowLabel),
          ),
        ],
      ),
    );
  }
}
