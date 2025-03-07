import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luna/widgets/instrument_selector.dart';
import 'package:luna/widgets/sequencer_grid.dart';
import '../models/sequencer_model.dart';

class SequencerGridScreen extends StatefulWidget {
  @override
  _SequencerGridScreenState createState() => _SequencerGridScreenState();
}

class _SequencerGridScreenState extends State<SequencerGridScreen> with SingleTickerProviderStateMixin {
  late SequencerModel _sequencer;
  double _tempo = 120.0;
  double _volume = 1.0;
  String? selectedOption;
  String? selectedScale;
  String? selectedKey;
  String? selectedRhythm;
  final TextEditingController _tempoController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  // Add preferences state
  bool showMetronome = true;
  bool showNoteNames = true;
  bool snapToGrid = true;
  bool loopPlayback = true;
  bool showChordSuggestions = false;
  bool autoSave = true;
  bool isPreferencesExpanded = false;

  @override
  void initState() {
    super.initState();
    _sequencer = SequencerModel(tickerProvider: this);
    _tempoController.text = _tempo.round().toString();
    _volumeController.text = (_volume * 100).round().toString();
  }

  @override
  void dispose() {
    _tempoController.dispose();
    _volumeController.dispose();
    _sequencer.dispose();
    super.dispose();
  }

  void _updateTempoFromInput(String value) {
    final newTempo = double.tryParse(value);
    if (newTempo != null && newTempo >= 60 && newTempo <= 180) {
      setState(() {
        _tempo = newTempo;
        _sequencer.updateTempo(newTempo);
      });
    }
  }

  void _updateVolumeFromInput(String value) {
    final newVolume = double.tryParse(value);
    if (newVolume != null && newVolume >= 0 && newVolume <= 100) {
      setState(() {
        _volume = newVolume / 100;
        _sequencer.updateVolume(_volume);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sequencer,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Music Sequencer"),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Consumer<SequencerModel>(
              builder: (context, sequencer, child) {
                return InstrumentSelector(
                  selectedInstrument: sequencer.selectedInstrument,
                  onInstrumentChanged: sequencer.updateInstrument,
                );
              },
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: SequencerGrid(),
                  ),
                  
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.deepPurpleAccent.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<SequencerModel>(
                              builder: (context, sequencer, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tempo',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.speed, color: Colors.white, size: 20),
                                        Expanded(
                                          child: Slider(
                                            value: _tempo,
                                            min: 60.0,
                                            max: 180.0,
                                            divisions: 120,
                                            onChanged: (newTempo) {
                                              setState(() {
                                                _tempo = newTempo;
                                                _tempoController.text = newTempo.round().toString();
                                                sequencer.updateTempo(newTempo);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _tempoController,
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(
                                              suffix: Text('BPM', style: TextStyle(color: Colors.white, fontSize: 12)),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                            ),
                                            onChanged: _updateTempoFromInput,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    const Text(
                                      'Volume',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.volume_up, color: Colors.white, size: 20),
                                        Expanded(
                                          child: Slider(
                                            value: _volume,
                                            min: 0.0,
                                            max: 1.0,
                                            divisions: 100,
                                            onChanged: (newVolume) {
                                              setState(() {
                                                _volume = newVolume;
                                                _volumeController.text = (newVolume * 100).round().toString();
                                                sequencer.updateVolume(newVolume);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _volumeController,
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(
                                              suffix: Text('%', style: TextStyle(color: Colors.white, fontSize: 12)),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                            ),
                                            onChanged: _updateVolumeFromInput,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Dropdowns section
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabeledDropdown("Key", selectedKey, ['C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B'],
                                      (value) => setState(() {
                                        selectedKey = value;
                                        _sequencer.updateKey(value);
                                      })),
                                  const SizedBox(height: 10),
                                  _buildLabeledDropdown("Scale", selectedScale, ['Major', 'Minor', 'Pentatonic', 'Blues'],
                                      (value) => setState(() {
                                        selectedScale = value;
                                        _sequencer.updateScale(value);
                                      })),
                                  const SizedBox(height: 10),
                                  _buildLabeledDropdown("Rhythm", selectedRhythm, ['4/4', '3/4', '6/8', '5/4', '7/8'],
                                      (value) => setState(() {
                                        selectedRhythm = value;
                                        _sequencer.updateRhythm(value);
                                      })),
                                  const SizedBox(height: 10),
                                  _buildLabeledDropdown("Options", selectedOption, ['Create Blank Song', 'Export MP3', 'Upload Song'],
                                      (value) {
                                        setState(() {
                                          selectedOption = value;
                                          if (value == 'Create Blank Song') {
                                            _sequencer.clearGrid();
                                          }
                                        });
                                      }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Preferences section with expansion capability
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isPreferencesExpanded = !isPreferencesExpanded;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Preferences',
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                        Icon(
                                          isPreferencesExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isPreferencesExpanded) ...[
                                    CheckboxListTile(
                                      title: const Text('Show Metronome', style: TextStyle(color: Colors.white)),
                                      value: showMetronome,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          showMetronome = value ?? false;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Show Note Names', style: TextStyle(color: Colors.white)),
                                      value: showNoteNames,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          showNoteNames = value ?? false;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Snap to Grid', style: TextStyle(color: Colors.white)),
                                      value: snapToGrid,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          snapToGrid = value ?? false;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Loop Playback', style: TextStyle(color: Colors.white)),
                                      value: loopPlayback,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          loopPlayback = value ?? false;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Show Chord Suggestions', style: TextStyle(color: Colors.white)),
                                      value: showChordSuggestions,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          showChordSuggestions = value ?? false;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Auto Save', style: TextStyle(color: Colors.white)),
                                      value: autoSave,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          autoSave = value ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Consumer<SequencerModel>(
                              builder: (context, sequencer, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildControlButton(
                                      icon: Icons.first_page,
                                      color: Colors.blue,
                                      onPressed: () {
                                        sequencer.stopSequencer();
                                        sequencer.currentStep = 0;
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    _buildControlButton(
                                      icon: sequencer.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.green,
                                      onPressed: () {
                                        sequencer.isPlaying ? sequencer.stopSequencer() : sequencer.startSequencer();
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    _buildControlButton(
                                      icon: Icons.stop,
                                      color: Colors.red,
                                      onPressed: sequencer.stopSequencer,
                                    ),
                                    const SizedBox(width: 20),
                                    _buildControlButton(
                                      icon: Icons.last_page,
                                      color: Colors.blue,
                                      onPressed: () {
                                        sequencer.stopSequencer();
                                        sequencer.currentStep = SequencerModel.numSteps - 1;
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required void Function() onPressed}) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed,
      iconSize: 32,
    );
  }

  Widget _buildLabeledDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            dropdownColor: Colors.black87,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}