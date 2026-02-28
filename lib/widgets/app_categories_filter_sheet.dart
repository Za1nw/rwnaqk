import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppCategoriesFilterSheet extends StatefulWidget {
  const AppCategoriesFilterSheet({super.key});

  @override
  State<AppCategoriesFilterSheet> createState() => _AppCategoriesFilterSheetState();
}

class _AppCategoriesFilterSheetState extends State<AppCategoriesFilterSheet> {
  // ===== State (UI only) =====
  int selectedGender = 1; // 0: All, 1: Female, 2: Male
  final expandedIndices = <int>{0}; // Clothing expanded by default
  final selectedSubs = <String>{};

  final categories = [
    _CatData(
      name: 'Clothing',
      image: 'https://picsum.photos/120?1',
      subs: ['Dresses', 'Pants', 'Skirts', 'Shorts', 'Jackets', 'Hoodies', 'Shirts', 'Polo', 'T-Shirts', 'Tunics'],
    ),
    _CatData(name: 'Shoes', image: 'https://picsum.photos/120?2', subs: ['Sneakers', 'Boots']),
    _CatData(name: 'Bags', image: 'https://picsum.photos/120?3', subs: ['Handbags', 'Backpacks']),
    _CatData(name: 'Lingerie', image: 'https://picsum.photos/120?4', subs: ['Bras', 'Panties']),
    _CatData(name: 'Accessories', image: 'https://picsum.photos/120?5', subs: ['Jewelry', 'Hats']),
    _CatData(name: 'Just for You', image: 'https://picsum.photos/120?6', isSpecial: true),
  ];

  @override
  Widget build(BuildContext context) {
    final sheetH = MediaQuery.of(context).size.height * 0.92;

    return Container(
      height: sheetH,
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          // ===== Header =====
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 10),
            child: Row(
              children: [
                Text(
                  'All Categories',
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close_rounded, color: context.foreground, size: 28),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ===== Gender Tabs =====
                  _GenderTabs(
                    index: selectedGender,
                    onChanged: (v) => setState(() => selectedGender = v),
                  ),

                  const SizedBox(height: 24),

                  // ===== Categories List =====
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final isExpanded = expandedIndices.contains(i);

                      return _CategoryTile(
                        data: cat,
                        isExpanded: isExpanded,
                        selectedSubs: selectedSubs,
                        onToggle: () {
                          setState(() {
                            if (isExpanded) {
                              expandedIndices.remove(i);
                            } else {
                              expandedIndices.add(i);
                            }
                          });
                        },
                        onSubTap: (sub) {
                          setState(() {
                            if (selectedSubs.contains(sub)) {
                              selectedSubs.remove(sub);
                            } else {
                              selectedSubs.add(sub);
                            }
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== UI parts =====================

class _GenderTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _GenderTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.input,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Tab(text: 'All', on: index == 0, onTap: () => onChanged(0)),
          _Tab(text: 'Female', on: index == 1, onTap: () => onChanged(1)),
          _Tab(text: 'Male', on: index == 2, onTap: () => onChanged(2)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool on;
  final VoidCallback onTap;
  const _Tab({required this.text, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: on ? context.background : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: on ? Border.all(color: context.primary.withOpacity(0.2), width: 1) : null,
            boxShadow: on ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: on ? context.primary : context.mutedForeground,
                fontWeight: on ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _CatData data;
  final bool isExpanded;
  final Set<String> selectedSubs;
  final VoidCallback onToggle;
  final ValueChanged<String> onSubTap;

  const _CategoryTile({
    required this.data,
    required this.isExpanded,
    required this.selectedSubs,
    required this.onToggle,
    required this.onSubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(data.image, width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Text(
                  data.name,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (data.isSpecial) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.star_rounded, color: context.primary, size: 18),
                ],
                const Spacer(),
                if (data.isSpecial)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  )
                else
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: context.mutedForeground,
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded && data.subs.isNotEmpty) ...[
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.subs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (_, i) {
              final sub = data.subs[i];
              final isSelected = selectedSubs.contains(sub);
              return _SubItem(
                text: sub,
                on: isSelected,
                onTap: () => onSubTap(sub),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SubItem extends StatelessWidget {
  final String text;
  final bool on;
  final VoidCallback onTap;
  const _SubItem({required this.text, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: on ? context.primary.withOpacity(0.5) : context.border.withOpacity(0.4),
            width: on ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: on ? context.foreground : context.mutedForeground,
              fontWeight: on ? FontWeight.w900 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CatData {
  final String name;
  final String image;
  final List<String> subs;
  final bool isSpecial;
  _CatData({required this.name, required this.image, this.subs = const [], this.isSpecial = false});
}
