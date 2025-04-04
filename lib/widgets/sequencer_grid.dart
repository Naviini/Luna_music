import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sequencer_model.dart';

class SequencerGrid extends StatelessWidget {
  const SequencerGrid({super.key});

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
        
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header row showing beat numbers
                Row(
                  children: [
                    const SizedBox(width: 60), // Space for note labels
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
                // Note grid
                for (int i = 0; i < SequencerModel.numNotes; i++)
                  Row(
                    children: [
                      // Note label with octave
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerRight,
                        child: Text(
                          sequencer.notes[i],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: sequencer.notes[i].contains('C') ? FontWeight.bold : FontWeight.normal,
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
                            int index = step + (i * SequencerModel.numSteps);
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
                                          ? Colors.blue.shade400
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
                                            color: Colors.blue.withOpacity(0.3),
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
            ),
          ),
        );
      },
    );
  }
}