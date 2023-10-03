import 'dart:async';

import 'package:flutter/material.dart';

import 'card_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CardUI(),
    );
  }
}

class CardUI extends StatefulWidget {
  const CardUI({super.key});

  @override
  State<CardUI> createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _shiftController;

  @override
  void initState() {
    super.initState();
    _shiftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
    //   await animate();
    // });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

//isOut = out of deck if its true the first card is out of stack
//false = card is out of deck
  bool isOut = false;

  Future<void> animate() async {
    await _moveController.forward();
    setState(() {
      isOut = true;
    });
    _moveController.reverse();
    await Future.delayed(Duration(milliseconds: 100));
    _shiftController.forward();
    await Future.delayed(Duration(seconds: 1));
    _shiftController.reset();
    setState(() {
      isOut = false;
      cardDetailsList.add(cardDetailsList.removeAt(0));
    });
  }

  List<CardUIDetails> cardDetailsList = [
    CardUIDetails(
        gradientColors: [Colors.indigo, Colors.purple],
        cardTitle: "Spotify",
        cardIcon: const Icon(Icons.music_note_rounded)),
    CardUIDetails(
        gradientColors: [Colors.pink, Color.fromARGB(255, 255, 122, 193)],
        cardTitle: "Slack",
        cardIcon: const Icon(Icons.message_rounded)),
    CardUIDetails(gradientColors: [
      Color.fromARGB(255, 196, 235, 200),
      const Color.fromARGB(255, 39, 176, 130)
    ], cardTitle: "Maps", cardIcon: const Icon(Icons.map_rounded)),
    CardUIDetails(
        gradientColors: [Color.fromARGB(255, 26, 90, 229), Colors.indigoAccent],
        cardTitle: "Timer",
        cardIcon: const Icon(Icons.timelapse_rounded))
  ];

  @override
  Widget build(BuildContext context) {
    int numOfCards = cardDetailsList.length;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        animate();
      }),
      backgroundColor: Colors.blue[200],
      body: Center(
        child: AnimatedBuilder(
          animation: _moveController,
          builder: (_, __) {
            return AnimatedBuilder(
              animation: _shiftController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(numOfCards + 1, (index) {
                    double reverseIndex = (numOfCards + 1) - index.toDouble();
                    var offSetX = 90 * _moveController.value;

                    //4=4
                    if (index == numOfCards) {
                      return Opacity(
                        opacity: isOut ? 0 : 1,
                        child: GenerateCard(
                          offSetX: offSetX,
                          index: index.toDouble(),
                          reverseIndex: reverseIndex,
                          cardUIDetails: cardDetailsList.first,
                        ),
                      );
                    }
                    //5 - 4 = 1
                    double moveEnd = (numOfCards + 1) - numOfCards.toDouble();
                    //4
                    double moveStart = reverseIndex;
                    if (index == 0) {
                      return DragTarget(
                        onAccept: (data) {
                          animate();
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Opacity(
                            opacity: isOut ? 1 : 0,
                            child: GenerateCard(
                              offSetX: offSetX,
                              cardUIDetails: cardDetailsList.first,
                              reverseIndex: isOut
                                  ? getAnimValue(
                                      start: (numOfCards + 1) - 1.0,
                                      end: moveEnd,
                                      animation: _moveController)
                                  : getAnimValue(
                                      start: moveStart,
                                      end: moveEnd,
                                      animation: _moveController),
                              index: isOut
                                  ? getAnimValue(
                                      start: 1.0,
                                      end: numOfCards.toDouble(),
                                      animation: _moveController)
                                  : numOfCards * _moveController.value,
                            ),
                          );
                        },
                      );
                    }

                    List<CardUIDetails> leftDetails = [];
                    for (int i = cardDetailsList.length - 1; i > 0; i--) {
                      leftDetails.add(cardDetailsList[i]);
                    }
                    return GenerateCard(
                      offSetX: 0,
                      reverseIndex: getAnimValue(
                          start: reverseIndex,
                          end: (numOfCards + 1) - (index.toDouble() + 1),
                          animation: _shiftController),
                      index: getAnimValue(
                          start: index.toDouble(),
                          end: index.toDouble() + 1,
                          animation: _shiftController),
                      cardUIDetails: leftDetails[index - 1],
                    );
                  }),
                );
              },
            );
          },
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class GenerateCard extends StatelessWidget {
  final double index;
  final double reverseIndex;
  final double offSetX;
  final CardUIDetails cardUIDetails;

  const GenerateCard(
      {super.key,
      required this.index,
      required this.reverseIndex,
      required this.offSetX,
      required this.cardUIDetails});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: CardToBeDragged(
        index: index,
        cardUIDetails: cardUIDetails,
      ),
      childWhenDragging:
          NextCardFeedback(currentIndex: index, cardUIDetails: cardUIDetails),
      data: CardUIDetails,
      child: Transform.translate(
        offset: Offset(0.0, reverseIndex * 10.0),
        child: Transform.translate(
          offset: Offset(offSetX, 0.0),
          child: CardToBeDragged(
            index: index,
            cardUIDetails: cardUIDetails,
          ),
        ),
      ),
    );
  }
}

class CardToBeDragged extends StatelessWidget {
  const CardToBeDragged({
    super.key,
    required this.index,
    required this.cardUIDetails,
  });

  final double index;
  final CardUIDetails cardUIDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 1.0,
              spreadRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: cardUIDetails.gradientColors,
          )),
      width: 200,
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cardUIDetails.cardTitle,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              cardUIDetails.cardIcon.icon,
              size: 34,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class NextCardFeedback extends StatelessWidget {
  final double currentIndex;
  final CardUIDetails cardUIDetails;

  const NextCardFeedback(
      {super.key, required this.currentIndex, required this.cardUIDetails});

  @override
  Widget build(BuildContext context) {
    print(currentIndex - 1);
    return GenerateCard(
      cardUIDetails: cardUIDetails,
      index: (currentIndex - 1),
      offSetX: 0.0,
      reverseIndex: 0.0,
    );
  }
}

double getAnimValue(
    {required double start,
    required double end,
    required Animation animation}) {
  return ((end - start) * animation.value) + start;
}
