import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_player_state.dart';

class MusicPlayerWrapper extends StatelessWidget {
  final Widget child;
  
  const MusicPlayerWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<AppPlayerState>(context);
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        child,
        if (playerState.isFullScreenPlayerVisible)
          _buildFullScreenPlayer(context, playerState, theme),
        if (playerState.isMiniPlayerVisible && !playerState.isFullScreenPlayerVisible)
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: _buildMiniPlayer(context, playerState, theme),
          ),
      ],
    );
  }

  Widget _buildFullScreenPlayer(BuildContext context, AppPlayerState playerState, ThemeData theme) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with collapse button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () {
                      playerState.hideFullPlayer();
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'NOW PLAYING',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          playerState.currentTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Album Art
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      playerState.currentImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.music_note, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // Song Info
                  Text(
                    playerState.currentTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playerState.currentArtist,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress Bar
                  Slider(
                    value: playerState.position.inSeconds.toDouble(),
                    min: 0,
                    max: playerState.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      playerState.seek(Duration(seconds: value.toInt()));
                    },
                    activeColor: const Color.fromARGB(255, 81, 190, 170),
                    inactiveColor: Colors.white24,
                  ),
                  const SizedBox(height: 24),
                  // Main Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                        onPressed: playerState.previousSong,
                      ),
                      IconButton(
                        icon: Icon(
                          playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 56,
                          color: const Color.fromARGB(255, 53, 174, 158),
                        ),
                        onPressed: playerState.togglePlay,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                        onPressed: playerState.nextSong,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, AppPlayerState playerState, ThemeData theme) {
    return GestureDetector(
      onTap: playerState.showFullPlayer,
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Album Art with Progress
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playerState.currentImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                  ),
                  CircularProgressIndicator(
                    value: playerState.duration.inSeconds > 0
                        ? playerState.position.inSeconds / playerState.duration.inSeconds
                        : 0,
                    strokeWidth: 2,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 36, 160, 152)),
                  ),
                ],
              ),
            ),
            // Song Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerState.currentTitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playerState.currentArtist,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: playerState.togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: theme.iconTheme.color,
                  onPressed: playerState.nextSong,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}