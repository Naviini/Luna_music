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
            // Add Playlist button
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
        Text(title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            )),
        TextButton(
          onPressed: () {},
          child: Text(actionText, style: TextStyle(color: colorScheme.primary, fontSize: 14)),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(track['title'] ?? 'Unknown',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        )),
                    Text(track['artist'] ?? 'Unknown Artist',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
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
            List<dynamic> songs = playlist['songs'] ?? []; // Ensure it's always a list

            return ExpansionTile(
              title: Text(playlist['name'] ?? "Unknown Playlist"),
              children: songs.map((song) {
                if (song is Map<String, dynamic>) { // Ensure it's a valid map
                  return ListTile(
                    title: Text(song['title'] ?? "Unknown Song"),
                  );
                } else {
                  return const SizedBox(); // Ignore invalid entries
                }
              }).toList(),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => FirestoreService().deletePlaylist(playlist.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Add Playlist button and dialog
  Widget _buildAddPlaylistButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showAddPlaylistDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text('Add Playlist'),
    );
  }

  // Show dialog to add playlist
  void _showAddPlaylistDialog(BuildContext context) {
    final _playlistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Playlist Name'),
          content: TextField(
            controller: _playlistController,
            decoration: const InputDecoration(hintText: 'Playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String playlistName = _playlistController.text.trim();
                if (playlistName.isNotEmpty) {
                  FirestoreService().addPlaylist(playlistName);
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
