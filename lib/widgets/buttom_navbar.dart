
import 'package:flutter/material.dart';

class ExpenseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const ExpenseBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  static const Color teal = Color(0xFF438F89);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: teal,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            _item(Icons.home_outlined, 0),
            _item(Icons.history_rounded, 1),
            const Spacer(),
            _item(Icons.account_balance_wallet_outlined, 2),
            _item(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, int index) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (selected)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  height: 3,
                  width: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
