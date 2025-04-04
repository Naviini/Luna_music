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
  final Map<String, String> drumToSound = {
    'kick': 'drum/R8-Kick-1.wav',
    'snare': 'drum/R8-Snare-1.wav',
    'hihat': 'drum/R8-Cl-Hi-Hat.wav',
    'clap': 'drum/R8-808-1.wav',
  };
  
  final List<String> notes = [
    'C3', 'C#3', 'D3', 'D#3', 'E3', 'F3', 'F#3', 'G3', 'G#3', 'A3', 'A#3', 'B3', 'C4', 'C#4', 'D4', 'D#4'
  ];

  final List<String> drums = ['kick', 'snare', 'hihat', 'clap'];

  // Add these properties at the start of SequencerModel class
  String currentTrackName = 'Untitled Track';
  Map<String, dynamic> currentTrackMetadata = {
    'tempo': 120.0,
    'key': 'C',
    'scale': 'Major',
    'rhythm': '4/4',
    'lastModified': DateTime.now().toIso8601String(),
  };

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
          playDrum(drums[i], layer.volume);
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
          playDrum(drums[drumIndex], layers[activeLayerIndex].volume);
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

  Future<void> playDrum(String drum, double layerVolume) async {
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

  Future<void> saveSequence({String? trackName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Update track name if provided
    if (trackName != null) {
      currentTrackName = trackName;
    }

    // Update metadata
    currentTrackMetadata = {
      'tempo': tempo,
      'key': 'C', // Update with actual key when implemented
      'scale': 'Major', // Update with actual scale when implemented
      'rhythm': '4/4', // Update with actual rhythm when implemented
      'lastModified': DateTime.now().toIso8601String(),
    };

    // Create track data structure
    Map<String, dynamic> trackData = {
      'name': currentTrackName,
      'metadata': currentTrackMetadata,
      'layers': layers.map((layer) => {
        'name': layer.name,
        'instrument': layer.instrument,
        'grid': layer.grid,
        'volume': layer.volume,
        'isMuted': layer.isMuted,
      }).toList(),
    };

    // Get existing tracks or initialize empty list
    List<String> savedTracks = prefs.getStringList('saved_tracks') ?? [];
    Map<String, String> trackContents = {};

    // Load existing track contents
    for (String trackKey in savedTracks) {
      String? content = prefs.getString('track_$trackKey');
      if (content != null) {
        trackContents[trackKey] = content;
      }
    }

    // Add or update current track
    String trackKey = currentTrackName.replaceAll(' ', '_').toLowerCase();
    trackContents[trackKey] = _encodeTrackData(trackData);
    savedTracks = trackContents.keys.toList();

    // Save track list and contents
    await prefs.setStringList('saved_tracks', savedTracks);
    await prefs.setString('track_$trackKey', trackContents[trackKey]!);

    // Save current track name
    await prefs.setString('current_track', currentTrackName);
  }

  // Add helper method to encode track data
  String _encodeTrackData(Map<String, dynamic> trackData) {
    return trackData.toString(); // For simplicity. Consider using json.encode for proper serialization
  }

  // Add method to load saved tracks
  Future<List<Map<String, String>>> getSavedTracks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedTracks = prefs.getStringList('saved_tracks') ?? [];
    List<Map<String, String>> trackList = [];

    for (String trackKey in savedTracks) {
      String? trackContent = prefs.getString('track_$trackKey');
      if (trackContent != null) {
        // Extract track name and last modified date
        Map<String, dynamic> trackData = _decodeTrackData(trackContent);
        trackList.add({
          'name': trackData['name'] ?? 'Untitled',
          'lastModified': trackData['metadata']?['lastModified'] ?? DateTime.now().toIso8601String(),
        });
      }
    }

    return trackList;
  }

  // Add helper method to decode track data
  Map<String, dynamic> _decodeTrackData(String trackContent) {
    // For simplicity. Consider using json.decode for proper deserialization
    try {
      // Basic string to map conversion
      return {'name': trackContent.split("'name': '")[1].split("'")[0]};
    } catch (e) {
      return {'name': 'Untitled'};
    }
  }

  // Add method to load a specific track
  Future<bool> loadTrack(String trackName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trackKey = trackName.replaceAll(' ', '_').toLowerCase();
    String? trackContent = prefs.getString('track_$trackKey');

    if (trackContent != null) {
      try {
        Map<String, dynamic> trackData = _decodeTrackData(trackContent);
        currentTrackName = trackData['name'] ?? 'Untitled Track';
        currentTrackMetadata = trackData['metadata'] ?? {};
        
        // Load track settings
        tempo = currentTrackMetadata['tempo'] ?? 120.0;
        // Add other settings when implemented
        
        // Load layers
        List<dynamic> layerData = trackData['layers'] ?? [];
        layers.clear();
        for (var data in layerData) {
          layers.add(Layer(
            name: data['name'] ?? 'Untitled Layer',
            instrument: data['instrument'] ?? 'Piano',
            grid: List<bool>.from(data['grid'] ?? []),
            volume: data['volume'] ?? 50.0,
            isMuted: data['isMuted'] ?? false,
          ));
        }

        if (layers.isEmpty) {
          addLayer('Layer 1', 'Piano');
        }
        
        activeLayerIndex = 0;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error loading track: $e');
        return false;
      }
    }
    return false;
  }

  // Add method to delete a track
  Future<bool> deleteTrack(String trackName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trackKey = trackName.replaceAll(' ', '_').toLowerCase();
    
    // Get existing tracks
    List<String> savedTracks = prefs.getStringList('saved_tracks') ?? [];
    if (savedTracks.contains(trackKey)) {
      savedTracks.remove(trackKey);
      await prefs.setStringList('saved_tracks', savedTracks);
      await prefs.remove('track_$trackKey');
      return true;
    }
    return false;
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

  void clearGrid() {
    if (activeLayerIndex < layers.length) {
      for (int i = 0; i < layers[activeLayerIndex].grid.length; i++) {
        layers[activeLayerIndex].grid[i] = false;
      }
      notifyListeners();
    }
  }

  // Add clearLayerGrid method
  void clearLayerGrid(int index) {
    if (index >= 0 && index < layers.length) {
      for (int i = 0; i < layers[index].grid.length; i++) {
        layers[index].grid[i] = false;
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