import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('My Library', 
            style: textTheme.headlineSmall?.copyWith(
              // fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
        centerTitle: false, 
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildQuickAccess(colorScheme, textTheme),
            const SizedBox(height: 24),
            
            
            _buildSectionHeader("Recently Played", "See All", colorScheme, textTheme),
            const SizedBox(height: 12),
            _buildHorizontalTrackList(colorScheme, textTheme),
            const SizedBox(height: 24),
            
          
            _buildSectionHeader("Your Playlists", "View All", colorScheme, textTheme),
            const SizedBox(height: 12),
            _buildPlaylistGrid(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  
  Widget _buildQuickAccess(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAction(Icons.favorite, "Favorites", colorScheme.error, colorScheme),
        _buildQuickAction(Icons.download, "Downloads", colorScheme.tertiary, colorScheme),
        _buildQuickAction(Icons.history, "History", colorScheme.secondary, colorScheme),
        _buildQuickAction(Icons.add, "Create", colorScheme.primary, colorScheme),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            )),
        TextButton(
          onPressed: () {},
          child: Text(actionText,
              style: TextStyle(color: colorScheme.primary, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildHorizontalTrackList(ColorScheme colorScheme, TextTheme textTheme) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://picsum.photos/200/200?random=$index",
                    height: 120,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Track ${index + 1}",
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    )),
                Text("Artist ${index + 1}",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistGrid(ColorScheme colorScheme, TextTheme textTheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerLowest,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://picsum.photos/300/300?random=$index",
                    fit: BoxFit.cover,
                    color: colorScheme.scrim.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Playlist ${index + 1}",
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text("${index + 5} tracks",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 
