
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  static const Color teal = Color(0xFF32847F);

  String _transactionType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    setState(() => _isSaving = true);

    try {
      final transaction = <String, dynamic>{
        'type': _transactionType,
        'name': _nameController.text.trim(),
        'amount': amount,
        'date': _selectedDate.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final box = Hive.box('transactions');
      await box.add(transaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction saved successfully'),
          backgroundColor: teal,
        ),
      );

      Navigator.pop(context, transaction);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save transaction. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Transaction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('TRANSACTION TYPE'),
                      DropdownButtonFormField<String>(
                        value: _transactionType,
                        decoration: _decoration(),
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
                            setState(() => _transactionType = value);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Select transaction type';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),
                      _label('NAME'),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration(
                          hint: 'Enter transaction name',
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';

                          if (name.isEmpty) {
                            return 'Enter a transaction name';
                          }
                          if (name.length < 2) {
                            return 'Name must contain at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),
                      _label('AMOUNT'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: _decoration(
                          hint: '0.00',
                          prefix: const Text('₹ '),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final amount = double.tryParse(text);

                          if (text.isEmpty) {
                            return 'Enter an amount';
                          }
                          if (amount == null || !amount.isFinite) {
                            return 'Enter a valid amount';
                          }
                          if (amount <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),
                      _label('DATE'),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: _decoration(
                            suffix: const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                          child: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}, '
                            '${_month(_selectedDate.month)} '
                            '${_selectedDate.year}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: teal.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: prefix,
            ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: teal),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  String _month(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }
}
