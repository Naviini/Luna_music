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

  void _showTrackSelectionDialog(BuildContext context, SequencerModel sequencerModel) async {
    final tracks = await sequencerModel.getSavedTracks();
    if (!context.mounted) return;

    if (tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved tracks found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Load Track',
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () async {
                      final updatedTracks = await sequencerModel.getSavedTracks();
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Click on a track to load it',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          final lastModified = DateTime.parse(track['lastModified'] ?? DateTime.now().toIso8601String());
                          return Card(
                            color: Colors.grey[800],
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                track['name'] ?? 'Untitled',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Last modified: ${lastModified.toString().split('.')[0]}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    '${track['metadata']?['tempo'] ?? '120'} BPM • ${track['metadata']?['key'] ?? 'C'} ${track['metadata']?['scale'] ?? 'Major'}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteTrackDialog(context, sequencerModel, track['name'] ?? ''),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showRenameTrackDialog(context, sequencerModel, track['name'] ?? ''),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final success = await sequencerModel.loadTrack(track['name'] ?? '');
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  if (success) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SequencerGridScreen(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Track "${track['name']}" loaded successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to load track "${track['name']}"'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteTrackDialog(BuildContext context, SequencerModel sequencerModel, String trackName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Track',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "$trackName"?\nThis action cannot be undone.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                final success = await sequencerModel.deleteTrack(trackName);
                if (context.mounted) {
                  Navigator.pop(context); // Close delete dialog
                  Navigator.pop(context); // Close load dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Track "$trackName" deleted successfully'
                            : 'Failed to delete track "$trackName"',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  // Show the track selection dialog again
                  _showTrackSelectionDialog(context, sequencerModel);
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRenameTrackDialog(BuildContext context, SequencerModel sequencerModel, String currentName) {
    String newName = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Rename Track',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: TextEditingController(text: currentName),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'New Track Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty && newName != currentName) {
                  // Save the current track with new name
                  await sequencerModel.saveSequence(trackName: newName);
                  // Delete the old track
                  await sequencerModel.deleteTrack(currentName);
                  if (context.mounted) {
                    Navigator.pop(context); // Close rename dialog
                    Navigator.pop(context); // Close load dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Track renamed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Show the track selection dialog again
                    _showTrackSelectionDialog(context, sequencerModel);
                  }
                }
              },
              child: const Text(
                'Rename',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
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
          child: SizedBox(
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
                                () {
                                  final sequencerModel = Provider.of<SequencerModel>(context, listen: false);
                                  _showTrackSelectionDialog(context, sequencerModel);
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