import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sequencer_model.dart';
import '../widgets/sequencer_grid.dart';
import '../widgets/drum_grid.dart';

class SequencerGridScreen extends StatefulWidget {
  const SequencerGridScreen({super.key});

  @override
  State<SequencerGridScreen> createState() => _SequencerGridScreenState();
}

class _SequencerGridScreenState extends State<SequencerGridScreen> with SingleTickerProviderStateMixin {
  late final SequencerModel _sequencerModel;

  @override
  void initState() {
    super.initState();
    _sequencerModel = SequencerModel(tickerProvider: this);
  }

  @override
  void dispose() {
    _sequencerModel.dispose();
    super.dispose();
  }

  void _showAddLayerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String layerName = 'Layer ${_sequencerModel.layers.length + 1}';
        String selectedInstrument = 'Piano';
        
        return AlertDialog(
          title: const Text('Add New Layer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Layer Name'),
                onChanged: (value) => layerName = value,
                controller: TextEditingController(text: layerName),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedInstrument,
                isExpanded: true,
                items: ['Piano', 'Guitar', 'Bass', 'Drums']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedInstrument = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _sequencerModel.addLayer(layerName, selectedInstrument);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveLayerDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Layer'),
          content: Text('Are you sure you want to remove ${_sequencerModel.layers[index].name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _sequencerModel.removeLayer(index);
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showClearGridDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Clear Grid',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to clear all notes from ${_sequencerModel.layers[index].name}?\nThis action cannot be undone.',
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
              onPressed: () {
                _sequencerModel.clearLayerGrid(index);
                Navigator.pop(context);
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSaveTrackDialog() {
    String trackName = _sequencerModel.currentTrackName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Save Track',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: trackName),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Track Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (value) => trackName = value,
              ),
              const SizedBox(height: 16),
              Text(
                'Track will be saved with the following settings:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '• Tempo: ${_sequencerModel.tempo.round()} BPM\n'
                '• Key: ${_sequencerModel.currentTrackMetadata['key']}\n'
                '• Scale: ${_sequencerModel.currentTrackMetadata['scale']}\n'
                '• Rhythm: ${_sequencerModel.currentTrackMetadata['rhythm']}\n'
                '• Layers: ${_sequencerModel.layers.length}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
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
                if (trackName.isNotEmpty) {
                  await _sequencerModel.saveSequence(trackName: trackName);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Track "$trackName" saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadTrackDialog() async {
    final tracks = await _sequencerModel.getSavedTracks();
    if (!mounted) return;

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
                      final updatedTracks = await _sequencerModel.getSavedTracks();
                      if (mounted) {
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
                                    onPressed: () => _showDeleteTrackDialog(track['name'] ?? ''),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showRenameTrackDialog(track['name'] ?? ''),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final success = await _sequencerModel.loadTrack(track['name'] ?? '');
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Track "${track['name']}" loaded successfully'
                                            : 'Failed to load track "${track['name']}"',
                                      ),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
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

  void _showDeleteTrackDialog(String trackName) {
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
                final success = await _sequencerModel.deleteTrack(trackName);
                if (mounted) {
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
                  // Refresh the load dialog
                  _showLoadTrackDialog();
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

  void _showRenameTrackDialog(String currentName) {
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
                  await _sequencerModel.saveSequence(trackName: newName);
                  // Delete the old track
                  await _sequencerModel.deleteTrack(currentName);
                  if (mounted) {
                    Navigator.pop(context); // Close rename dialog
                    Navigator.pop(context); // Close load dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Track renamed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the load dialog
                    _showLoadTrackDialog();
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
    return ChangeNotifierProvider.value(
      value: _sequencerModel,
      child: Consumer<SequencerModel>(
        builder: (context, sequencer, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  // Layer controls
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        // Layer selector
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: sequencer.layers.length,
                            itemBuilder: (context, index) {
                              final layer = sequencer.layers[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: InkWell(
                                  onTap: () => sequencer.setActiveLayer(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: sequencer.activeLayerIndex == index
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          layer.isMuted ? Icons.volume_off : Icons.volume_up,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          layer.name,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        if (sequencer.layers.length > 1) // Only show remove button if more than one layer
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                            onPressed: () => _showRemoveLayerDialog(index),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        // Add clear grid button
                                        IconButton(
                                          icon: const Icon(Icons.clear_all, color: Colors.white, size: 16),
                                          onPressed: () => _showClearGridDialog(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Clear Grid',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Add layer button
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _showAddLayerDialog,
                        ),
                      ],
                    ),
                  ),
                  // Layer controls
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        // Instrument selector for active layer
                        if (sequencer.layers.isNotEmpty)
                          Expanded(
                            child: DropdownButton<String>(
                              value: sequencer.layers[sequencer.activeLayerIndex].instrument,
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              items: ['Piano', 'Guitar', 'Bass', 'Drums']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  sequencer.updateLayerInstrument(
                                    sequencer.activeLayerIndex,
                                    newValue,
                                  );
                                }
                              },
                            ),
                          ),
                        // Layer volume control
                        if (sequencer.layers.isNotEmpty)
                          Expanded(
                            child: Slider(
                              value: sequencer.layers[sequencer.activeLayerIndex].volume,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: '${sequencer.layers[sequencer.activeLayerIndex].volume.round()}%',
                              onChanged: (value) {
                                sequencer.updateLayerVolume(
                                  sequencer.activeLayerIndex,
                                  value,
                                );
                              },
                            ),
                          ),
                        // Mute button
                        if (sequencer.layers.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              sequencer.layers[sequencer.activeLayerIndex].isMuted
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              sequencer.toggleLayerMute(sequencer.activeLayerIndex);
                            },
                          ),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Regular instrument grid
                          if (sequencer.layers.isNotEmpty &&
                              sequencer.layers[sequencer.activeLayerIndex].instrument != 'Drums')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SequencerGrid(),
                            ),
                          // Drum grid
                          if (sequencer.layers.isNotEmpty &&
                              sequencer.layers[sequencer.activeLayerIndex].instrument == 'Drums')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DrumGrid(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Add these buttons before the Controls section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Track'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showSaveTrackDialog(),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Load Track'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showLoadTrackDialog(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Controls section
                  ExpansionTile(
                    title: const Text(
                      'Controls',
                      style: TextStyle(color: Colors.white),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Tempo control
                            Row(
                              children: [
                                const Text(
                                  'Tempo:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: sequencer.tempo,
                                    min: 60,
                                    max: 200,
                                    divisions: 140,
                                    label: '${sequencer.tempo.round()} BPM',
                                    onChanged: (value) {
                                      sequencer.updateTempo(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // Volume control
                            Row(
                              children: [
                                const Text(
                                  'Volume:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: sequencer.volume,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label: '${sequencer.volume.round()}%',
                                    onChanged: (value) {
                                      sequencer.updateVolume(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Settings section
                  ExpansionTile(
                    title: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Preferences section
                                const Text(
                                  'Preferences',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Preferences toggles
                                SwitchListTile(
                                  title: const Text(
                                    'Auto Play on Load',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update auto play preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Show and Play the Same Bar',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: true,
                                  onChanged: (bool value) {
                                    // Update show and play preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Hear Preview of Added Notes',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: true,
                                  onChanged: (bool value) {
                                    // Update preview preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Show Piano Keys',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update piano keys preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Highlight "Fifth" of Song Key',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update highlight preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Allow Adding Notes Not in Scale',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update scale notes preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Use Current Scale as Default',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: true,
                                  onChanged: (bool value) {
                                    // Update default scale preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Show Notes From All Channels',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update show all notes preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                SwitchListTile(
                                  title: const Text(
                                    'Show Octave Scroll Bar',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  value: false,
                                  onChanged: (bool value) {
                                    // Update scroll bar preference
                                  },
                                  activeColor: Colors.blue,
                                ),
                                // Theme selection button
                                ListTile(
                                  title: const Text(
                                    'Light Theme',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  trailing: const Icon(
                                    Icons.brightness_6,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    // Toggle theme
                                  },
                                ),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 20),
                                // Song Settings section
                                const Text(
                                  'Song Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Scale selector
                                Row(
                                  children: [
                                    const Text(
                                      'Scale:  ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: 'Major',
                                        isExpanded: true,
                                        dropdownColor: Colors.grey[900],
                                        style: const TextStyle(color: Colors.white),
                                        items: ['Major', 'Minor', 'Pentatonic', 'Chromatic', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            sequencer.updateScale(newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Key selector
                                Row(
                                  children: [
                                    const Text(
                                      'Key:    ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: 'C',
                                        isExpanded: true,
                                        dropdownColor: Colors.grey[900],
                                        style: const TextStyle(color: Colors.white),
                                        items: ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            sequencer.updateKey(newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Tempo control with text
                                Row(
                                  children: [
                                    const Text(
                                      'Tempo:',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: sequencer.tempo,
                                        min: 60,
                                        max: 200,
                                        divisions: 140,
                                        label: '${sequencer.tempo.round()} BPM',
                                        onChanged: (value) {
                                          sequencer.updateTempo(value);
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${sequencer.tempo.round()}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Rhythm selector
                                Row(
                                  children: [
                                    const Text(
                                      'Rhythm:',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: '4/4',
                                        isExpanded: true,
                                        dropdownColor: Colors.grey[900],
                                        style: const TextStyle(color: Colors.white),
                                        items: ['4/4', '3/4', '6/8', '5/4', '7/8']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            sequencer.updateRhythm(newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Instrument Settings section
                                const Text(
                                  'Instrument Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Volume control
                                Row(
                                  children: [
                                    const Text(
                                      'Volume:',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: sequencer.volume,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: '${sequencer.volume.round()}%',
                                        onChanged: (value) {
                                          sequencer.updateVolume(value);
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${sequencer.volume.round()}%',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Instrument Type selector
                                Row(
                                  children: [
                                    const Text(
                                      'Type:   ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: 'Piano',
                                        isExpanded: true,
                                        dropdownColor: Colors.grey[900],
                                        style: const TextStyle(color: Colors.white),
                                        items: ['Piano', 'Guitar', 'Bass', 'Drums', 'Synth', 'Strings', 'Accordion']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            // Update instrument type
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Customize Instrument button
                                Center(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.tune),
                                    label: const Text('Customize Instrument'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomizeInstrumentDialog(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Playback controls
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: () {
                            // Previous step logic
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            sequencer.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (sequencer.isPlaying) {
                              sequencer.stopSequencer();
                            } else {
                              sequencer.startSequencer();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.white),
                          onPressed: () {
                            sequencer.stopSequencer();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: () {
                            // Next step logic
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomizeInstrumentDialog extends StatefulWidget {
  const CustomizeInstrumentDialog({super.key});

  @override
  _CustomizeInstrumentDialogState createState() => _CustomizeInstrumentDialogState();
}

class _CustomizeInstrumentDialogState extends State<CustomizeInstrumentDialog> {
  String type = 'chip wave';
  String wave = 'double saw';
  String unison = 'honky tonk';
  double eqFilter = 0.0;
  double fadeInOut = 0.0;
  double noteFilter = 0.0;
  double reverb = 0.0;
  bool effectsExpanded = false;
  bool envelopesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Customize Instrument',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Type selector
              const Text('Type:', style: TextStyle(color: Colors.white)),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: type,
                  isExpanded: true,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  items: ['chip wave', 'FM', 'harmonics', 'PWM', 'spectrum']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => type = newValue);
                    }
                  },
                ),
              ),

              // EQ Filter
              const Text('EQ Filter:', style: TextStyle(color: Colors.white)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: eqFilter,
                  min: 0,
                  max: 100,
                  onChanged: (value) => setState(() => eqFilter = value),
                ),
              ),

              // Fade In/Out
              const Text('Fade In/Out:', style: TextStyle(color: Colors.white)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: fadeInOut,
                  min: 0,
                  max: 100,
                  onChanged: (value) => setState(() => fadeInOut = value),
                ),
              ),

              // Wave selector
              const Text('Wave:', style: TextStyle(color: Colors.white)),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: wave,
                  isExpanded: true,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  items: ['double saw', 'square', 'triangle', 'sine', 'noise']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => wave = newValue);
                    }
                  },
                ),
              ),

              // Unison selector
              const Text('Unison:', style: TextStyle(color: Colors.white)),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: unison,
                  isExpanded: true,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  items: ['honky tonk', 'pure', 'shimmer', 'detuned']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => unison = newValue);
                    }
                  },
                ),
              ),

              // Effects section
              ExpansionTile(
                title: const Text('Effects', style: TextStyle(color: Colors.white)),
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                children: [
                  // Note Filter
                  const Text('Note Filter:', style: TextStyle(color: Colors.white)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: noteFilter,
                      min: 0,
                      max: 100,
                      onChanged: (value) => setState(() => noteFilter = value),
                    ),
                  ),

                  // Reverb
                  const Text('Reverb:', style: TextStyle(color: Colors.white)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: reverb,
                      min: 0,
                      max: 100,
                      onChanged: (value) => setState(() => reverb = value),
                    ),
                  ),
                ],
              ),

              // Envelopes section
              ExpansionTile(
                title: const Text('Envelopes', style: TextStyle(color: Colors.white)),
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // Add envelope logic
                      },
                    ),
                    const Icon(Icons.expand_more, color: Colors.white),
                  ],
                ),
                children: [
                  // Envelope items
                  ListTile(
                    title: const Text('n. filter freqs', style: TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        // Remove envelope logic
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('swell 1', style: TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        // Remove envelope logic
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}