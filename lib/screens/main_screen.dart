import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'games_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomNavIndex = 0; // 0: Home/T2, 1: VIP, 2: Earn, 3: Shop
  String _selectedCategory = "HOT"; // HOT, Casino, Slots, Mini
  UserProfile? _user;
  bool _isLoadingUser = true;

  // Banner carousel page controller
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  // Marquee announcement
  final List<String> _marqueeMessages = [
    "user_xxxx1880 Withdraw Cash ₹10,000",
    "user_xxxx4381 Withdraw Cash ₹100",
    "user_xxxx8644 Add Cash ₹2,000",
    "user_xxxx2538 Withdraw Cash ₹5,000",
    "user_xxxx9012 Win Mega Jackpot ₹45,200",
  ];
  int _marqueeIndex = 0;
  Timer? _marqueeTimer;

  @override
  void initState() {
    super.initState();
    _refreshBalance();
    _startTimers();
  }

  void _startTimers() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    _marqueeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _marqueeIndex = (_marqueeIndex + 1) % _marqueeMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _marqueeTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _refreshBalance() async {
    setState(() => _isLoadingUser = true);
    try {
      final user = await ApiClient.getProfile();
      setState(() => _user = user);
    } catch (_) {} finally {
      setState(() => _isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Promotional Top Banner Carousel
                _buildTopBannerCarousel(),

                // 2. Marquee Ticker
                _buildMarqueeBar(),

                // 3. User Balance & Quick Action Bar
                _buildUserBar(),

                // 4. Main Body: Left Sidebar + Right Game Grid
                Expanded(
                  child: _bottomNavIndex == 0
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left glowing category navigation tabs
                            _buildLeftSidebar(),
                            // Right Game Catalog
                            Expanded(
                              child: GamesScreen(
                                onBalanceRefreshRequested: _refreshBalance,
                                activeCategory: _selectedCategory,
                                onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
                              ),
                            ),
                          ],
                        )
                      : _buildTabScreen(_bottomNavIndex),
                ),
              ],
            ),

            // 5. Bottom Navigation Bar with Curved Center "Get ₹500"
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabScreen(int index) {
    switch (index) {
      case 1:
        return ProfileScreen(user: _user, onBalanceRefreshRequested: _refreshBalance);
      case 2:
        return const HistoryScreen();
      case 3:
        return const DepositScreen();
      default:
        return const SizedBox();
    }
  }

  // --- 1. Promotional Banner Carousel ---
  Widget _buildTopBannerCarousel() {
    return SizedBox(
      height: 120,
      child: PageView(
        controller: _bannerController,
        onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
        children: [
          _buildBannerSlide1(),
          _buildBannerSlide2(),
          _buildBannerSlide3(),
        ],
      ),
    );
  }

  Widget _buildBannerSlide1() {
    // GET ₹500 Spin Now (Image 1)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF6B21A8), Color(0xFF7E22CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x77000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient shine
          Positioned(
            right: 20,
            top: -10,
            bottom: -10,
            width: 140,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFEAB308), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "GET ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                            child: const Text(
                              "₹500",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Open Chests & Spin the Wheel to Win Big!",
                        style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      // Spin Now Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Color(0x66FFB800), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Text(
                          "Spin Now",
                          style: TextStyle(
                            color: Color(0xFF451A03),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Fortune Wheel Graphic icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.gold, width: 2),
                    gradient: const SweepGradient(
                      colors: [Color(0xFFFFB800), Color(0xFF9333EA), Color(0xFF00D2FF), Color(0xFFFFB800)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.stars, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide2() {
    // BONUS TO CASH (Image 2)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF4C0519), Color(0xFF831843), Color(0xFF581C87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                  child: const Text(
                    "BONUS TO CASH",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.gold, width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer, color: AppTheme.gold, size: 10),
                      SizedBox(width: 3),
                      Text("07:09:10", style: TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              "PLAY, COLLECT BONUS AND CONVERT TO REAL CASH!",
              style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildBonusPill("EARN BONUS", Icons.monetization_on),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.gold),
                _buildBonusPill("PLAY & WIN", Icons.casino),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.gold),
                _buildBonusPill("CONVERT CASH", Icons.account_balance_wallet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlide3() {
    // 7Day Sign-In Rewards (Images 3 & 4)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF581C87), Color(0xFF3B0764)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                    child: const Text(
                      "7Day Sign-In Rewards",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "COME BACK EVERYDAY AND WIN BIG REWARDS!",
                    style: TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.neonPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Claim Today's Bonus",
                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.card_giftcard, color: AppTheme.gold, size: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusPill(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 9, color: AppTheme.gold),
          const SizedBox(width: 3),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 2. Live Marquee Ticker ---
  Widget _buildMarqueeBar() {
    return Container(
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0635),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A1572), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: AppTheme.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: Text(
                _marqueeMessages[_marqueeIndex],
                key: ValueKey<int>(_marqueeIndex),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.goldLight,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. User Balance & Quick Deposit/Withdraw Bar ---
  Widget _buildUserBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          // User Avatar & VIP Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 1.5),
                  color: const Color(0xFF3B1259),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              Positioned(
                bottom: -3,
                left: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 0.5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      "VIP 3",
                      style: TextStyle(
                        color: Color(0xFF451A03),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Username & Dual Balance Pills
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.username.isNotEmpty == true ? _user!.username : "user_54911560",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Cash Balance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF280B45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6B21A8), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.goldGradient,
                            ),
                            child: const Center(
                              child: Text(
                                "₹",
                                style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _user?.walletBalance.toStringAsFixed(2) ?? "276.14",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Coins / Bonus Balance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF280B45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6B21A8), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.toll, color: AppTheme.gold, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            _user?.withdrawableBalance.toStringAsFixed(2) ?? "227.54",
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Deposit & Withdraw Action Buttons
          Row(
            children: [
              // Deposit Button
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen()));
                },
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9333EA),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x669333EA), blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 2),
                    const Text("Deposit", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Withdraw Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WithdrawScreen(
                        currentBalance: _user?.walletBalance ?? 0.0,
                        onBalanceRefreshRequested: _refreshBalance,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x6616A34A), blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 2),
                    const Text("Withdraw", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. Left Vertical Category Navigation Bar ---
  Widget _buildLeftSidebar() {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(left: 6, right: 4, top: 4, bottom: 65),
      child: Column(
        children: [
          _buildSidebarTab("HOT", Icons.local_fire_department, hasFire: true),
          const SizedBox(height: 6),
          _buildSidebarTab("Casino", Icons.casino),
          const SizedBox(height: 6),
          _buildSidebarTab("Slots", Icons.looks_one),
          const SizedBox(height: 6),
          _buildSidebarTab("Mini", Icons.sports_esports),
          const Spacer(),
          // Floating VIP / Gift Code Shortcut (Image 1, 2, 3)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B168C), Color(0xFF280B45)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.gold, width: 0.8),
            ),
            child: const Column(
              children: [
                Icon(Icons.card_giftcard, color: AppTheme.gold, size: 20),
                SizedBox(height: 2),
                Text(
                  "Gift Code",
                  style: TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTab(String title, IconData icon, {bool hasFire = false}) {
    final bool isSelected = _selectedCategory.toUpperCase() == title.toUpperCase();

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7B1FA2) : const Color(0xFF210538),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFD946EF) : const Color(0xFF38155A),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x66D946EF), blurRadius: 6, offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFFC084FC),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFC084FC),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. Custom Bottom Curved Navigation Bar with Floating Center Claim Button ---
  Widget _buildBottomNav() {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background bar
          Container(
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A0E78), Color(0xFF23033F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, "Home", Icons.home),
                _buildBottomNavItem(1, "VIP", Icons.workspace_premium, hasBadge: true),
                const SizedBox(width: 60), // Space for center floating "Get ₹500"
                _buildBottomNavItem(2, "Earn", Icons.share),
                _buildBottomNavItem(3, "Shop", Icons.shopping_cart),
              ],
            ),
          ),

          // Central Elevated "Get ₹500" Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                _showClaimBonusDialog();
              },
              child: Container(
                width: 72,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF581C87)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: AppTheme.gold, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xAA9333EA), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: AppTheme.gold, size: 20),
                    const SizedBox(height: 2),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                      child: const Text(
                        "Get₹500",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, String label, IconData icon, {bool hasBadge = false}) {
    final bool isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _bottomNavIndex = index);
        if (index == 0) _refreshBalance();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.gold : const Color(0xFFB099D0),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? AppTheme.gold : const Color(0xFFB099D0),
                ),
              ),
            ],
          ),
          if (hasBadge)
            Positioned(
              top: -2,
              right: -3,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showClaimBonusDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A0845),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.gold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: AppTheme.gold),
            SizedBox(width: 8),
            Text("Spin to Win ₹500!", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Daily spin wheel is ready! Spin the wheel to unlock up to ₹500 cash and gold bonus tokens.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🎉 Congratulations! ₹50 Free Bonus added to your wallet!"),
                  backgroundColor: AppTheme.success,
                ),
              );
              _refreshBalance();
            },
            child: const Text("Claim Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
