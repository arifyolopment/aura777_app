import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WalletRequestItem> _deposits = [];
  List<WalletRequestItem> _withdrawals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final dep = await ApiClient.getWalletHistory("deposit");
      final withdr = await ApiClient.getWalletHistory("withdraw");
      setState(() {
        _deposits = dep;
        _withdrawals = withdr;
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Transaction Records"),
        backgroundColor: AppTheme.background,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: "Deposits"),
            Tab(text: "Withdrawals"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_deposits, isDeposit: true),
                _buildList(_withdrawals, isDeposit: false),
              ],
            ),
    );
  }

  Widget _buildList(List<WalletRequestItem> list, {required bool isDeposit}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isDeposit ? Icons.savings_outlined : Icons.account_balance_outlined, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 10),
            Text(
              "No ${isDeposit ? 'deposit' : 'withdrawal'} history found",
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isApproved = item.status.toLowerCase() == "approved" || item.status.toLowerCase() == "success";
        final isPending = item.status.toLowerCase() == "pending";

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF38155A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDeposit ? const Color(0xFF16A34A).withOpacity(0.2) : const Color(0xFF9333EA).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isDeposit ? AppTheme.success : AppTheme.neonPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDeposit ? "Deposit Request" : "Withdrawal Request",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.createdAt.isNotEmpty
                            ? (DateTime.tryParse(item.createdAt) != null
                                ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(item.createdAt))
                                : item.createdAt)
                            : "Recent",
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isDeposit ? '+' : '-'}₹${item.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isDeposit ? AppTheme.success : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? AppTheme.success.withOpacity(0.2)
                          : isPending
                              ? AppTheme.accentYellow.withOpacity(0.2)
                              : AppTheme.danger.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isApproved
                            ? AppTheme.success
                            : isPending
                                ? AppTheme.accentYellow
                                : AppTheme.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
