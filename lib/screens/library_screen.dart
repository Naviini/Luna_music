// import 'package:flutter/material.dart';

// class LibraryScreen extends StatelessWidget {
//   const LibraryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Library'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Saved Tracks",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 5, // Fetch saved tracks from a database later
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading:
//                         const Icon(Icons.music_note, color: Colors.deepPurple),
//                     title: Text('Saved Track ${index + 1}'),
//                     subtitle: Text('Artist ${index + 1}'),
//                     onTap: () {
//                       // Play saved track
//                     },
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "My Playlists",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount:
//                     3, // Fetch user-created playlists from a database later
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading: const Icon(Icons.playlist_play,
//                         color: Colors.deepPurple),
//                     title: Text('Playlist ${index + 1}'),
//                     subtitle: Text('Created on ${DateTime.now().year}'),
//                     onTap: () {
//                       // Navigate to playlist details
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Saved Tracks"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Fetch saved tracks from a database later
                itemBuilder: (context, index) {
                  return trackCard(index);
                },
              ),
            ),
            const SizedBox(height: 20),
            sectionTitle("My Playlists"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Fetch user-created playlists from a database later
                itemBuilder: (context, index) {
                  return playlistCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget trackCard(int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: const Icon(Icons.music_note, color: Colors.deepPurple, size: 30),
        title: Text('Saved Track ${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text('Artist ${index + 1}', style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.play_arrow, color: Colors.black),
        onTap: () {
          // Play saved track
        },
      ),
    );
  }

  Widget playlistCard(int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: const Icon(Icons.playlist_play, color: Colors.deepPurple, size: 30),
        title: Text('Playlist ${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text('Created on ${DateTime.now().year}', style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          // Navigate to playlist details
        },
      ),
    );
  }
}
