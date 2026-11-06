import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';

class RecentCalendarSheet extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onPick;

  const RecentCalendarSheet({
    super.key,
    required this.initialDate,
    required this.onPick,
  });

  @override
  State<RecentCalendarSheet> createState() => _RecentCalendarSheetState();
}

class _RecentCalendarSheetState extends State<RecentCalendarSheet> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < 360;
    final isDark = context.isDark;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF24111F) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.25)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month header
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1, 1);
                    }),
                    isDark: isDark,
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark ? BrandColors.gold : BrandColors.burgundy)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          AppDateUtils.monthName(_month.month),
                          style: TextStyle(
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ),
                  _CircleBtn(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1, 1);
                    }),
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _CalendarGrid(
                month: _month,
                selected: _selected,
                onSelect: (d) => setState(() => _selected = d),
                compact: isCompact,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          widget.onPick(_selected!);
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? BrandColors.gold
                        : BrandColors.burgundy,
                    foregroundColor: isDark
                        ? const Color(0xFF1E0A17)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    Tk.wishlistFilterChooseDate.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final bool compact;
  final bool isDark;

  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.compact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final startWeekday = (firstDay.weekday);
    final totalCells = ((startWeekday - 1) + daysInMonth);
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.20)
            : const Color(0xFFF7F1F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : BrandColors.burgundy.withValues(alpha: 0.08),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cellCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (_, i) {
          final dayNum = i - (startWeekday - 1) + 1;
          final inMonth = dayNum >= 1 && dayNum <= daysInMonth;

          if (!inMonth) return const SizedBox();

          final d = DateTime(month.year, month.month, dayNum);
          final isSelected =
              selected != null &&
              selected!.year == d.year &&
              selected!.month == d.month &&
              selected!.day == d.day;

          return InkWell(
            onTap: () => onSelect(d),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                    : (isDark ? const Color(0xFF2E1728) : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : BrandColors.burgundy.withValues(alpha: 0.08)),
                ),
              ),
              child: Center(
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? const Color(0xFF1E0A17) : Colors.white)
                        : (isDark ? Colors.white : const Color(0xFF1E0A17)),
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 11.5 : 12.5,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2E1728) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : BrandColors.burgundy.withValues(alpha: 0.10),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF1E0A17),
        ),
      ),
    );
  }
}
