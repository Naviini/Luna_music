import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sequencer_model.dart';

class DrumGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SequencerModel>(
      builder: (context, sequencer, child) {
        if (sequencer.layers.isEmpty) {
          return const Center(
            child: Text(
              'Add a layer to start creating music',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final activeLayer = sequencer.layers[sequencer.activeLayerIndex];
        
        return Column(
          children: [
            // Header row showing beat numbers
            Row(
              children: [
                SizedBox(width: 60), // Space for drum labels
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: SequencerModel.numSteps,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: SequencerModel.numSteps,
                    itemBuilder: (context, step) {
                      return Center(
                        child: Text(
                          '${step + 1}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: step % 4 == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Drum grid
            for (int i = 0; i < 4; i++) // 4 drum types: Kick, Snare, Hi-hat, Clap
              Row(
                children: [
                  // Drum label
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerRight,
                    child: Text(
                      _getDrumLabel(i),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Grid cells
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: SequencerModel.numSteps,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: SequencerModel.numSteps,
                      itemBuilder: (context, step) {
                        int index = step + (i * SequencerModel.numSteps) + (SequencerModel.numNotes * SequencerModel.numSteps);
                        bool isPlayingStep = step == sequencer.currentStep;
                        bool isQuarterNote = step % 4 == 0;

                        return GestureDetector(
                          onTap: () => sequencer.toggleNote(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                              color: sequencer.isPlaying && isPlayingStep
                                  ? Colors.orange.withOpacity(0.7)
                                  : activeLayer.grid[index]
                                      ? _getDrumColor(i)
                                      : isQuarterNote
                                          ? Colors.grey[700]
                                          : Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isQuarterNote ? Colors.white24 : Colors.transparent,
                                width: 1,
                              ),
                              boxShadow: activeLayer.grid[index]
                                  ? [
                                      BoxShadow(
                                        color: _getDrumColor(i).withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  String _getDrumLabel(int index) {
    switch (index) {
      case 0:
        return 'Kick';
      case 1:
        return 'Snare';
      case 2:
        return 'Hi-hat';
      case 3:
        return 'Clap';
      default:
        return '';
    }
  }

  Color _getDrumColor(int index) {
    switch (index) {
      case 0:
        return Colors.red.shade400;
      case 1:
        return Colors.green.shade400;
      case 2:
        return Colors.yellow.shade400;
      case 3:
        return Colors.purple.shade400;
      default:
        return Colors.blue.shade400;
    }
  }
} 