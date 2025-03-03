import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Shimmer(
        child: Text('Dashboard'),
        gradient: LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade100]),
      ),
    );
  }
}
