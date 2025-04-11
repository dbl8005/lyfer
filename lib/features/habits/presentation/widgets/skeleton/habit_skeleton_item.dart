import 'package:flutter/material.dart';
import 'package:lyfer/core/shared/widgets/custom_card.dart';
import 'package:lyfer/core/shared/widgets/shimmer_loading.dart';

class HabitSkeletonItem extends StatelessWidget {
  const HabitSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: CustomCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
