import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ShippingMethodSelector extends StatelessWidget {
  final String headerTitle;

  /// required keys:
  /// - id, title, eta, price
  /// optional:
  /// - note (النص اللي يتغير تحت حسب الاختيار)
  final List<Map<String, dynamic>> options;

  final String? selectedId;
  final ValueChanged<String> onChanged;

  const ShippingMethodSelector({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  Map<String, dynamic>? _findSelected() {
    if (selectedId == null) return null;
    for (final o in options) {
      if ((o['id'] as String?) == selectedId) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    // ✅ الرسالة تتبع المحدد
    final selected = _findSelected();
    final note = (selected?['note'] as String?)?.trim() ?? '';

    // ✅ لو ما فيه note نخلي مكان ثابت (عشان ما يهتز التصميم)
    final displayNote = note.isNotEmpty ? note : ' '; // مساحة فقط

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerTitle,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(context.isDark ? .10 : .06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              /// ✅ الخيارين داخل نفس البطاقة
              for (int i = 0; i < options.length && i < 2; i++) ...[
                _ShippingTile(
                  data: options[i],
                  selected: (options[i]['id'] as String?) == selectedId,
                  onTap: () {
                    final id = options[i]['id'] as String?;
                    if (id != null) onChanged(id);
                  },
                ),
                if (i != 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.border.withOpacity(.25),
                  ),
              ],

              /// ✅ قسم الرسالة ثابت داخل نفس البطاقة (يتغير حسب الاختيار)
              Divider(
                height: 1,
                thickness: 1,
                color: context.border.withOpacity(.25),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(44, 8, 12, 10),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Text(
                      displayNote,
                      key: ValueKey(displayNote), // ✅ يبدّل عند تغيّر النص
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShippingTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool selected;
  final VoidCallback onTap;

  const _ShippingTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '') as String;
    final eta = (data['eta'] ?? '') as String;
    final price = (data['price'] ?? '') as String;

    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 360;

        final bg = selected
            ? context.primary.withOpacity(context.isDark ? .14 : .10)
            : Colors.transparent;

        final pad = EdgeInsetsDirectional.fromSTEB(
          compact ? 12 : 14,
          compact ? 10 : 12,
          compact ? 12 : 14,
          compact ? 10 : 12,
        );

        return InkWell(
          onTap: onTap,
          child: Container(
            color: bg,
            padding: pad,
            child: Row(
              children: [
                _RadioLike(selected: selected, size: compact ? 20 : 22),
                const SizedBox(width: 10),

                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 13.5 : 14,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _EtaPill(text: eta, compact: compact),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  price,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 13.5 : 14,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EtaPill extends StatelessWidget {
  final String text;
  final bool compact;

  const _EtaPill({required this.text, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.primary.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.w900,
          fontSize: compact ? 10.5 : 11,
          height: 1.0,
        ),
      ),
    );
  }
}

class _RadioLike extends StatelessWidget {
  final bool selected;
  final double size;

  const _RadioLike({required this.selected, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.primary : context.border.withOpacity(.55),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? size * .52 : 0,
          height: selected ? size * .52 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.primary,
          ),
        ),
      ),
    );
  }
}