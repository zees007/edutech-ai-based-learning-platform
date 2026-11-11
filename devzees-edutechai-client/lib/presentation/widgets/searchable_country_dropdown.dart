import 'package:flutter/material.dart';

import 'package:devzees_edutechai_client/core/constants/country_data.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

/// Premium, in-place anchored searchable dropdown for country selection.
/// Directly anchors beneath (or above) the field without opening a full-screen modal.
class SearchableCountryDropdown extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final bool isDark;
  final String label;
  final bool isEnabled;

  const SearchableCountryDropdown({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.isDark,
    this.label = 'COUNTRY',
    this.isEnabled = true,
  });

  @override
  State<SearchableCountryDropdown> createState() =>
      SearchableCountryDropdownState();
}

class SearchableCountryDropdownState extends State<SearchableCountryDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Country> _filtered = CountryData.allCountries;

  late AnimationController _chevronController;
  late Animation<double> _chevronAnimation;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(CountryData.allCountries);
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _closeDropdown(notify: false);
    _chevronController.dispose();
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Public method allowing external triggers (e.g. mobile dial code chip) to open dropdown
  void toggleDropdown() {
    if (!widget.isEnabled) return;
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    _filtered = List.from(CountryData.allCountries);
    _searchCtrl.clear();
    setState(() => _isOpen = true);
    _chevronController.forward();

    final overlay = Overlay.of(context);
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (triggerOffset.dy + triggerSize.height);
    final openUpwards = spaceBelow < 300 && triggerOffset.dy > 300;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // Full-screen transparent backdrop to dismiss on click outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            // Floating anchored dropdown card
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                openUpwards ? -310 : triggerSize.height + 6,
              ),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    final isDark = widget.isDark;
                    final textPrimary =
                        isDark ? Colors.white : AppColors.textPrimary;
                    final textSecondary = isDark
                        ? AppColors.textSecondary
                        : const Color(0xFF64748B);
                    final bgColor =
                        isDark ? AppColors.surfaceDark : Colors.white;

                    return Container(
                      width: triggerSize.width,
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        minHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.5 : 0.12,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ─── Inline Search Bar ───────────────────────────────
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : const Color(0xFFF8FAFC),
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.primary
                                            .withValues(alpha: 0.3)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchCtrl,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 13,
                                  ),
                                  onChanged: (query) {
                                    setOverlayState(() {
                                      _filterCountries(query);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText:
                                        'Search country or dial code (e.g. US, +1)...',
                                    hintStyle: TextStyle(
                                      color: textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 17,
                                      color: isDark
                                          ? AppColors.primary
                                          : const Color(0xFF64748B),
                                    ),
                                    suffixIcon: _searchCtrl.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear_rounded,
                                              size: 15,
                                            ),
                                            color: textSecondary,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              _searchCtrl.clear();
                                              setOverlayState(() {
                                                _filterCountries('');
                                              });
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                          vertical: 9,
                                        ),
                                  ),
                                ),
                              ),
                            ),

                            // ─── Filtered Countries List ─────────────────────────
                            Flexible(
                              child: _filtered.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Center(
                                        child: Text(
                                          'No country found',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemCount: _filtered.length,
                                      separatorBuilder: (_, _) => Divider(
                                        height: 1,
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.04,
                                              )
                                            : const Color(0xFFF1F5F9),
                                      ),
                                      itemBuilder: (ctx, index) {
                                        final country = _filtered[index];
                                        final isSelected =
                                            widget.selectedCountry.code ==
                                            country.code;

                                        return InkWell(
                                          onTap: () {
                                            widget.onCountryChanged(country);
                                            _closeDropdown();
                                          },
                                          hoverColor: AppColors.primary
                                              .withValues(
                                                alpha: isDark ? 0.15 : 0.08,
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 9,
                                            ),
                                            color: isSelected
                                                ? AppColors.primary
                                                    .withValues(
                                                      alpha: isDark ? 0.2 : 0.1,
                                                    )
                                                : Colors.transparent,
                                            child: Row(
                                              children: [
                                                Text(
                                                  country.flag,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    country.name,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? (isDark
                                                              ? Colors.white
                                                              : AppColors
                                                                  .primary)
                                                          : textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? Colors.white
                                                            .withValues(
                                                              alpha: 0.07,
                                                            )
                                                        : const Color(
                                                            0xFFF1F5F9,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    country.dialCode,
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: isSelected
                                                          ? (isDark
                                                              ? Colors.white
                                                              : AppColors
                                                                  .primary)
                                                          : textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    Icons.check_rounded,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _filterCountries(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      _filtered = List.from(CountryData.allCountries);
    } else {
      _filtered = CountryData.allCountries.where((c) {
        return c.name.toLowerCase().contains(clean) ||
            c.code.toLowerCase().contains(clean) ||
            c.dialCode.contains(clean);
      }).toList();
    }
  }

  void _closeDropdown({bool notify = true}) {
    if (!_isOpen && _overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notify && mounted) {
      setState(() => _isOpen = false);
      _chevronController.reverse();
    } else {
      _isOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label.isNotEmpty) ...[
            Text(
              widget.label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
          ],
          InkWell(
            key: _triggerKey,
            onTap: toggleDropdown,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.75)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOpen
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : const Color(0xFFE2E8F0)),
                  width: _isOpen ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.selectedCountry.flag,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.selectedCountry.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RotationTransition(
                    turns: _chevronAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: _isOpen
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.primary.withValues(alpha: 0.8)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

