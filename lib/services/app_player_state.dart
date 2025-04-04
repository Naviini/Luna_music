import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AppPlayerState with ChangeNotifier {
  bool _isMiniPlayerVisible = false;
  bool _isFullScreenPlayerVisible = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _currentTitle = '';
  String _currentArtist = '';
  String _currentImageUrl = '';
  String _currentAudioUrl = '';
  Function? _onNext;
  Function? _onPrevious;
  late final AudioPlayer _audioPlayer;

  AppPlayerState() {
    _audioPlayer = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
    
    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_onNext != null) _onNext!();
    });
  }

  // Getters
  bool get isMiniPlayerVisible => _isMiniPlayerVisible;
  bool get isFullScreenPlayerVisible => _isFullScreenPlayerVisible;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentArtist => _currentArtist;
  String get currentImageUrl => _currentImageUrl;
  String get currentAudioUrl => _currentAudioUrl;

  Future<void> play(
    String title,
    String artist,
    String imageUrl,
    String audioUrl, {
    Function? onNext,
    Function? onPrevious,
  }) async {
    _currentTitle = title;
    _currentArtist = artist;
    _currentImageUrl = imageUrl;
    _currentAudioUrl = audioUrl;
    _onNext = onNext;
    _onPrevious = onPrevious;

    _isMiniPlayerVisible = true;
    _isFullScreenPlayerVisible = false;
    
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void nextSong() {
    if (_onNext != null) {
      _onNext!();
    } else {
      debugPrint("Next song function is not set");
    }
  }

  void previousSong() {
    if (_onPrevious != null) {
      _onPrevious!();
    } else {
      debugPrint("Previous song function is not set");
    }
  }

  void showFullPlayer() {
    _isFullScreenPlayerVisible = true;
    notifyListeners();
  }

  void hideFullPlayer() {
    _isFullScreenPlayerVisible = false;
    notifyListeners();
  }

  void toggleMiniPlayer() {
    _isMiniPlayerVisible = !_isMiniPlayerVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
