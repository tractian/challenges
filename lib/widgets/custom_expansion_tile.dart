import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isExpanded;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: isExpanded,
      children: children,
    );
  }
}
