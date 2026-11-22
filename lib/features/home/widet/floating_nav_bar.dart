import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'common.dart';

class NavItem {
  final List<List<dynamic>> icon;
  final String label;
  const NavItem(this.icon, this.label);
}

/// Floating pill bar; the selected tab expands into a green pill with its label.
class FloatingNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: p.navBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < items.length; i++)
            _Tab(item: items[i], selected: i == index, onTap: () => onTap(i)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 13),
          decoration: BoxDecoration(
            color: selected ? p.green : const Color(0x00000000),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: item.icon,
                size: 22,
                color: selected ? p.onGreen : p.navIcon,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style: vText(
                            14,
                            w: FontWeight.w500,
                            color: p.onGreen,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
