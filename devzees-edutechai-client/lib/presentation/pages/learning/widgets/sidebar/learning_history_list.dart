import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/shimmer_loading.dart';
import 'learning_history_item.dart';
import 'learning_history_skeleton.dart';

class LearningHistoryList extends ConsumerWidget {
  final ScrollController scrollController;
  final bool expanded;

  const LearningHistoryList({
    super.key,
    required this.scrollController,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionsProvider);

    if (state.isLoading) {
      return ShimmerLoading(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            LearningHistorySkeletonItem(expanded: expanded, titleWidth: 120),
            LearningHistorySkeletonItem(expanded: expanded, titleWidth: 95),
            LearningHistorySkeletonItem(expanded: expanded, titleWidth: 140),
            LearningHistorySkeletonItem(expanded: expanded, titleWidth: 110),
            LearningHistorySkeletonItem(expanded: expanded, titleWidth: 85),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No sessions match. Start a new topic!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return AppColors.primary;
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primary.withValues(alpha: 0.85);
          }
          return AppColors.primary.withValues(alpha: 0.4);
        }),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.dragged)) {
            return 6.0;
          }
          return 4.0;
        }),
        crossAxisMargin: 2.0,
        mainAxisMargin: 4.0,
      ),
      child: Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: state.items.length + (state.isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }
            return LearningHistoryItem(
              session: state.items[index],
              index: index,
              expanded: expanded,
            );
          },
        ),
      ),
    );
  }
}
