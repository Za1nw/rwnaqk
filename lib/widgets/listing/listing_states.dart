import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
import 'package:rwnaqk/widgets/common/app_error_state.dart';

class ListingSkeletonSliver extends StatelessWidget {
  const ListingSkeletonSliver({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item() {
      return Container(
        height: 210,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.border.withOpacity(0.35),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: item()),
                const SizedBox(width: 12),
                Expanded(child: item()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: item()),
                const SizedBox(width: 12),
                Expanded(child: item()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListingEmptySliver extends StatelessWidget {
  final VoidCallback onRefresh;

  const ListingEmptySliver({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const AppEmptyState(
              title: 'No products found',
              subtitle: 'Try adjusting the filters or refresh the page.',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onRefresh,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.primary,
                  foregroundColor: context.primaryForeground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListingErrorSliver extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ListingErrorSliver({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppErrorState(
        title: message,
        subtitle: 'Please try again.',
        buttonText: 'Retry',
        onRetry: onRetry,
        expanded: false,
      ),
    );
  }
}