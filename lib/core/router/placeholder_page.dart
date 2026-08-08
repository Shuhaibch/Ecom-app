import 'package:flutter/material.dart';

/// Temporary body shown for a shell-branch root until its feature is
/// implemented. Rendered inside [AppShell]'s Scaffold, so it has no
/// AppBar of its own.
class PlaceholderBody extends StatelessWidget {
  final String title;

  const PlaceholderBody({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title — coming soon',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

/// Temporary full page (with its own AppBar) shown for routes pushed on
/// the root navigator, e.g. product details, until implemented.
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PlaceholderBody(title: title),
    );
  }
}
