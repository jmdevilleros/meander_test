// =============================================================================
// meander-proof-of-concept
// main.dart - App entry point
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
final _isRunningNotifier = ValueNotifier<bool>(false);
const _runningDuration = Duration(seconds: 60);

// -----------------------------------------------------------------------------
enum TokenDirection { left, neutral, right }

class TokenMovement {
  TokenDirection direction = TokenDirection.neutral;
}

// -----------------------------------------------------------------------------
void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meander proof-of-concept',
      theme: buildThemeData(),
      home: Center(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Meander proof-of-concept'),
            centerTitle: true,
          ),
          body: const MainPage(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  ThemeData buildThemeData() {
    const primaryColor = Colors.blueGrey;
    return ThemeData(
      primaryColor: primaryColor,
      primarySwatch: primaryColor,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        bodyText2: TextStyle(
          color: primaryColor,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HeaderField(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            MeanderZone(),
            MeanderZone(),
          ],
        ),
        const StartButton(),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
class HeaderField extends StatelessWidget {
  const HeaderField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ValueListenableBuilder(
          valueListenable: _isRunningNotifier,
          builder: (_, bool isRunning, __) {
            return DefaultTextStyle(
                style: const TextStyle(fontSize: 15, color: Colors.white),
                child: isRunning
                    ? const CountDownTimer(lapse: _runningDuration)
                    : const Text("00:00"));
          }),
    );
  }
}

// -----------------------------------------------------------------------------
class CountDownTimer extends StatefulWidget {
  final Duration lapse;

  const CountDownTimer({
    Key? key,
    required this.lapse,
  }) : super(key: key);

  // ---------------------------------------------------------------------------
  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  late Timer timer;
  late Duration remain;

  // ---------------------------------------------------------------------------
  void onTick(Timer timer) {
    remain = Duration(seconds: widget.lapse.inSeconds - timer.tick);
    if (remain <= Duration.zero || _isRunningNotifier.value == false) {
      _isRunningNotifier.value = false;
      timer.cancel();
    }
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  @override
  initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), onTick);
    remain = Duration(seconds: widget.lapse.inSeconds - timer.tick);
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final String remainStr = remain.toString();
    final startPos = remainStr.indexOf(":") + 1;
    final endPos = remainStr.lastIndexOf(".");
    return Text(
      remainStr.substring(startPos, endPos),
    );
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
class StartButton extends StatelessWidget {
  const StartButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      onPressed: () async {
        if (_isRunningNotifier.value == true) {
          _isRunningNotifier.value = false;
        } else {
          await doCountDown(context);
          _isRunningNotifier.value = true;
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _isRunningNotifier,
        child: const Icon(Icons.directions_run),
        builder: (_, bool isRunning, __) {
          return Icon(
            isRunning == true ? Icons.stop : Icons.play_arrow,
            size: 40,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Future<void> doCountDown(BuildContext context) async {
    int secondsToStart = 3;
    do {
      showCountdown(context, "$secondsToStart");
      await Future.delayed(const Duration(seconds: 1), () => secondsToStart--);
    } while (secondsToStart > 0);
    showCountdown(context, "GO");
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ---------------------------------------------------------------------------
  showCountdown(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 250),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 100, color: Colors.yellow),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MeanderZone extends StatelessWidget {
  const MeanderZone({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movement = TokenMovement()..direction = TokenDirection.neutral;
    final width = MediaQuery.of(context).size.width / 1.618 / 1.618;
    final height = MediaQuery.of(context).size.height / 1.618 / 1.618;
    final collisionNotifier = ValueNotifier<int>(0);

    return Column(
      children: [
        ValueListenableBuilder(
            valueListenable: collisionNotifier,
            builder: (_, int millis, __) {
              return Text(
                "$millis",
                style: Theme.of(context).textTheme.bodyText2,
              );
            }),
        MeanderBox(
          size: Size(width, height),
          movement: movement,
          collisionNotifier: collisionNotifier,
        ),
        buildControlButtons(movement),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget buildControlButtons(TokenMovement movement) {
    return Row(
      children: [
        ControlButton(
          iconData: Icons.chevron_left,
          direction: TokenDirection.left,
          movement: movement,
        ),
        const SizedBox(width: 20),
        ControlButton(
          iconData: Icons.chevron_right,
          direction: TokenDirection.right,
          movement: movement,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
class ControlButton extends StatelessWidget {
  final IconData iconData;
  final TokenMovement movement;
  final TokenDirection direction;

  const ControlButton({
    Key? key,
    required this.iconData,
    required this.movement,
    required this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => movement.direction = direction,
      onTapUp: (_) => movement.direction = TokenDirection.neutral,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).textTheme.bodyText2?.color,
        ),
        child: Icon(iconData, size: 50),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MeanderBox extends StatefulWidget {
  final Size size;
  final TokenMovement movement;
  final ValueNotifier<int> collisionNotifier;

  const MeanderBox({
    Key? key,
    required this.size,
    required this.movement,
    required this.collisionNotifier,
  }) : super(key: key);

  @override
  State<MeanderBox> createState() => _MeanderBoxState();
}

class _MeanderBoxState extends State<MeanderBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  final Offset tokenSpeed = const Offset(1, 0);
  late double meanderWidth;
  late double plotAmplitude;
  late double plotPeriod;
  late double plotShiftX;
  late double plotShiftY;
  late Size tokenSize;
  Color tokenColor = Colors.red;
  Offset tokenOffset = const Offset(0, 0);
  double plotStartY = 0;
  Timer? collisionTimer;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    initParameters();
    setStartOffset();
    controller = AnimationController(duration: _runningDuration, vsync: this);
    animation =
        Tween<double>(begin: 0, end: widget.size.height).animate(controller);
    animation.addListener(() => onAnimationCycle());
    _isRunningNotifier.addListener(() => onChangeRunning());
  }

  // ---------------------------------------------------------------------------
  void initParameters() {
    meanderWidth = 3 * widget.size.width / 7;
    plotShiftX = 2 * widget.size.width / 7;
    plotShiftY = Random().nextDouble() * widget.size.height;
    tokenSize = Size(meanderWidth / 3, meanderWidth / 3);
    plotAmplitude =
        widget.size.width / 5 - Random().nextInt(tokenSize.width ~/ 5);
    plotPeriod = widget.size.height;
    widget.collisionNotifier.value = 0;
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    animation.removeListener(() => onAnimationCycle());
    _isRunningNotifier.removeListener(() => onChangeRunning());
    controller.dispose();
    collisionTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(30.0),
        ),
        color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.8),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: widget.size,
            painter: MeanderPainter(
              plotFunction: plotFunction,
              meanderWidth: meanderWidth,
            ),
          ),
          MeanderToken(size: tokenSize, offset: tokenOffset, color: tokenColor)
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  double plotFunction(double y) {
    final double B = 2 * pi / plotPeriod;
    const speed = 10;
    return plotAmplitude * sin(B * (y + plotShiftY + plotStartY * speed)) +
        plotShiftX;
  }

  // ---------------------------------------------------------------------------
  void setStartOffset() {
    final double startY = widget.size.height / 3;
    final double startX = widget.size.width / 2;
    tokenOffset =
        Offset(startX - tokenSize.width / 2, startY - tokenSize.height / 2);

    bool isColliding = true;
    do {
      switch (checkCollision()) {
        case TokenDirection.left:
          tokenOffset += tokenSpeed * 10;
          break;
        case TokenDirection.neutral:
          isColliding = false;
          break;
        case TokenDirection.right:
          tokenOffset -= tokenSpeed * 10;
          break;
      }
    } while (isColliding);
  }

  // ---------------------------------------------------------------------------
  void onAnimationCycle() {
    plotStartY = animation.value;
    switch (widget.movement.direction) {
      case TokenDirection.left:
        tokenOffset -= tokenSpeed;
        break;
      case TokenDirection.neutral:
        break;
      case TokenDirection.right:
        tokenOffset += tokenSpeed;
        break;
    }
    bool isColliding = true;
    switch (checkCollision()) {
      case TokenDirection.left: // Collision with left side of meander
        tokenOffset += tokenSpeed * 2;
        break;
      case TokenDirection.neutral: // No collision
        isColliding = false;
        break;
      case TokenDirection.right: // Collision with right side of meander
        tokenOffset -= tokenSpeed * 2;
        break;
    }
    if (isColliding) {
      tokenColor = Colors.deepOrangeAccent;
      if (collisionTimer == null || collisionTimer?.isActive == false) {
        collisionTimer = Timer.periodic(const Duration(milliseconds: 1), (_) {
          widget.collisionNotifier.value++;
        });
      }
    } else {
      tokenColor = Colors.red;
      if (collisionTimer?.isActive == true) {
        collisionTimer?.cancel();
      }
    }
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  void onChangeRunning() {
    if (_isRunningNotifier.value == true) {
      controller.reset();
      setStartOffset();
      initParameters();
      setState(() {});
      controller.forward();
    } else {
      controller.stop();
      collisionTimer?.cancel();
    }
  }

  // ---------------------------------------------------------------------------
  TokenDirection checkCollision() {
    double tolerance = 2.0;
    final y1 = tokenOffset.dy;
    final y2 = tokenOffset.dy + tokenSize.height;
    final x1 = plotFunction(y1);
    final x2 = plotFunction(y2);
    final x3 = x1 + meanderWidth;
    final x4 = x2 + meanderWidth;
    final x5 = plotFunction(tokenOffset.dy + tokenSize.height / 2);
    final x6 = x5 + meanderWidth;

    // Check collision with left side of meander
    if (tokenOffset.dx + tolerance <= x1 ||
        tokenOffset.dx + tolerance <= x2 ||
        tokenOffset.dx <= x5) {
      return TokenDirection.left;
    }

    // check collision with right side of meander
    if (tokenOffset.dx + tokenSize.width - tolerance >= x3 ||
        tokenOffset.dx + tokenSize.width - tolerance >= x4 ||
        tokenOffset.dx + tokenSize.width >= x6) {
      return TokenDirection.right;
    }
    // No collision
    return TokenDirection.neutral;
  }
}

// -----------------------------------------------------------------------------
class MeanderPainter extends CustomPainter {
  final double meanderWidth;
  final double Function(double y) plotFunction;

  MeanderPainter({
    required this.plotFunction,
    required this.meanderWidth,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final plotPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final leftSidePoints = <Offset>[
      for (double y = 1; y <= size.height - 5; y += 1)
        Offset(plotFunction(y), y)
    ];

    final rightSidePoints = <Offset>[
      for (final lp in leftSidePoints) lp + Offset(meanderWidth, 0)
    ];

    canvas.drawPoints(PointMode.points, leftSidePoints, plotPaint);
    canvas.drawPoints(PointMode.points, rightSidePoints, plotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _isRunningNotifier.value == true;
  }
}

// -----------------------------------------------------------------------------
class MeanderToken extends StatelessWidget {
  final Size size;
  final Offset offset;
  final Color color;

  const MeanderToken({
    Key? key,
    required this.size,
    required this.offset,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size.width,
      height: size.height,
      left: offset.dx,
      top: offset.dy,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
