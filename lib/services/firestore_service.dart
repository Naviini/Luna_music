import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference trackCollection =
      FirebaseFirestore.instance.collection('saved_tracks');

  Future<void> saveTrackToLibrary(String title, String artist, String imageUrl) async {
    try {
      await trackCollection.add({
        'title': title,
        'artist': artist,
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Track added successfully!");
    } catch (e) {
      print("❌ ERROR adding track: $e");
    }
  }

  Stream<QuerySnapshot> getTracks() {
    return trackCollection.orderBy('timestamp', descending: true).snapshots();
  }
}
