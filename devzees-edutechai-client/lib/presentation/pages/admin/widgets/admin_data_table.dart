import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// Reusable glassmorphic data table with dark theme styling.
/// Supports column headers, horizontal scrolling with scrollbar, and row builders for flexible content.
class AdminDataTable extends StatefulWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final List<double>? columnWidths;
  final double? minWidth;

  // Sorting
  final String? sortBy;
  final bool? isDesc;
  final void Function(String column)? onSort;

  // Pagination
  final int? currentPage;
  final int? totalPages;
  final void Function(int newPage)? onPageChanged;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidths,
    this.minWidth,
    this.sortBy,
    this.isDesc,
    this.onSort,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
  });

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double minTableWidth = widget.minWidth ??
                      (widget.columns.length * 110.0).clamp(600.0, 1000.0);
                  final bool needsScroll = constraints.maxWidth < minTableWidth;
                  final double tableWidth =
                      needsScroll ? minTableWidth : constraints.maxWidth;

                  Widget content = SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // Header Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDeep.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: List.generate(widget.columns.length, (i) {
                              final colName = widget.columns[i];
                              final isSorted = widget.sortBy?.toLowerCase() ==
                                  colName.toLowerCase();

                              Widget headerContent = Text(
                                colName,
                                style: AppTextStyles.captionBold.copyWith(
                                  color: AppColors.purple,
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );

                              if (widget.onSort != null) {
                                headerContent = Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: headerContent),
                                    if (isSorted)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4.0),
                                        child: Icon(
                                          widget.isDesc == true
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          size: 14,
                                          color: AppColors.purple,
                                        ),
                                      ),
                                  ],
                                );

                                headerContent = MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => widget.onSort!(colName),
                                    child: headerContent,
                                  ),
                                );
                              }

                              return Expanded(
                                flex: widget.columnWidths != null
                                    ? (widget.columnWidths![i] * 10).round()
                                    : 1,
                                child: headerContent,
                              );
                            }),
                          ),
                        ),
                        // Data Rows
                        if (widget.rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No data available',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        else
                          ...List.generate(widget.rows.length, (rowIdx) {
                            return _DataRow(
                              cells: widget.rows[rowIdx],
                              isEven: rowIdx % 2 == 0,
                              columnWidths: widget.columnWidths,
                            );
                          }),
                      ],
                    ),
                  );

                  if (needsScroll) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 10,
                            bottom: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swipe_rounded,
                                size: 13,
                                color: AppColors.textMuted.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Swipe horizontally for all columns',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: false,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: content,
                          ),
                        ),
                      ],
                    );
                  }
                  return content;
                },
              ),

              // Pagination Footer
              if (widget.onPageChanged != null &&
                  widget.currentPage != null &&
                  widget.totalPages != null &&
                  widget.totalPages! > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.glassBorder.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Page ${widget.currentPage! + 1} of ${widget.totalPages}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        color: widget.currentPage! > 0
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        onPressed: widget.currentPage! > 0
                            ? () => widget.onPageChanged!(widget.currentPage! - 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        color: widget.currentPage! < widget.totalPages! - 1
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        onPressed: widget.currentPage! < widget.totalPages! - 1
                            ? () => widget.onPageChanged!(widget.currentPage! + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatefulWidget {
  final List<Widget> cells;
  final bool isEven;
  final List<double>? columnWidths;

  const _DataRow({
    required this.cells,
    required this.isEven,
    this.columnWidths,
  });

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.purple.withValues(alpha: 0.06)
              : widget.isEven
                  ? Colors.transparent
                  : AppColors.surfaceDark.withValues(alpha: 0.3),
          border: Border(
            bottom: BorderSide(
              color: AppColors.glassBorder.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: List.generate(widget.cells.length, (i) {
            return Expanded(
              flex: widget.columnWidths != null
                  ? (widget.columnWidths![i] * 10).round()
                  : 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: widget.cells[i],
              ),
            );
          }),
        ),
      ),
    );
  }
}
