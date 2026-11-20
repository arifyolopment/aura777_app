import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class WithdrawScreen extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onBalanceRefreshRequested;

  const WithdrawScreen({
    super.key,
    required this.currentBalance,
    required this.onBalanceRefreshRequested,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitWithdraw() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final dest = _destinationController.text.trim();

    if (amount < 100) {
      Fluttertoast.showToast(msg: "Minimum withdrawal is ₹100");
      return;
    }
    if (amount > widget.currentBalance) {
      Fluttertoast.showToast(msg: "Insufficient available balance");
      return;
    }
    if (dest.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your UPI ID or Bank Details");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiClient.submitWithdraw(
        amount,
        dest,
      );
      Fluttertoast.showToast(msg: "Withdrawal request submitted successfully!");
      _amountController.clear();
      _destinationController.clear();
      widget.onBalanceRefreshRequested();
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
        title: const Text("Withdraw Cash", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF280B45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold, width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x66FFB800), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Available to Withdraw", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("Direct to UPI / Bank", style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                    child: Text(
                      "₹${widget.currentBalance.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Amount Input Card
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
                  const Text("Withdrawal Amount", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      prefixStyle: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
                      hintText: "Enter amount (Min ₹100)",
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
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

            const SizedBox(height: 14),

            // Destination Input Card
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
                  const Text("UPI ID or Bank Account", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _destinationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "e.g. mobile@upi or A/C + IFSC",
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x6616A34A), blurRadius: 10),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CONFIRM WITHDRAWAL",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
