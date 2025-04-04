import 'package:flutter/material.dart';
import 'genre_songs_screen.dart'; // Add this import

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Rock', 'color': Colors.redAccent},
    {'name': 'Jazz', 'color': Colors.blueAccent},
    {'name': 'Pop', 'color': Colors.purpleAccent},
    {'name': 'Hip Hop', 'color': Colors.greenAccent},
    {'name': 'Electronic', 'color': Colors.orangeAccent},
  ];

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
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
            title: const Text(
              'Explore Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            centerTitle: false,
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: Container(),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now..',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's unlock new insights with amazing community and share your community",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () => _navigateToGenreSongs(category['name']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: category['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category['color'].withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Category ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['name'],
                              style: TextStyle(
                                color: category['color'],
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Tap to explore songs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}