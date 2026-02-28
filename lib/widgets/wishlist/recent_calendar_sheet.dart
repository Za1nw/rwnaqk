import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

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

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.border.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(context.isDark ? 0.18 : 0.10),
                blurRadius: 24,
                offset: const Offset(0, -6),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month header
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1, 1);
                    }),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: context.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _monthName(_month.month),
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _CircleBtn(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1, 1);
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _CalendarGrid(
                month: _month,
                selected: _selected,
                onSelect: (d) => setState(() => _selected = d),
                compact: isCompact,
              ),

              const SizedBox(height: 12),

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
                    backgroundColor: context.primary,
                    foregroundColor: context.primaryForeground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Choose date'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final bool compact;

  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Monday-based layout (1..7)
    final startWeekday = (firstDay.weekday); // Mon=1
    final totalCells = ((startWeekday - 1) + daysInMonth);
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.background.withOpacity(context.isDark ? 0.18 : 0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withOpacity(0.25)),
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
          final isSelected = selected != null &&
              selected!.year == d.year &&
              selected!.month == d.month &&
              selected!.day == d.day;

          return InkWell(
            onTap: () => onSelect(d),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: isSelected ? context.primary : context.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? context.primary : context.border.withOpacity(0.25),
                ),
              ),
              child: Center(
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    color: isSelected ? context.primaryForeground : context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 11.5 : 12.5,
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

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.border.withOpacity(0.35)),
        ),
        child: Icon(icon, size: 16, color: context.foreground),
      ),
    );
  }
}