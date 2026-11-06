import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class ShippingMethodSelector extends StatelessWidget {
  final String? titleText;
  final String? headerTitle;
  final String selectedId;
  final List<Map<String, dynamic>> options;
  final ValueChanged<String> onChanged;

  const ShippingMethodSelector({
    super.key,
    this.titleText,
    this.headerTitle,
    required this.selectedId,
    required this.options,
    required this.onChanged,
  });

  String get effectiveTitle => headerTitle ?? titleText ?? '';

  Map<String, dynamic>? get _selectedOption {
    for (final op in options) {
      if ((op['id'] as String?) == selectedId) return op;
    }
    return options.isNotEmpty ? options.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final note = (_selectedOption?['note'] ?? '') as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effectiveTitle.isNotEmpty) ...[
          Text(
            effectiveTitle,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 10),
        ],

        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withValues(
                  alpha: context.isDark ? .10 : .06,
                ),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
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
                    color: context.border.withValues(alpha: .25),
                  ),
              ],

              Divider(
                height: 1,
                thickness: 1,
                color: context.border.withValues(alpha: .25),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(44, 8, 12, 10),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    note,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      height: 1.15,
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
            ? context.primary.withValues(alpha: context.isDark ? .14 : .10)
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
                            fontFamily: 'Cairo',
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
                    fontFamily: 'Cairo',
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
        color: context.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.primary.withValues(alpha: .22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.w900,
          fontSize: compact ? 10.5 : 11,
          fontFamily: 'Cairo',
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
          color: selected
              ? context.primary
              : context.border.withValues(alpha: .55),
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
