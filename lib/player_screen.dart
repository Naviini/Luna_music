
import 'package:flutter/material.dart';
 import 'package:audioplayers/audioplayers.dart';
 
 class MusicPlayerPage extends StatefulWidget {
   final String title;
   final String artist;
   final String imageUrl;
   final String url;
   final Function onNext;
   final Function onPrevious;
 
   const MusicPlayerPage({
     super.key,
     required this.title,
     required this.artist,
     required this.imageUrl,
     required this.url,
     required this.onNext,
     required this.onPrevious,
   });
 
   @override
   _MusicPlayerPageState createState() => _MusicPlayerPageState();
 }
 
 class _MusicPlayerPageState extends State<MusicPlayerPage> {
   late AudioPlayer _audioPlayer;
   bool isPlaying = false;
   Duration duration = Duration.zero;
   Duration position = Duration.zero;
 
   @override
   void initState() {
     super.initState();
     _audioPlayer = AudioPlayer();
 
     _audioPlayer.onDurationChanged.listen((newDuration) {
       setState(() {
         duration = newDuration;
       });
     });
 
     _audioPlayer.onPositionChanged.listen((newPosition) {
       setState(() {
         position = newPosition;
       });
     });
 
     _audioPlayer.onPlayerComplete.listen((event) {
       widget.onNext(); // Auto-play next song when current ends
     });
 
     _playMusic();
   }
 
   void _playMusic() async {
     await _audioPlayer.play(UrlSource(widget.url));
     setState(() {
       isPlaying = true;
     });
   }
 
   void _pauseMusic() async {
     await _audioPlayer.pause();
     setState(() {
       isPlaying = false;
     });
   }
 
   void _resumeMusic() async {
     await _audioPlayer.resume();
     setState(() {
       isPlaying = true;
     });
   }
 
   @override
   void dispose() {
     _audioPlayer.dispose();
     super.dispose();
   }
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.black,
       appBar: AppBar(
         backgroundColor: Colors.transparent,
         elevation: 0,
         centerTitle: true,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.pop(context),
         ),
       ),
       body: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           // Album Cover
           Container(
             margin: const EdgeInsets.symmetric(horizontal: 20),
             width: 300,
             height: 300,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20),
               image: DecorationImage(
                 image: AssetImage(widget.imageUrl),
                 fit: BoxFit.cover,
               ),
             ),
           ),
           const SizedBox(height: 20),
           
           // Song Title and Artist
           Text(widget.title,
               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
           Text(widget.artist, style: const TextStyle(fontSize: 18, color: Colors.white70)),
 
           const SizedBox(height: 20),
 
           // Progress Bar
           Slider(
             min: 0,
             max: duration.inSeconds.toDouble(),
             value: position.inSeconds.toDouble(),
             activeColor: Colors.green,
             inactiveColor: Colors.white24,
             onChanged: (value) async {
               final newPosition = Duration(seconds: value.toInt());
               await _audioPlayer.seek(newPosition);
               setState(() {
                 position = newPosition;
               });
             },
           ),
 
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               Text(
                 _formatDuration(position),
                 style: const TextStyle(color: Colors.white70),
               ),
               Text(
                 _formatDuration(duration),
                 style: const TextStyle(color: Colors.white70),
               ),
             ],
           ),
 
           const SizedBox(height: 10),
 
           // Music Controls
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               IconButton(
                 icon: const Icon(Icons.skip_previous, color: Colors.white, size: 50),
                 onPressed: () => widget.onPrevious(),
               ),
               IconButton(
                 icon: Icon(
                   isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                   color: Colors.green,
                   size: 60,
                 ),
                 onPressed: () {
                   if (isPlaying) {
                     _pauseMusic();
                   } else {
                     _resumeMusic();
                   }
                 },
               ),
               IconButton(
                 icon: const Icon(Icons.skip_next, color: Colors.white, size: 50),
                 onPressed: () => widget.onNext(),
               ),
             ],
           ),
         ],
       ),
     );
   }
 
   String _formatDuration(Duration duration) {
     String minutes = duration.inMinutes.toString().padLeft(2, '0');
     String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
     return "$minutes:$seconds";
   }
 }

