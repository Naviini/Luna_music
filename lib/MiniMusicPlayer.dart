import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_player_state.dart';

class MiniMusicPlayer extends StatelessWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<AppPlayerState>(context);
    final theme = Theme.of(context);

    if (!playerState.isMiniPlayerVisible || playerState.currentAudioUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        playerState.showFullPlayer();
      },
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
            // Album Art with Progress Indicator
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 76, 150, 175)),
                  ),
                ],
              ),
            ),

            // Song Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
            ),

            // Controls
            Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.skip_previous, size: 28),
      color: theme.iconTheme.color,
      onPressed: playerState.previousSong, // Ensure this function is properly set
    ),
    IconButton(
      icon: Icon(
        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
        color: theme.iconTheme.color,
        size: 28,
      ),
      onPressed: playerState.togglePlay,
    ),
    IconButton(
      icon: const Icon(Icons.skip_next, size: 28),
      color: theme.iconTheme.color,
      onPressed: playerState.nextSong,
    ),
  ],
),

          ],
        ),
      ),
    );
  }
}
