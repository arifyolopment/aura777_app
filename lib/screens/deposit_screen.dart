import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();
  List<PaymentMethod> _methods = [];
  PaymentMethod? _selectedMethod;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<double> _quickAmounts = [100, 300, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final methods = await ApiClient.getPaymentMethods();
      setState(() {
        _methods = methods;
        if (methods.isNotEmpty) _selectedMethod = methods.first;
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitDeposit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final utr = _utrController.text.trim();

    if (amount < 100) {
      Fluttertoast.showToast(msg: "Minimum deposit is ₹100");
      return;
    }
    if (utr.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter UTR / Transaction Reference");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiClient.submitDeposit(
        amount,
        utr,
      );
      Fluttertoast.showToast(msg: "Deposit request submitted successfully!");
      _amountController.clear();
      _utrController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Deposit Funds", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Select Amount Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF4A1572)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deposit Amount",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixText: "₹ ",
                            prefixStyle: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
                            hintText: "Enter amount",
                            hintStyle: const TextStyle(color: Colors.white30, fontSize: 16),
                            filled: true,
                            fillColor: const Color(0xFF280B45),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF5B168C)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF5B168C)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Quick Amount Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickAmounts.map((amt) {
                            return GestureDetector(
                              onTap: () {
                                _amountController.text = amt.toInt().toString();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF280B45),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                                ),
                                child: Text(
                                  "+₹${amt.toInt()}",
                                  style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Payment Method Selection
                  if (_methods.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF4A1572)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Payment UPI / QR",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ..._methods.map((m) {
                            final isSel = _selectedMethod?.id == m.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMethod = m),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF3B1259) : const Color(0xFF280B45),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? AppTheme.gold : const Color(0xFF5B168C),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: isSel ? AppTheme.gold : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          if (m.upiId != null)
                                            Text("UPI: ${m.upiId}", style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    if (m.upiId != null)
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 16, color: AppTheme.gold),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: m.upiId!));
                                          Fluttertoast.showToast(msg: "UPI Copied");
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  // UTR Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF4A1572)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "UTR / Reference Number",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _utrController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Enter 12-digit UPI UTR",
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: const Color(0xFF280B45),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF5B168C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitDeposit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "SUBMIT DEPOSIT",
                              style: TextStyle(color: Color(0xFF451A03), fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
