
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color teal = Color(0xFF438F89);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('transactions');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, transactionsBox, _) {
          double income = 0;
          double expenses = 0;

          for (final value in transactionsBox.values) {
            if (value is! Map) continue;

            final amount = (value['amount'] as num).toDouble();

            if (value['type'] == 'Income') {
              income += amount;
            } else if (value['type'] == 'Expense') {
              expenses += amount;
            }
          }

          final balance = income - expenses;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: teal,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₹ ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _WalletItem(
                  title: 'Total Income',
                  amount: income,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
                _WalletItem(
                  title: 'Total Expenses',
                  amount: expenses,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WalletItem extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _WalletItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
