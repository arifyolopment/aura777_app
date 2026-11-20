import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'game_player_screen.dart';

class GamesScreen extends StatefulWidget {
  final VoidCallback onBalanceRefreshRequested;
  final String activeCategory;
  final Function(String) onCategoryChanged;

  const GamesScreen({
    super.key,
    required this.onBalanceRefreshRequested,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<GameItem> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void didUpdateWidget(covariant GamesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCategory != widget.activeCategory) {
      _loadGames();
    }
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      String cat = widget.activeCategory.toLowerCase();
      // Map UI categories to API categories if needed
      if (cat == "hot") cat = "all";
      if (cat == "slots") cat = "slot";
      if (cat == "casino") cat = "casino";
      if (cat == "mini") cat = "crash";

      final res = await ApiClient.getGames(category: cat);
      setState(() {
        _games = res["games"] as List<GameItem>;
      });
    } catch (_) {
      // Fallback or demo games matching screenshots if API has fewer
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.gold),
      );
    }

    if (widget.activeCategory.toUpperCase() == "MINI") {
      return _buildMiniGamesView();
    }

    return _buildGameGridView();
  }

  Widget _buildGameGridView() {
    // If games list from API is empty or small, mix with authentic fallback items matching screenshots
    final displayGames = _getMergedGames();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 80),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: displayGames.length,
      itemBuilder: (context, index) {
        final game = displayGames[index];
        return _buildCasinoGameCard(game, index);
      },
    );
  }

  List<GameCardData> _getMergedGames() {
    // Top visual games from screenshots
    final List<GameCardData> preset = [
      GameCardData(
        title: "Fortune Garuda 500",
        badge: "NEW",
        badgeColor: AppTheme.neonGreen,
        image: "https://images.unsplash.com/photo-1606167668584-78701c57f13d?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        tag: "HOT",
      ),
      GameCardData(
        title: "Fortune Garuda 1000",
        badge: "NEW",
        badgeColor: AppTheme.neonGreen,
        image: "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFFD97706), Color(0xFFB45309)],
        tag: "1000X",
      ),
      GameCardData(
        title: "Fortune Gems 500",
        badge: "NEW",
        badgeColor: AppTheme.neonGreen,
        image: "https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        tag: "500",
      ),
      GameCardData(
        title: "Fortune Gems",
        badge: "HOT",
        badgeColor: AppTheme.danger,
        image: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
        tag: "GEMS",
      ),
      GameCardData(
        title: "Fortune Gems 2",
        badge: "HOT",
        badgeColor: AppTheme.danger,
        image: "https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFFF97316), Color(0xFFC2410C)],
        tag: "GEMS 2",
      ),
      GameCardData(
        title: "Fortune Gems 3",
        badge: "HOT",
        badgeColor: AppTheme.danger,
        image: "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFFEAB308), Color(0xFFA16207)],
        tag: "GEMS 3",
      ),
      GameCardData(
        title: "Fortune Coins 2",
        badge: "HOT",
        badgeColor: AppTheme.danger,
        image: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFF06B6D4), Color(0xFF0E7490)],
        tag: "COINS 2",
      ),
      GameCardData(
        title: "Money Coming Expand Bets",
        badge: "NEW",
        badgeColor: AppTheme.neonGreen,
        image: "https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFF10B981), Color(0xFF047857)],
        tag: "EXPAND",
      ),
      GameCardData(
        title: "Clover Coins 4x4",
        badge: "NEW",
        badgeColor: AppTheme.neonGreen,
        image: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=300&q=80",
        gradient: const [Color(0xFF059669), Color(0xFF065F46)],
        tag: "4X4",
      ),
    ];

    if (_games.isNotEmpty) {
      final List<GameCardData> apiConverted = _games.map((g) {
        return GameCardData(
          title: g.title,
          badge: "HOT",
          badgeColor: AppTheme.danger,
          image: g.icon,
          gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          tag: g.provider.toUpperCase(),
          gameUid: g.gameUid,
          provider: g.provider,
        );
      }).toList();
      return apiConverted;
    }

    return preset;
  }

  Widget _buildCasinoGameCard(GameCardData game, int index) {
    return GestureDetector(
      onTap: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GamePlayerScreen(
              gameUid: game.gameUid ?? "fortune_gems_500",
              provider: game.provider ?? "JL",
              gameTitle: game.title,
            ),
          ),
        );
        if (res == true) {
          widget.onBalanceRefreshRequested();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5D288E), width: 1.2),
                gradient: LinearGradient(
                  colors: game.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game thumbnail image
                    game.image.startsWith("http")
                        ? CachedNetworkImage(
                            imageUrl: game.image,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: const Color(0xFF2C0D4D)),
                            errorWidget: (_, __, ___) => _buildFallbackGraphic(game),
                          )
                        : _buildFallbackGraphic(game),

                    // Top Left Badge (e.g. HOT / NEW)
                    if (game.badge != null)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: game.badgeColor ?? AppTheme.danger,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 2),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                game.badge == "HOT" ? Icons.local_fire_department : Icons.stars,
                                color: Colors.white,
                                size: 9,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                game.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Bottom glossy gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            game.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackGraphic(GameCardData game) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: game.gradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, color: AppTheme.gold, size: 28),
            const SizedBox(height: 4),
            Text(
              game.tag ?? "AURA",
              style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini Games View (Aviator, Mines, Chicken Road, Goal, Dice, Hilo) matching screenshot 3
  Widget _buildMiniGamesView() {
    final List<Map<String, dynamic>> miniGames = [
      {
        "title": "Golden Bank 2",
        "badge": null,
        "color": const Color(0xFF7A4A00),
        "icon": Icons.account_balance,
      },
      {
        "title": "Super Rich",
        "badge": "HOT",
        "color": const Color(0xFFD97706),
        "icon": Icons.monetization_on,
      },
      {
        "title": "Golden Empire",
        "badge": "NEW",
        "color": const Color(0xFF9333EA),
        "icon": Icons.military_tech,
      },
      {
        "title": "Aviator",
        "badge": null,
        "color": const Color(0xFFE11D48),
        "icon": Icons.flight_takeoff,
        "isAviator": true,
      },
      {
        "title": "Chicken Road 2",
        "badge": "HOT",
        "color": const Color(0xFFEA580C),
        "icon": Icons.egg,
      },
      {
        "title": "Mines",
        "badge": null,
        "color": const Color(0xFF0284C7),
        "icon": Icons.star_border,
        "isSimple": true,
        "code": "Mi",
      },
      {
        "title": "Chicken Road",
        "badge": null,
        "color": const Color(0xFFDB2777),
        "icon": Icons.pets,
      },
      {
        "title": "Goal",
        "badge": null,
        "color": const Color(0xFF16A34A),
        "icon": Icons.sports_soccer,
        "isSimple": true,
        "code": "Go",
      },
      {
        "title": "Dice",
        "badge": null,
        "color": const Color(0xFF7C3AED),
        "icon": Icons.casino,
        "isSimple": true,
        "code": "Di",
      },
      {
        "title": "Hilo",
        "badge": null,
        "color": const Color(0xFFF59E0B),
        "icon": Icons.swap_vert,
        "isSimple": true,
        "code": "Hi",
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 80),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: miniGames.length,
      itemBuilder: (context, index) {
        final item = miniGames[index];
        final Color cardColor = item["color"] as Color;
        final String? badge = item["badge"] as String?;
        final bool isSimple = item["isSimple"] == true;
        final bool isAviator = item["isAviator"] == true;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GamePlayerScreen(
                  gameUid: item["title"].toString().toLowerCase().replaceAll(" ", "_"),
                  provider: "MINI",
                  gameTitle: item["title"],
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cardColor.withOpacity(0.8), width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Badge
                      if (badge != null)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: badge == "HOT" ? AppTheme.danger : AppTheme.neonGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),

                      // Card Content
                      if (isSimple)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["code"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    item["title"],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(item["icon"] as IconData, color: Colors.white70, size: 24),
                              ),
                            ],
                          ),
                        )
                      else if (isAviator)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.airplanemode_active, color: Colors.white, size: 30),
                              const SizedBox(height: 4),
                              const Text(
                                "Aviator",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item["icon"] as IconData, color: AppTheme.gold, size: 28),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  item["title"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item["title"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GameCardData {
  final String title;
  final String? badge;
  final Color? badgeColor;
  final String image;
  final List<Color> gradient;
  final String? tag;
  final String? gameUid;
  final String? provider;

  GameCardData({
    required this.title,
    this.badge,
    this.badgeColor,
    required this.image,
    required this.gradient,
    this.tag,
    this.gameUid,
    this.provider,
  });
}
