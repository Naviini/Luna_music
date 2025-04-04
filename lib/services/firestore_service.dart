import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Gets the current user's UID from Firebase Auth
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// Stream of saved tracks for the current user
  Stream<QuerySnapshot> getTracks() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved_tracks')
        .snapshots();
  }

  /// Stream of playlists for the current user
  Stream<QuerySnapshot> getPlaylists() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .snapshots();
  }

  /// Adds a new empty playlist to the current user's account
  Future<void> addPlaylist(String playlistName) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .add({
      'name': playlistName,
      'songs': [],
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a playlist by its Firestore document ID
  Future<void> deletePlaylist(String playlistId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .doc(playlistId)
        .delete();
  }

  /// Adds a song to a specific playlist
  Future<void> addSongToPlaylist(
    String playlistId,
    String songId,
    String songTitle,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .doc(playlistId)
        .update({
      'songs': FieldValue.arrayUnion([
        {
          'id': songId,
          'title': songTitle,
          'added_at': FieldValue.serverTimestamp(),
        }
      ])
    });
  }

  /// Removes a song from a playlist
  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
    String songTitle,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .doc(playlistId)
        .update({
      'songs': FieldValue.arrayRemove([
        {
          'id': songId,
          'title': songTitle,
        }
      ])
    });
  }

  /// Save a new track to the user's saved_tracks collection
  Future<void> saveTrack({
    required String id,
    required String title,
    required String artist,
    required String image,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('saved_tracks')
        .doc(id)
        .set({
      'id': id,
      'title': title,
      'artist': artist,
      'image': image,
      'saved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a track from the user's saved_tracks
  Future<void> deleteTrack(String trackId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('saved_tracks')
        .doc(trackId)
        .delete();
  }
}
