import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luna/screens/sequencer_grid_screen.dart'; 
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import '../track_loader.dart';
import 'package:luna/track_loader.dart';
import '../template_loader.dart';
import '../models/sequencer_model.dart';
import 'settings_screen.dart'; // Import the new settings screen

class SequencerScreen extends StatelessWidget {
  const SequencerScreen({super.key});

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Tap cells to create beats'),
              Text('2. Use different rows for different instruments'),
              Text('3. Press play to hear your creation'),
              Text('4. Save your beats to access them later'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Music'),
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showTutorial(context),
            tooltip: 'Show Tutorial',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1), //0.8
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.queue_music,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Create Your Music",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          child: GridView.count(
                            crossAxisCount: 2, // Two buttons per row
                            mainAxisSpacing: 20, // Space between rows
                            crossAxisSpacing: 20, // Space between columns
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true, // Allow the grid to take only the needed space
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                            children: [
                              _buildFeatureButton(
                                context,
                                'New Track',
                                Icons.add_circle_outline,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SequencerGridScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildFeatureButton(
                                context,
                                'Load Track',
                                Icons.folder_open,
                                () async {
                                  List<String> tracks = await loadTracks();
                                  if (tracks.isNotEmpty) {
                                    _showTrackSelectionDialog(context, tracks);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No tracks available!')),
                                    );
                                  }
                                },
                              ),
                              _buildFeatureButton(
                                context,
                                'Templates',
                                Icons.library_music,
                                () async {
                                  List<String> templates = await loadTemplates();
                                  if (templates.isNotEmpty) {
                                    _showTemplateSelectionDialog(context, templates);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No templates available!')),
                                    );
                                  }
                                },
                              ),
                              _buildFeatureButton(
                                context,
                                'Settings',
                                Icons.settings,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '🎵 Pro tip: Tap the help icon for a quick tutorial!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Adjusted padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8), // More opaque background
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure minimal size
        children: [
          Center( // Center the icon
            child: Icon(icon, size: 25, color: Colors.white), // Decreased icon size
          ),
          const SizedBox(height: 8),
          Center( // Center the text
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14, // Increased font size for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center, // Center align the text
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackSelectionDialog(BuildContext context, List<String> tracks) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Track'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tracks[index]),
                  onTap: () {
                    _loadSelectedTrack(context, tracks[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _loadSelectedTrack(BuildContext context, String trackName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loading track: $trackName')),
    );
  }

  void _showTemplateSelectionDialog(BuildContext context, List<String> templates) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Template'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(templates[index]),
                  onTap: () {
                    _loadSelectedTemplate(context, templates[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _loadSelectedTemplate(BuildContext context, String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loading template: $templateName')),
    );
    // Implement the logic to load the selected template into the sequencer
  }
}