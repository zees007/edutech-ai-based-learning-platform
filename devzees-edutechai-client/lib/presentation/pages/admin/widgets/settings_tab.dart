import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/system_setting_model.dart';
import '../../../widgets/shimmer_loading.dart';

enum SettingCategory {
  all('All', Icons.grid_view),
  models('AI Models', Icons.psychology_outlined),
  limits('Limits & Quotas', Icons.speed_outlined),
  pricing('Pricing', Icons.attach_money),
  coupons('Promotions', Icons.local_offer_outlined),
  other('Other', Icons.tune_outlined);

  final String label;
  final IconData icon;
  const SettingCategory(this.label, this.icon);
}

/// System Settings Master-Detail configuration tab.
class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  final _searchController = TextEditingController();
  final _valueController = TextEditingController();
  final _orderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SettingCategory _selectedCategory = SettingCategory.all;
  String? _lastLoadedCode;
  bool _showMobileDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminSettingsProvider.notifier).loadSettings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _valueController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _syncControllers(SystemSettingModel? setting) {
    if (setting == null) return;
    if (_lastLoadedCode != setting.code) {
      _lastLoadedCode = setting.code;
      _valueController.text = setting.value;
      _orderController.text = setting.orderNumber.toString();
    }
  }

  SettingCategory _getCategory(String code) {
    final upper = code.toUpperCase();
    if (upper.contains('MODEL') || upper.contains('LLM')) return SettingCategory.models;
    if (upper.contains('LIMIT')) return SettingCategory.limits;
    if (upper.contains('PRICE') ||
        upper.contains('MONTHLY') ||
        upper.contains('ANNUALLY') ||
        upper.contains('YEARLY')) {
      return SettingCategory.pricing;
    }
    if (upper.contains('COUPON') || upper.contains('PROMO')) return SettingCategory.coupons;
    return SettingCategory.other;
  }

  Color _getCategoryColor(SettingCategory cat) {
    switch (cat) {
      case SettingCategory.models:
        return AppColors.purpleLight;
      case SettingCategory.limits:
        return AppColors.accentCyan;
      case SettingCategory.pricing:
        return AppColors.emerald;
      case SettingCategory.coupons:
        return AppColors.accentPink;
      case SettingCategory.other:
      case SettingCategory.all:
        return AppColors.blueLight;
    }
  }

  String _getSettingDescription(String code) {
    switch (code) {
      case 'ORCHESTRATOR_MODEL':
        return 'LLM model identifier used for core system orchestration and task delegation.';
      case 'SOCRATIC_TUTOR_MODEL':
        return 'LLM model identifier used by the Socratic tutor for guided interactive learning.';
      case 'QUIZ_AGENT_MODEL':
        return 'LLM model identifier used for generating quizzes, questions, and grading assessments.';
      case 'PRIMARY_LLM_MODEL':
        return 'Primary LLM model identifier (e.g. gemini-2.5-flash) used for agent reasoning, Socratic tutoring, and code analysis.';
      case 'FALLBACK_LLM_MODEL':
        return 'Secondary fallback LLM model identifier (e.g. gemini-1.5-flash) used when primary model reaches rate limits or is unavailable.';
      case 'FREE_YOUTUBE_LIMIT':
        return 'Maximum number of YouTube video recommendations allowed per day for Free tier users.';
      case 'PRO_YOUTUBE_LIMIT':
        return 'Maximum number of YouTube video recommendations allowed per day for Pro tier users.';
      case 'ULTRA_YOUTUBE_LIMIT':
        return 'Maximum number of YouTube video recommendations allowed per day for Ultra tier users.';
      case 'FREE_FOLLOWUP_LIMIT':
        return 'Maximum number of Socratic follow-up questions allowed per session for Free tier users.';
      case 'PRO_FOLLOWUP_LIMIT':
        return 'Maximum number of Socratic follow-up questions allowed per session for Pro tier users.';
      case 'YOUTUBE_DAILY_SEARCH_LIMIT':
        return 'Global daily cap for YouTube API queries executed across the entire platform.';
      case 'PRO_MONTHLY':
      case 'PRO_PRICE_MONTHLY':
        return 'Monthly subscription fee in USD for Pro tier membership (e.g. 19).';
      case 'PRO_ANNUALLY':
      case 'PRO_PRICE_YEARLY':
        return 'Annual subscription fee in USD for Pro tier membership (e.g. 180).';
      case 'ULTRA_MONTHLY':
      case 'ULTRA_PRICE_MONTHLY':
        return 'Monthly subscription fee in USD for Ultra tier membership (e.g. 49).';
      case 'ULTRA_ANNUALLY':
      case 'ULTRA_PRICE_YEARLY':
        return 'Annual subscription fee in USD for Ultra tier membership (e.g. 470).';
      case 'VALID_COUPONS':
        return 'JSON string or comma-separated list of active promotional coupon codes (e.g. ["WELCOME50", "STUDENT20"]).';
      default:
        return 'Runtime configuration parameter directly loaded by backend services.';
    }
  }

  List<SystemSettingModel> _filterItems(List<SystemSettingModel> items, String query) {
    var list = items;
    if (_selectedCategory != SettingCategory.all) {
      list = list.where((item) => _getCategory(item.code) == _selectedCategory).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((item) {
        return item.code.toLowerCase().contains(q) ||
            item.value.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSettingsProvider);
    final isMobile = Responsive.isMobile(context);

    // Keep form controllers in sync with current selected setting
    _syncControllers(state.selectedSetting);

    // Listen for success/error messages
    ref.listen<AdminSettingsState>(adminSettingsProvider, (prev, next) {
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(next.successMessage!)),
              ],
            ),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(next.error!)),
              ],
            ),
            backgroundColor: AppColors.accentRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    final filteredList = _filterItems(state.items, state.searchQuery);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(state),
          const SizedBox(height: 24),

          // Content body
          if (state.isLoading && state.items.isEmpty)
            const ShimmerLoading(child: ShimmerBox(height: 400))
          else if (state.error != null && state.items.isEmpty)
            _buildErrorState(state.error!)
          else if (isMobile)
            _buildMobileLayout(state, filteredList)
          else
            _buildDesktopLayout(state, filteredList),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminSettingsState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Settings & Parameters',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Configure platform runtime parameters, AI LLM models, tier limits, pricing, and promotional coupons.',
                style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'Refresh Settings',
          onPressed: state.isLoading
              ? null
              : () => ref.read(adminSettingsProvider.notifier).loadSettings(),
          icon: state.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.refresh, color: AppColors.textSecondary),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.glassBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.glassBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRose.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.accentRose, size: 48),
          const SizedBox(height: 12),
          Text('Failed to load system settings', style: AppTextStyles.subtitle1),
          const SizedBox(height: 6),
          Text(error, style: AppTextStyles.body2.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(adminSettingsProvider.notifier).loadSettings(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentViolet,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AdminSettingsState state, List<SystemSettingModel> filteredList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Master Settings List
        Expanded(
          flex: 5,
          child: _buildMasterList(state, filteredList),
        ),
        const SizedBox(width: 24),
        // Right Column: Detail / Edit Form
        Expanded(
          flex: 6,
          child: _buildDetailForm(state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AdminSettingsState state, List<SystemSettingModel> filteredList) {
    if (_showMobileDetail && state.selectedSetting != null) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showMobileDetail = false),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Settings List'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accentViolet),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailForm(state),
        ],
      );
    }
    return _buildMasterList(state, filteredList, isMobile: true);
  }

  Widget _buildMasterList(
    AdminSettingsState state,
    List<SystemSettingModel> filteredList, {
    bool isMobile = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Count Bar
          Row(
            children: [
              Text(
                'Configurations',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentViolet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentViolet.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${state.items.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentViolet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.glassBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(adminSettingsProvider.notifier).updateSearch(val);
              },
              style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search setting by code or value...',
                hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textMuted, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(adminSettingsProvider.notifier).updateSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SettingCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                    },
                    avatar: Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    backgroundColor: AppColors.glassBase,
                    selectedColor: AppColors.accentViolet,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.accentViolet : AppColors.glassBorder,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // List of settings
          if (filteredList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off, color: AppColors.textMuted, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'No settings match your filter',
                    style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isSelected = state.selectedSetting?.code == item.code;
                final cat = _getCategory(item.code);
                final catColor = _getCategoryColor(cat);

                return InkWell(
                  onTap: () {
                    ref.read(adminSettingsProvider.notifier).selectSetting(item);
                    _lastLoadedCode = item.code;
                    _valueController.text = item.value;
                    _orderController.text = item.orderNumber.toString();
                    if (isMobile) {
                      setState(() => _showMobileDetail = true);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentViolet.withValues(alpha: 0.12)
                          : AppColors.glassBase,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentViolet
                            : AppColors.glassBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Order number chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.trackNeutral,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${item.orderNumber}',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Code
                            Expanded(
                              child: Text(
                                item.code,
                                style: AppTextStyles.subtitle2.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.accentViolet
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: catColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon, size: 11, color: catColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    cat.label,
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: catColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Truncated value preview
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDeep.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.glassBorder.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            item.value,
                            style: AppTextStyles.caption.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailForm(AdminSettingsState state) {
    final setting = state.selectedSetting;
    if (setting == null) {
      return Container(
        height: 350,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Select a Setting to Edit',
              style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose any configuration item on the left to edit its value directly.',
              style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final cat = _getCategory(setting.code);
    final catColor = _getCategoryColor(cat);
    final description = _getSettingDescription(setting.code);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Header: Code & Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: catColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 14, color: catColor),
                                const SizedBox(width: 6),
                                Text(
                                  cat.label,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: catColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.trackNeutral,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Order #${setting.orderNumber}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        setting.code,
                        style: AppTextStyles.h4.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy Setting Code',
                  icon: const Icon(Icons.copy, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: setting.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Copied '${setting.code}' to clipboard"),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description Helper Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.glassBase,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.accentViolet),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Value Input (Plain string field, no dropdowns)
            Text(
              'Configuration Value (String)',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Direct string value. For LLMs, enter the exact model name. For limits, enter an integer. For pricing, enter a decimal amount.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.glassBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextFormField(
                controller: _valueController,
                maxLines: setting.code.contains('COUPON') ? 5 : 2,
                minLines: 1,
                style: AppTextStyles.body2.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Setting value cannot be empty';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  hintText: 'Enter setting value...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Order Number Input
            Text(
              'Display Order Number',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sorting index used when listing settings in UI and queries.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.glassBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(val) == null) {
                    return 'Must be an integer';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: '10',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Timestamps Metadata
            Row(
              children: [
                Icon(Icons.history, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Created: ${_formatDateTime(setting.createdAt)}   •   Last Updated: ${_formatDateTime(setting.updatedAt)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: state.isSaving
                      ? null
                      : () {
                          _valueController.text = setting.value;
                          _orderController.text = setting.orderNumber.toString();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: state.isSaving ? null : () => _submitUpdate(setting),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpdate(SystemSettingModel current) async {
    if (!_formKey.currentState!.validate()) return;

    final newValue = _valueController.text.trim();
    final newOrder = int.tryParse(_orderController.text.trim()) ?? current.orderNumber;

    await ref.read(adminSettingsProvider.notifier).updateSetting(
          current.code,
          newValue,
          newOrder,
        );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} ${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
