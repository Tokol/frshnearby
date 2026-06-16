import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class PlaceholderTabScreen extends StatelessWidget {
  const PlaceholderTabScreen({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(title: title, message: message, icon: icon),
    );
  }
}
