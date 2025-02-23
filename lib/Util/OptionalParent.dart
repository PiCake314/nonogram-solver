import 'package:flutter/material.dart';



class OptionalParent extends StatelessWidget {
  final bool include_parent;
  final Widget child;
  final Widget Function(Widget) parent;

  const OptionalParent({
    super.key,
    required this.include_parent,
    required this.child,
    required this.parent,
  });

  @override
  Widget build(BuildContext context) => include_parent ? parent(child) : child;
}