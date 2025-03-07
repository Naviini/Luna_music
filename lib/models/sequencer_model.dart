import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SequencerModel extends ChangeNotifier {
  bool isPlaying = false;
  int currentStep = 0;
  double tempo = 120.0;
  late Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Reused instance

  static const int numSteps = 16;  // 16 steps in the sequencer
  static const int numNotes = 16;  // 16 notes for each step
  final List<bool> grid = List.generate(numSteps * numNotes, (_) => false);

  String selectedInstrument = 'Piano';
  String currentNote = 'C3';

  final Map<String, String> noteToSound = {};
  final List<String> notes = [
    'C3', 'C#3', 'D3', 'D#3', 'E3', 'F3', 'F#3', 'G3', 'G#3', 'A3', 'A#3', 'B3', 'C4', 'C#4', 'D4', 'D#4'
  ];

  SequencerModel({required TickerProvider tickerProvider}) {
    _ticker = tickerProvider.createTicker((elapsed) {
      int stepDuration = (60000 ~/ tempo ~/ numSteps);
      int step = (elapsed.inMilliseconds ~/ stepDuration) % numSteps;

      // Update current step based on elapsed time, this ensures sequential playback
      if (step != currentStep) {
        currentStep = step;

        // Play only notes that are selected for the current step
        for (int i = 0; i < numNotes; i++) {
          int index = currentStep + (i * numSteps);
          if (grid[index]) {
            _playNote(notes[i]);
            currentNote = notes[i];
          }
        }
        notifyListeners();
      }
    });
    _updateInstrumentSounds();
  }

  void toggleNote(int index) {
    grid[index] = !grid[index];
    notifyListeners();
    if (grid[index]) _playNote(notes[index ~/ numSteps]);
  }

  Future<void> _playNote(String note) async {
    if (!noteToSound.containsKey(note)) return;
    try {
      await _audioPlayer.play(AssetSource(noteToSound[note]!));
    } catch (e) {
      debugPrint('Error playing $note: $e');
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
    await prefs.setString('sequence', grid.join(','));
  }

  Future<void> loadSequence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedSequence = prefs.getString('sequence');
    if (savedSequence != null) {
      List<bool> newGrid = savedSequence.split(',').map((e) => e == 'true').toList();
      grid.setAll(0, newGrid);
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

  void clearGrid() {
    for (int i = 0; i < grid.length; i++) {
      grid[i] = false;
    }
    notifyListeners();
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
  
    void updateVolume(double newTempo) {
    tempo = newTempo;
    notifyListeners();
  }

}