import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Library',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Recently Played", "See All", colorScheme, textTheme),
            const SizedBox(height: 12),
            _buildTrackListFromFirestore(colorScheme, textTheme),
            const SizedBox(height: 24),
            _buildSectionHeader("Your Playlists", "View All", colorScheme, textTheme),
            const SizedBox(height: 12),
            _buildPlaylistListFromFirestore(colorScheme, textTheme),
            const SizedBox(height: 24),
            _buildAddPlaylistButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {
            // Optional: Add navigation to full track or playlist view
          },
          child: Text(
            actionText,
            style: TextStyle(color: colorScheme.primary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackListFromFirestore(ColorScheme colorScheme, TextTheme textTheme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getTracks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No tracks found"));
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var track = snapshot.data!.docs[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        track['image'] ?? '',
                        height: 120,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey, height: 120, width: 160),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      track['title'] ?? 'Unknown',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track['artist'] ?? 'Unknown Artist',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistListFromFirestore(ColorScheme colorScheme, TextTheme textTheme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No playlists found"));
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((playlist) {
            List<dynamic> songs = playlist['songs'] ?? [];

            return ExpansionTile(
              title: Text(
                playlist['name'] ?? "Unknown Playlist",
                style: textTheme.titleSmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  FirestoreService().deletePlaylist(playlist.id);
                },
              ),
              children: songs.map((song) {
                if (song is Map<String, dynamic>) {
                  return ListTile(
                    title: Text(song['title'] ?? "Unknown Song"),
                    leading: const Icon(Icons.music_note),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAddPlaylistButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddPlaylistDialog(context),
      icon: const Icon(Icons.playlist_add),
      label: const Text('Add Playlist'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  void _showAddPlaylistDialog(BuildContext context) {
    final playlistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Playlist Name'),
          content: TextField(
            controller: playlistController,
            decoration: const InputDecoration(hintText: 'Playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = playlistController.text.trim();
                if (name.isNotEmpty) {
                  FirestoreService().addPlaylist(name);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
