import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiClient {
  static const String baseUrl = "https://aura777.info/app/api";

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Requested-With": "com.aura777.app",
    },
  ));

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // 1. Player Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await _dio.post(
        "/auth.php",
        data: {
          "username": username,
          "password": password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (res.data["status"] == "success") {
        final data = res.data["data"];
        final prefs = await SharedPreferences.getInstance();
        final token = data['token'] ?? '';
        final userId = data['user_id'] ?? data['id'] ?? 0;
        final uname = data['username'] ?? username;

        // Extract and persist PHP session cookie if returned by server
        String? sessCookie;
        final rawCookies = res.headers['set-cookie'];
        if (rawCookies != null) {
          for (final c in rawCookies) {
            if (c.contains('AURA777_SESS=')) {
              final match = RegExp(r'AURA777_SESS=([^;]+)').firstMatch(c);
              if (match != null) {
                sessCookie = match.group(1);
                break;
              }
            }
          }
        }

        await prefs.setString('auth_token', token.toString());
        await prefs.setInt('user_id', userId is int ? userId : int.tryParse(userId.toString()) ?? 0);
        await prefs.setString('username', uname.toString());
        await prefs.setString('user_password', password);
        if (sessCookie != null) {
          await prefs.setString('sess_cookie', sessCookie);
        }
        return data;
      }
      throw Exception(res.data["message"] ?? "Invalid credentials");
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? "Network error";
      throw Exception(msg);
    }
  }

  // 2. Fetch Profile & Live Wallet Balance
  static Future<UserProfile> getProfile() async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.get("/profile.php", queryParameters: {
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] == "success") {
      return UserProfile.fromJson(res.data["data"]);
    }
    throw Exception(res.data["message"] ?? "Failed to load profile");
  }

  // 3. Fetch Games Catalog (234 Games)
  static Future<Map<String, dynamic>> getGames({String category = "all", String search = ""}) async {
    final res = await _dio.get("/games.php", queryParameters: {
      "category": category,
      "search": search,
      "limit": 250,
    });

    if (res.data["status"] == "success") {
      final rawGames = res.data["data"]["games"] as List? ?? [];
      final games = rawGames.map((g) => GameItem.fromJson(g)).toList();
      final counts = res.data["data"]["category_counts"] as Map<String, dynamic>? ?? {};
      return {
        "games": games,
        "counts": counts,
      };
    }
    throw Exception("Failed to load games");
  }

  // 4. Fetch Master Admin Payment Accounts
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.get("/wallet.php", queryParameters: {
      "action": "get_methods",
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] == "success") {
      final list = res.data["data"]["methods"] as List? ?? [];
      return list.map((m) => PaymentMethod.fromJson(m)).toList();
    }
    return [];
  }

  // 5. Submit Deposit Request
  static Future<void> submitDeposit(double amount, String utr) async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.post("/wallet.php?action=deposit", data: {
      "amount": amount,
      "utr_number": utr,
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] != "success") {
      throw Exception(res.data["message"] ?? "Deposit failed");
    }
  }

  // 6. Submit Withdraw Request
  static Future<void> submitWithdraw(double amount, String bankDetails) async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.post("/wallet.php?action=withdraw", data: {
      "amount": amount,
      "bank_details": bankDetails,
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] != "success") {
      throw Exception(res.data["message"] ?? "Withdrawal failed");
    }
  }

  // 7. Fetch Deposit & Withdraw History
  static Future<List<WalletRequestItem>> getWalletHistory(String type) async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.get("/wallet.php", queryParameters: {
      "action": "history",
      "type": type,
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] == "success") {
      final list = res.data["data"]["requests"] as List? ?? [];
      return list.map((r) => WalletRequestItem.fromJson(r)).toList();
    }
    return [];
  }

  // 8. Fetch Bet History Ledger
  static Future<Map<String, dynamic>> getBetHistory() async {
    final token = await getToken();
    final uid = await getUserId();
    final res = await _dio.get("/bet_history.php", queryParameters: {
      if (uid != null) "user_id": uid,
    }, options: Options(headers: {
      if (token != null) "Authorization": "Bearer $token",
    }));

    if (res.data["status"] == "success") {
      final data = res.data["data"];
      final rawBets = data["bets"] as List? ?? [];
      final bets = rawBets.map((b) => BetRecord.fromJson(b)).toList();
      return {
        "bets": bets,
        "turnover": (data["total_turnover"] as num?)?.toDouble() ?? 0.0,
        "net_pnl": (data["total_net_pnl"] as num?)?.toDouble() ?? 0.0,
      };
    }
    throw Exception("Failed to load betting history");
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
