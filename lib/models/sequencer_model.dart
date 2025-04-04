import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Update track name if provided
      if (trackName != null) {
        currentTrackName = trackName;
      }

      // Validate track name
      if (currentTrackName.isEmpty) {
        throw Exception('Track name cannot be empty');
      }

      // Update metadata
      currentTrackMetadata = {
        'tempo': tempo,
        'key': currentTrackMetadata['key'] ?? 'C',
        'scale': currentTrackMetadata['scale'] ?? 'Major',
        'rhythm': currentTrackMetadata['rhythm'] ?? '4/4',
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
      String trackKey = currentTrackName.replaceAll(' ', '_').toLowerCase();

      // Add or update current track
      await prefs.setString('track_$trackKey', jsonEncode(trackData));
      
      // Update track list if it's a new track
      if (!savedTracks.contains(trackKey)) {
        savedTracks.add(trackKey);
        await prefs.setStringList('saved_tracks', savedTracks);
      }

      // Save current track name
      await prefs.setString('current_track', currentTrackName);
    } catch (e) {
      debugPrint('Error saving track: $e');
      rethrow;
    }
  }

  Future<bool> loadTrack(String trackName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String trackKey = trackName.replaceAll(' ', '_').toLowerCase();
      String? trackContent = prefs.getString('track_$trackKey');

      if (trackContent == null) {
        throw Exception('Track not found');
      }

      Map<String, dynamic> trackData = jsonDecode(trackContent);
      currentTrackName = trackData['name'] ?? 'Untitled Track';
      currentTrackMetadata = trackData['metadata'] ?? {};
      
      // Load track settings
      tempo = double.tryParse(currentTrackMetadata['tempo']?.toString() ?? '') ?? 120.0;
      
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

  Future<bool> deleteTrack(String trackName) async {
    try {
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
    } catch (e) {
      debugPrint('Error deleting track: $e');
      return false;
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

  Future<List<Map<String, dynamic>>> getSavedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tracks = prefs.getStringList('saved_tracks') ?? [];
      final List<Map<String, dynamic>> trackList = [];

      for (final trackName in tracks) {
        final trackData = prefs.getString('track_$trackName');
        if (trackData != null) {
          try {
            final Map<String, dynamic> track = jsonDecode(trackData);
            trackList.add({
              'name': trackName.replaceAll('_', ' '),
              'lastModified': track['metadata']?['lastModified'] ?? DateTime.now().toIso8601String(),
              'metadata': track['metadata'] ?? {},
            });
          } catch (e) {
            debugPrint('Error parsing track data for $trackName: $e');
          }
        }
      }

      // Sort tracks by last modified date (newest first)
      trackList.sort((a, b) {
        final dateA = DateTime.parse(a['lastModified'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(b['lastModified'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });

      return trackList;
    } catch (e) {
      debugPrint('Error getting saved tracks: $e');
      return [];
    }
  }
}