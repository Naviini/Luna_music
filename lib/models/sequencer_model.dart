import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Layer {
  String name;
  String instrument;
  List<bool> grid;
  double volume;
  bool isMuted;

  Layer({
    required this.name,
    required this.instrument,
    required this.grid,
    this.volume = 50.0,
    this.isMuted = false,
  });
}

class SequencerModel extends ChangeNotifier {
  bool isPlaying = false;
  int currentStep = 0;
  double tempo = 120.0;
  double volume = 50.0;
  late Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Reused instance

  static const int numSteps = 16;  // 16 steps in the sequencer
  static const int numNotes = 16;  // 16 notes for each step
  static const int numDrums = 4;   // 4 drum types
  static const int maxLayers = 8;  // Maximum number of layers

  // Layer management
  List<Layer> layers = [];
  int activeLayerIndex = 0;

  String selectedInstrument = 'Piano';
  String currentNote = 'C3';

  final Map<String, String> noteToSound = {};
  final Map<String, String> drumToSound = {};
  final List<String> notes = [
    'C3', 'C#3', 'D3', 'D#3', 'E3', 'F3', 'F#3', 'G3', 'G#3', 'A3', 'A#3', 'B3', 'C4', 'C#4', 'D4', 'D#4'
  ];

  final List<String> drums = ['kick', 'snare', 'hihat', 'clap'];

  SequencerModel({required TickerProvider tickerProvider}) {
    _ticker = tickerProvider.createTicker((elapsed) {
      int stepDuration = (60000 ~/ tempo ~/ numSteps);
      int step = (elapsed.inMilliseconds ~/ stepDuration) % numSteps;

      if (step != currentStep) {
        currentStep = step;
        _playCurrentStep();
        notifyListeners();
      }
    });
    
    // Initialize with a default layer
    addLayer('Layer 1', 'Piano');
    _updateInstrumentSounds();
    _updateDrumSounds();
  }

  void _playCurrentStep() {
    for (var layer in layers) {
      if (layer.isMuted) continue;
      
      // Play notes
      for (int i = 0; i < numNotes; i++) {
        int index = currentStep + (i * numSteps);
        if (layer.grid[index]) {
          _playNote(layer.instrument, notes[i], layer.volume);
        }
      }

      // Play drums
      for (int i = 0; i < numDrums; i++) {
        int index = currentStep + ((numNotes + i) * numSteps);
        if (layer.grid[index]) {
          _playDrum(drums[i], layer.volume);
        }
      }
    }
  }

  void addLayer(String name, String instrument) {
    if (layers.length >= maxLayers) return;
    
    layers.add(Layer(
      name: name,
      instrument: instrument,
      grid: List.generate(numSteps * (numNotes + numDrums), (_) => false),
    ));
    notifyListeners();
  }

  void removeLayer(int index) {
    if (layers.length <= 1) return; // Keep at least one layer
    layers.removeAt(index);
    if (activeLayerIndex >= layers.length) {
      activeLayerIndex = layers.length - 1;
    }
    notifyListeners();
  }

  void setActiveLayer(int index) {
    if (index >= 0 && index < layers.length) {
      activeLayerIndex = index;
      notifyListeners();
    }
  }

  void toggleLayerMute(int index) {
    if (index >= 0 && index < layers.length) {
      layers[index].isMuted = !layers[index].isMuted;
      notifyListeners();
    }
  }

  void updateLayerVolume(int index, double volume) {
    if (index >= 0 && index < layers.length) {
      layers[index].volume = volume;
      notifyListeners();
    }
  }

  void updateLayerInstrument(int index, String instrument) {
    if (index >= 0 && index < layers.length) {
      layers[index].instrument = instrument;
      notifyListeners();
    }
  }

  void toggleNote(int index) {
    if (activeLayerIndex < layers.length) {
      layers[activeLayerIndex].grid[index] = !layers[activeLayerIndex].grid[index];
      notifyListeners();
      
      if (layers[activeLayerIndex].grid[index]) {
        if (index < numSteps * numNotes) {
          _playNote(layers[activeLayerIndex].instrument, notes[index ~/ numSteps], layers[activeLayerIndex].volume);
        } else {
          int drumIndex = (index ~/ numSteps) - numNotes;
          _playDrum(drums[drumIndex], layers[activeLayerIndex].volume);
        }
      }
    }
  }

  Future<void> _playNote(String instrument, String note, double layerVolume) async {
    if (!noteToSound.containsKey(note)) return;
    try {
      await _audioPlayer.setVolume((volume / 100) * (layerVolume / 100));
      await _audioPlayer.play(AssetSource(noteToSound[note]!));
    } catch (e) {
      debugPrint('Error playing $note: $e');
    }
  }

  Future<void> _playDrum(String drum, double layerVolume) async {
    if (!drumToSound.containsKey(drum)) return;
    try {
      await _audioPlayer.setVolume((volume / 100) * (layerVolume / 100));
      await _audioPlayer.play(AssetSource(drumToSound[drum]!));
    } catch (e) {
      debugPrint('Error playing $drum: $e');
    }
  }

  void startSequencer() {
    if (isPlaying) return;
    isPlaying = true;
    currentStep = 0;
    _ticker.start();
    notifyListeners();
  }

  void stopSequencer() {
    _ticker.stop();
    isPlaying = false;
    currentStep = 0;
    notifyListeners();
  }

  void updateTempo(double newTempo) {
    tempo = newTempo;
    notifyListeners();
  }

  Future<void> saveSequence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save all layers
    List<String> layerData = [];
    for (var layer in layers) {
      layerData.add('${layer.name}|${layer.instrument}|${layer.grid.join(',')}|${layer.volume}|${layer.isMuted}');
    }
    await prefs.setStringList('layers', layerData);
  }

  Future<void> loadSequence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? layerData = prefs.getStringList('layers');
    if (layerData != null) {
      layers.clear();
      for (var data in layerData) {
        var parts = data.split('|');
        if (parts.length >= 5) {
          List<bool> grid = parts[2].split(',').map((e) => e.trim().toLowerCase() == 'true').toList();
          layers.add(Layer(
            name: parts[0],
            instrument: parts[1],
            grid: grid,
            volume: double.parse(parts[3]),
            isMuted: parts[4].toLowerCase() == 'true',
          ));
        }
      }
      if (layers.isNotEmpty) {
        activeLayerIndex = 0;
      }
      notifyListeners();
    }
  }

  void updateInstrument(String instrument) {
    selectedInstrument = instrument;
    _updateInstrumentSounds();
    notifyListeners();
  }

  void _updateInstrumentSounds() {
    noteToSound.clear();
    String path = selectedInstrument.toLowerCase();
    for (String note in notes) {
      noteToSound[note] = '$path/$note.mp3';
    }
  }

  void _updateDrumSounds() {
    drumToSound.clear();
    for (String drum in drums) {
      drumToSound[drum] = 'drums/$drum.mp3';
    }
  }

  void clearGrid() {
    if (activeLayerIndex < layers.length) {
      for (int i = 0; i < layers[activeLayerIndex].grid.length; i++) {
        layers[activeLayerIndex].grid[i] = false;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void updateScale(String? newScale) {
    // Logic to update the scale
    notifyListeners(); // Notify listeners about the change
  }

  void updateKey(String? newScale) {
    // Logic to update the scale
    notifyListeners(); // Notify listeners about the change
  }

  void updateRhythm(String? newScale) {
    // Logic to update the scale
    notifyListeners(); // Notify listeners about the change
  }
  
  void updateVolume(double newVolume) {
    volume = newVolume;
    _audioPlayer.setVolume(volume / 100);
    notifyListeners();
  }
}