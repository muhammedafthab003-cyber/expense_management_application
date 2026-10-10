
import 'package:expense_management_application/screens/wallet_screen.dart';
import 'package:expense_management_application/widgets/buttom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_management_application/screens/wallet_screen.dart';



const Color teal = Color(0xFF438F89);
const Color pageColor = Color(0xFFF7FAF9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  void openAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const HistoryPage(),
      const WalletPage(),
      const ProfilePage(),
      const  HistoryPage(),
      
    ];

    return Scaffold(
      backgroundColor: pageColor,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTransaction,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ExpenseBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        onAddTap: openAddTransaction,
      ),
    );
  }
}

// HOME DASHBOARD

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('transactions');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, transactionsBox, _) {
        final transactions = transactionsBox.values
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
            .reversed
            .toList();

        double income = 0;
        double expenses = 0;
        double dailyExpenses = 0;
        double weeklyExpenses = 0;

        final now = DateTime.now();

        for (final item in transactions) {
          final amount = (item['amount'] as num).toDouble();
          final isIncome = item['type'] == 'Income';
          final date = DateTime.tryParse(
            item['date'].toString(),
          );

          if (isIncome) {
            income += amount;
          } else {
            expenses += amount;

            if (date != null) {
              final sameDay = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              if (sameDay) {
                dailyExpenses += amount;
              }

              final startOfToday = DateTime(
                now.year,
                now.month,
                now.day,
              );
              final startOfWeek = startOfToday.subtract(
                Duration(days: startOfToday.weekday - 1),
              );

              if (!date.isBefore(startOfWeek) &&
                  !date.isAfter(now)) {
                weeklyExpenses += amount;
              }
            }
          }
        }

        final balance = income - expenses;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good afternoon,',
                  style: TextStyle(fontSize: 13),
                ),
                const Text(
                  'Your Finances',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: teal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: teal.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _BalanceItem(
                              title: 'Income',
                              amount: income,
                              icon: Icons.arrow_downward,
                            ),
                          ),
                          Expanded(
                            child: _BalanceItem(
                              title: 'Expenses',
                              amount: expenses,
                              icon: Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Daily and weekly expenses
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'DAILY EXPENSES',
                        amount: dailyExpenses,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'WEEKLY EXPENSES',
                        amount: weeklyExpenses,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // Recent transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tap History in the bottom navigation',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(color: teal),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...transactions.take(5).map(
                    (item) => TransactionTile(item: item),
                  ),

                // The extra Add Transaction button has been removed.
                // Use the + button in the bottom navigation instead.
              ],
            ),
          ),
        );
      },
    );
  }
}

// BALANCE ITEM

class _BalanceItem extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;

  const _BalanceItem({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 15),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// SUMMARY CARD

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;

  const _SummaryCard({
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TRANSACTION TILE

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const TransactionTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item['type'] == 'Income';
    final amount = (item['amount'] as num).toDouble();
    final date = DateTime.tryParse(item['date'].toString());

    final dateText = date == null
        ? 'Date unavailable'
        : '${date.day}/${date.month}/${date.year}';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        leading: CircleAvatar(
          backgroundColor:
              isIncome ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          item['name']?.toString() ?? 'Transaction',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          dateText,
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// HISTORY SCREEN

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('transactions');

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Transactions History'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, transactionsBox, _) {
          if (transactionsBox.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          final items = transactionsBox.values
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
              .reversed
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return TransactionTile(item: items[index]);
            },
          );
        },
      ),
    );
  }
}

// WALLET SCREEN

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: pageColor,
      body: Center(child: Text('Wallet')),
    );
  }
}

// PROFILE SCREEN

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: pageColor,
      body: Center(child: Text('Profile')),
    );
  }
}

// ADD TRANSACTION SCREEN

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  String? transactionType = 'Expense';
  DateTime? selectedDate = DateTime.now();

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) return;

    final box = Hive.box('transactions');

    await box.add({
      'type': transactionType!,
      'name': nameController.text.trim(),
      'amount': amount,
      'date': selectedDate!.toIso8601String(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction saved successfully'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: transactionType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Expense',
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: 'Income',
                    child: Text('Income'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => transactionType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select transaction type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter transaction name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter transaction name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must contain at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null) {
                    return 'Please enter a valid amount';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              FormField<DateTime>(
                initialValue: selectedDate,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
                builder: (field) {
                  return InkWell(
                    onTap: () async {
                      await pickDate();
                      field.didChange(selectedDate);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon:
                            const Icon(Icons.calendar_month),
                        errorText: field.errorText,
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select date'
                            : '${selectedDate!.day}/'
                                '${selectedDate!.month}/'
                                '${selectedDate!.year}',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16),
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
