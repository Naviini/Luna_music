import 'package:flutter/material.dart';
import 'genre_songs_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Rock',
      'icon': Icons.rocket_launch,
      'description': 'Classic and modern rock anthems'
    },
    {
      'name': 'Jazz',
      'icon': Icons.music_note,
      'description': 'Smooth jazz and improvisation'
    },
    {
      'name': 'Pop',
      'icon': Icons.star,
      'description': 'Current and timeless pop hits'
    },
    {
      'name': 'Hip Hop',
      'icon': Icons.mic,
      'description': 'Urban beats and rhymes'
    },
    {
      'name': 'Electronic',
      'icon': Icons.electrical_services,
      'description': 'EDM and electronic vibes'
    },
  ];

  final Color primaryColor = const Color.fromARGB(255, 108, 51, 179); // Original card accent color
  final Color cardColor = const Color.fromARGB(255, 30, 30, 30);

  void _navigateToGenreSongs(String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreSongsScreen(genre: genre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: CustomScrollView(
        slivers: [
          // ===== ONLY THIS SECTION CHANGED (HEADER COLOR) =====
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(43, 20, 72, 1), // New purple header
            title: const Text(
              'Explore Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: Container(
              color: const Color.fromRGBO(43, 20, 72, 1), // Solid purple (no gradient)
            ),
          ),
          // ===================================================

          // Everything below remains EXACTLY THE SAME
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Music Genres',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Browse categories to discover new music",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _navigateToGenreSongs(category['name']),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                category['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['description'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(top: 16, bottom: 32),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'More categories coming soon',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}