import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication package
import 'settings_screen.dart'; // Link to settings screen
import 'EditBiographyScreen.dart'; // Link to Edit Biography screen
import '../../player_screen.dart'; // Link to Music Player

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String bio = "Loading...";
  int followers = 0;
  int following = 0;

  List<Map<String, String>> songs = [];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchSavedTracks();
  }

  // Fetch user profile data from Firestore
  Future<void> _fetchUserProfile() async {
    try {
      // Get the current logged-in user's ID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User is not logged in');
      }

      // Fetch the user's document from Firestore using their userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Get the user document by userId
          .get();

      if (!userDoc.exists) {
        throw FirebaseException(code: 'user-not-found', message: 'User profile not found in Firestore', plugin: '');
      }

      setState(() {
        name = userDoc['username'] ?? "Name not available";
        bio = userDoc['bio'] ?? "Bio not available";
        followers = userDoc['followers'] ?? 0;
        following = userDoc['following'] ?? 0;
      });
    } catch (e) {
      if (e is FirebaseAuthException) {
        setState(() {
          name = "Authentication Error";
          bio = "Please log in again";
        });
        print("Authentication error: ${e.message}");
      } else if (e is FirebaseException) {
        setState(() {
          name = "Firestore Error";
          bio = "Could not fetch profile data";
        });
        print("Firestore error: ${e.message}");
      } else {
        setState(() {
          name = "Error loading profile";
          bio = "Unknown error occurred";
        });
        print("Unknown error: $e");
      }
    }
  }

  // Fetch saved tracks from Firestore
  Future<void> _fetchSavedTracks() async {
    try {
      // Get the current logged-in user's ID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User is not logged in');
      }

      // Fetch the user's saved tracks from Firestore using their userId
      final savedTracksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Use the user's ID to access their document
          .collection('saved_tracks') // Saved tracks should be stored here
          .get();

      if (savedTracksSnapshot.docs.isEmpty) {
        print("No saved tracks found for this user.");
        setState(() {
          songs = [];
        });
        return;
      }

      List<Map<String, String>> fetchedSongs = [];
      for (var doc in savedTracksSnapshot.docs) {
        var songData = doc.data();
        fetchedSongs.add({
          "title": songData['title'] ?? "Untitled", // Provide default values if data is missing
          "artist": songData['artist'] ?? "Unknown Artist",
          "imageUrl": songData['image'] ?? "assets/default_image.jpg", // Default image if none exists
          "url": songData['songUrl'] ?? "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", // Default URL if none exists
        });
      }

      setState(() {
        songs = fetchedSongs; // Update the state with fetched songs
      });
    } catch (e) {
      print("Error fetching saved tracks: $e");
      setState(() {
        songs = []; // Clear any existing data if there's an error
      });

      if (e is FirebaseAuthException) {
        print("Authentication error: ${e.message}");
      } else if (e is FirebaseException) {
        print("Firestore error: ${e.message}");
      } else {
        print("Unknown error: $e");
      }
    }
  }

  void _playNextSong(int currentIndex) {
    if (currentIndex < songs.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerPage(
            title: songs[currentIndex + 1]["title"]!,
            artist: songs[currentIndex + 1]["artist"]!,
            imageUrl: songs[currentIndex + 1]["imageUrl"]!,
            url: songs[currentIndex + 1]["url"]!,
            onNext: () => _playNextSong(currentIndex + 1),
            onPrevious: () => _playPreviousSong(currentIndex + 1),
          ),
        ),
      );
    } else {
      print("No next song available");
    }
  }

  void _playPreviousSong(int currentIndex) {
    if (currentIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerPage(
            title: songs[currentIndex - 1]["title"]!,
            artist: songs[currentIndex - 1]["artist"]!,
            imageUrl: songs[currentIndex - 1]["imageUrl"]!,
            url: songs[currentIndex - 1]["url"]!,
            onNext: () => _playNextSong(currentIndex - 1),
            onPrevious: () => _playPreviousSong(currentIndex - 1),
          ),
        ),
      );
    } else {
      print("No previous song available");
    }
  }

  // Update biography in Firestore
  Future<void> _updateBio(String newBio) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Update the user's bio in Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'bio': newBio,
      });

      setState(() {
        bio = newBio;
      });
    } catch (e) {
      print("Error updating bio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.png'),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProfileStat(count: "9", label: "Posts"),
                      ProfileStat(count: "500", label: "Followers"),
                      ProfileStat(count: "300", label: "Following"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                const SizedBox(height: 8.0),
                Text(
                  bio,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditBiographyScreen()),
                  );

                  if (result != null && result is String) {
                    _updateBio(result);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child: const Text("Edit Biography",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child: const Text("Share Profile",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white54),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                          title: songs[index]["title"]!,
                          artist: songs[index]["artist"]!,
                          imageUrl: songs[index]["imageUrl"]!,
                          url: songs[index]["url"]!,
                          onNext: () => _playNextSong(index),
                          onPrevious: () => _playPreviousSong(index),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(songs[index]["imageUrl"]!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  const ProfileStat({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
}
