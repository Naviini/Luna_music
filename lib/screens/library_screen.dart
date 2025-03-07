import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saved Tracks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Fetch saved tracks from a database later
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:
                        const Icon(Icons.music_note, color: Colors.deepPurple),
                    title: Text('Saved Track ${index + 1}'),
                    subtitle: Text('Artist ${index + 1}'),
                    onTap: () {
                      // Play saved track
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "My Playlists",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount:
                    3, // Fetch user-created playlists from a database later
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.playlist_play,
                        color: Colors.deepPurple),
                    title: Text('Playlist ${index + 1}'),
                    subtitle: Text('Created on ${DateTime.now().year}'),
                    onTap: () {
                      // Navigate to playlist details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
