class UserProfile {
  final int id;
  final String username;
  final double walletBalance;
  final double withdrawableBalance;
  final String? masterAdminName;
  final String status;

  UserProfile({
    required this.id,
    required this.username,
    required this.walletBalance,
    required this.withdrawableBalance,
    this.masterAdminName,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      withdrawableBalance: (json['available_balance'] as num?)?.toDouble() ??
          (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      masterAdminName: json['master_admin'] is Map
          ? json['master_admin']['username']
          : json['master_name']?.toString(),
      status: json['status'] ?? 'active',
    );
  }
}

class GameItem {
  final int id;
  final String gameUid;
  final String title;
  final String category;
  final String provider;
  final String icon;
  final String launchUrl;

  GameItem({
    required this.id,
    required this.gameUid,
    required this.title,
    required this.category,
    required this.provider,
    required this.icon,
    required this.launchUrl,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id'] ?? 0,
      gameUid: json['game_uid'] ?? '',
      title: json['title'] ?? json['game_name'] ?? 'Game',
      category: json['category'] ?? 'slot',
      provider: json['provider'] ?? 'JL',
      icon: json['icon'] ?? '',
      launchUrl: json['launch_url'] ?? '',
    );
  }
}

class PaymentMethod {
  final int id;
  final String title;
  final String methodType;
  final String? upiId;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;

  PaymentMethod({
    required this.id,
    required this.title,
    required this.methodType,
    this.upiId,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      title: json['account_title'] ?? 'Payment Method',
      methodType: json['method_type'] ?? 'upi',
      upiId: json['upi_id'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
    );
  }
}

class WalletRequestItem {
  final int id;
  final String type;
  final double amount;
  final String status;
  final String? utrNumber;
  final String? bankDetails;
  final String createdAt;

  WalletRequestItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.utrNumber,
    this.bankDetails,
    required this.createdAt,
  });

  factory WalletRequestItem.fromJson(Map<String, dynamic> json) {
    return WalletRequestItem(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'deposit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      utrNumber: json['utr_number'],
      bankDetails: json['bank_details'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class BetRecord {
  final String id;
  final String category;
  final String title;
  final double amount;
  final double netPnl;
  final String status;
  final String createdAt;

  BetRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.netPnl,
    required this.status,
    required this.createdAt,
  });

  factory BetRecord.fromJson(Map<String, dynamic> json) {
    return BetRecord(
      id: json['id']?.toString() ?? '',
      category: json['category'] ?? 'Casino',
      title: json['title'] ?? 'Wager',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'settled',
      createdAt: json['created_at'] ?? '',
    );
  }
}
