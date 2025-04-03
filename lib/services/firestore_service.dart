import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get saved tracks
  Stream<QuerySnapshot> getTracks() {
    return _db.collection('saved_tracks').snapshots();
  }

  // Get list of playlists
  Stream<QuerySnapshot> getPlaylists() {
    return _db.collection('playlists').snapshots();
  }

  // Add a new playlist
  Future<void> addPlaylist(String playlistName) async {
    await _db.collection('playlists').add({
      'name': playlistName,
      'songs': [], // Empty song list initially
    });
  }

  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    await _db.collection('playlists').doc(playlistId).delete();
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId, String songTitle) async {
    await _db.collection('playlists').doc(playlistId).update({
      'songs': FieldValue.arrayUnion([
        {'id': songId, 'title': songTitle}
      ])
    });
  }
}
