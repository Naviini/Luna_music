import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GenreSongsScreen extends StatelessWidget {
  final String genre;

  const GenreSongsScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(43, 20, 72, 1),
        title: Text(
          '$genre Songs',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildSongList(),
    );
  }

  Widget _buildSongList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('saved_tracks')
          .where('genre', isEqualTo: genre)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $genre songs found',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var song = snapshot.data!.docs[index];
            return _buildSongCard(song);
          },
        );
      },
    );
  }

  Widget _buildSongCard(DocumentSnapshot song) {
    Map<String, dynamic> data = song.data() as Map<String, dynamic>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: data['image'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[800],
              width: 50,
              height: 50,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.music_note),
          ),
        ),
        title: Text(
          data['title'] ?? 'Unknown Title',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          data['artist'] ?? 'Unknown Artist',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          onPressed: () {
            // TODO: Implement play functionality
          },
        ),
      ),
    );
  }
}