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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Scale selector
                            DropdownButton<String>(
                              value: 'Major',
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              items: ['Major', 'Minor', 'Pentatonic']
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
                            const SizedBox(height: 8),
                            // Key selector
                            DropdownButton<String>(
                              value: 'C',
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
                            const SizedBox(height: 8),
                            // Rhythm selector
                            DropdownButton<String>(
                              value: '4/4',
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              items: ['4/4', '3/4', '6/8']
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
                          ],
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