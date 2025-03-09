import 'package:flutter/material.dart';
import '../../player_screen.dart'; 
import 'settings_screen.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Shenon Lekamge";
  String bio = "Music lover | Producer";

  // List of songs
  final List<Map<String, String>> songs = List.generate(9, (index) {
    return {
      "title": "Song ${index + 1}",
      "artist": "Artist ${index + 1}",
      "imageUrl": "assets/track${index + 1}.jpg",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${index + 1}.mp3",
    };
  });

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
                        builder: (context) => const EditProfileScreen()),
                  );

                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      name = result['name'] ?? name;
                      bio = result['bio'] ?? bio;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child: const Text("Edit Profile",
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
                    // Navigate to player screen 
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
