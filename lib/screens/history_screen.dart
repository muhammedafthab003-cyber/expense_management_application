
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const Color historyTeal = Color(0xFF438F89);
const Color historyBackground = Color(0xFFF7FAF9);

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('transactions');

    return Scaffold(
      backgroundColor: historyBackground,
      appBar: AppBar(
        title: const Text('Transactions History'),
        backgroundColor: historyTeal,
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

          // Keep original Hive keys so edits/deletes affect
          // the correct transaction, even in reversed order.
          final keys = transactionsBox.keys.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final rawItem = transactionsBox.get(key);

              if (rawItem is! Map) {
                return const SizedBox.shrink();
              }

              final item = Map<String, dynamic>.from(rawItem);

              return _TransactionCard(
                item: item,
                onEdit: () => _editTransaction(
                  context,
                  box,
                  key,
                  item,
                ),
                onDelete: () => _deleteTransaction(
                  context,
                  box,
                  key,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    dynamic box,
    dynamic key,
    Map<String, dynamic> item,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: item['name']?.toString() ?? '',
    );
    final amountController = TextEditingController(
      text: item['amount']?.toString() ?? '',
    );

    String type = item['type']?.toString() ?? 'Expense';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Type',
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
                          if (value != null) {
                            setDialogState(() => type = value);
                          }
                        },
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length < 2) {
                            return 'Enter at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₹ ',
                        ),
                        validator: (value) {
                          final amount = double.tryParse(
                            value?.trim() ?? '',
                          );

                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave == true) {
      final amount = double.parse(amountController.text.trim());

      await box.put(key, {
        ...item,
        'type': type,
        'name': nameController.text.trim(),
        'amount': amount,
        // Keep the original date when editing.
        'date': item['date'],
      });
    }

    nameController.dispose();
    amountController.dispose();
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    dynamic box,
    dynamic key,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await box.delete(key);
    }
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${item['type']} • $dateText'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.more_vert, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
