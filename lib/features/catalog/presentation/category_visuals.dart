import 'package:flutter/material.dart';

/// Single source of truth for how a product category is presented across the
/// app (home strip, map filter chips, …).
///
/// Today the glyph is an emoji placeholder. When fixed image assets are ready,
/// fill in [assetPath] here and every call site upgrades automatically — no
/// other file needs to change.
class CategoryVisual {
  const CategoryVisual({
    required this.emoji,
    required this.tileColor,
    required this.glyphBackground,
    this.assetPath,
  });

  /// Emoji placeholder used until a fixed asset is supplied.
  final String emoji;

  /// Optional fixed image asset. When set it is preferred over [emoji].
  final String? assetPath;

  /// Large tile background (home category strip).
  final Color tileColor;

  /// Circle background behind the glyph (home category strip).
  final Color glyphBackground;
}

const _fallback = CategoryVisual(
  emoji: '🧺',
  tileColor: Color(0xFFEDEDED),
  glyphBackground: Color(0xFFF6F6F6),
);

const _visuals = <String, CategoryVisual>{
  'category-meat': CategoryVisual(
    emoji: '🥩',
    tileColor: Color(0xFFFFE0D6),
    glyphBackground: Color(0xFFFFF4EE),
  ),
  'category-fish': CategoryVisual(
    emoji: '🐟',
    tileColor: Color(0xFFD9F1FF),
    glyphBackground: Color(0xFFF1FBFF),
  ),
  'category-bakery': CategoryVisual(
    emoji: '🥖',
    tileColor: Color(0xFFFFE8B7),
    glyphBackground: Color(0xFFFFF7E3),
  ),
  'category-vegetables': CategoryVisual(
    emoji: '🥦',
    tileColor: Color(0xFFDFF4D7),
    glyphBackground: Color(0xFFF1FBEA),
  ),
  'category-fruits': CategoryVisual(
    emoji: '🍎',
    tileColor: Color(0xFFFFE2A8),
    glyphBackground: Color(0xFFFFF3D8),
  ),
  'category-dairy': CategoryVisual(
    emoji: '🧈',
    tileColor: Color(0xFFE5E9FF),
    glyphBackground: Color(0xFFF6F7FF),
  ),
  'category-eggs': CategoryVisual(
    emoji: '🥚',
    tileColor: Color(0xFFFFF1C8),
    glyphBackground: Color(0xFFFFF9E8),
  ),
  'category-honey': CategoryVisual(
    emoji: '🍯',
    tileColor: Color(0xFFFFE3A3),
    glyphBackground: Color(0xFFFFF2CC),
  ),
  'category-cheese': CategoryVisual(
    emoji: '🧀',
    tileColor: Color(0xFFFFF0A8),
    glyphBackground: Color(0xFFFFF8CF),
  ),
  'category-milk': CategoryVisual(
    emoji: '🥛',
    tileColor: Color(0xFFEAF4FF),
    glyphBackground: Color(0xFFF7FBFF),
  ),
  'category-herbs': CategoryVisual(
    emoji: '🌿',
    tileColor: Color(0xFFDDF6DF),
    glyphBackground: Color(0xFFF0FFF2),
  ),
  'category-mushrooms': CategoryVisual(
    emoji: '🍄',
    tileColor: Color(0xFFE8DED5),
    glyphBackground: Color(0xFFF5EFE8),
  ),
  'category-berries': CategoryVisual(
    emoji: '🫐',
    tileColor: Color(0xFFF4D8EA),
    glyphBackground: Color(0xFFFFEFF7),
  ),
  'category-flowers': CategoryVisual(
    emoji: '💐',
    tileColor: Color(0xFFFFE0EF),
    glyphBackground: Color(0xFFFFF1F8),
  ),
  'category-drinks': CategoryVisual(
    emoji: '🧃',
    tileColor: Color(0xFFFFDDB5),
    glyphBackground: Color(0xFFFFF0DF),
  ),
  'category-preserves': CategoryVisual(
    emoji: '🫙',
    tileColor: Color(0xFFE4F0E8),
    glyphBackground: Color(0xFFF2FAF4),
  ),
  'category-grains': CategoryVisual(
    emoji: '🌾',
    tileColor: Color(0xFFFFEBC7),
    glyphBackground: Color(0xFFFFF8EA),
  ),
  'category-prepared-food': CategoryVisual(
    emoji: '🍲',
    tileColor: Color(0xFFE7E1FF),
    glyphBackground: Color(0xFFF6F2FF),
  ),
  'category-organic': CategoryVisual(
    emoji: '🌱',
    tileColor: Color(0xFFD8F3C8),
    glyphBackground: Color(0xFFF1FFE9),
  ),
};

/// Presentation for [categoryId], falling back to a neutral basket when unknown.
CategoryVisual categoryVisual(String categoryId) =>
    _visuals[categoryId] ?? _fallback;

/// Renders a category glyph: the fixed asset when available, otherwise the
/// emoji placeholder. Centralising this keeps the emoji→asset swap to one file.
class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph({required this.categoryId, this.size = 24, super.key});

  final String categoryId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(categoryId);
    final asset = visual.assetPath;
    if (asset != null) {
      return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
    }
    return Text(
      visual.emoji,
      style: TextStyle(fontSize: size * 0.92, height: 1, letterSpacing: 0),
    );
  }
}
