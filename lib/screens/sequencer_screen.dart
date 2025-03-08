import 'package:flutter/material.dart';
import 'sequencer_grid_screen.dart'; 

class SequencerScreen extends StatelessWidget {
  const SequencerScreen({super.key});

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Tap cells to create beats'),
              Text('2. Use different rows for different instruments'),
              Text('3. Press play to hear your creation'),
              Text('4. Save your beats to access them later'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Music'),
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showTutorial(context),
            tooltip: 'Show Tutorial',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1), //0.8
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.queue_music,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Create Your Music",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureButton(
                              context,
                              'New Track',
                              Icons.add_circle_outline,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SequencerGridScreen()),
                                );
                              },
                            ),
                            _buildFeatureButton(
                              context,
                              'Load Track',
                              Icons.folder_open,
                              () {
                                // TODO: Implement load functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                            _buildFeatureButton(
                              context,
                              'Templates',
                              Icons.library_music,
                              () {
                                // TODO: Implement templates functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                            _buildFeatureButton(
                              context,
                              'Settings',
                              Icons.settings,
                              () {
                                // TODO: Implement settings functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '🎵 Pro tip: Tap the help icon for a quick tutorial!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 52), // v-12
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), //15
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        elevation: 12, // Increased elevation
        shadowColor: Colors.black.withOpacity(0.5), // More pronounced shadow
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white), // Larger icon
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
// class SequencerScreen extends StatelessWidget {
//   const SequencerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Music'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Theme.of(context).primaryColor.withOpacity(0.8),
//               Theme.of(context).primaryColor.withOpacity(0.2),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Card(
//             elevation: 8,
//             margin: const EdgeInsets.all(16),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.queue_music,
//                     size: 100,
//                     color: Colors.deepPurple,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     "Start Creating Your Track",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Create amazing beats with our intuitive sequencer",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SequencerGridScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     icon: const Icon(Icons.play_circle_filled),
//                     label: const Text(
//                       "Open Sequencer",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }