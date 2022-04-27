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
                style: const TextStyle(fontSize: 15),
                child: isRunning
                    ? const CountDownTimer(lapse: _runningDuration)
                    : const Text(""));
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
    final width = MediaQuery.of(context).size.width / 1.618 / 2;
    final height = MediaQuery.of(context).size.height / 1.618 / 1.618;
    return Column(
      children: [
        collisionTimer(context),
        MeanderBox(
          size: Size(width, height),
          movement: movement,
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
          iconData: Icons.arrow_back,
          direction: TokenDirection.left,
          movement: movement,
        ),
        ControlButton(
          iconData: Icons.arrow_forward,
          direction: TokenDirection.right,
          movement: movement,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget collisionTimer(BuildContext context) {
    return Text(
      "Collision time",
      style: Theme.of(context).textTheme.bodyText2,
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
        child: Icon(iconData, size: 40),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MeanderBox extends StatefulWidget {
  final Size size;
  final TokenMovement movement;

  const MeanderBox({
    Key? key,
    required this.size,
    required this.movement,
  }) : super(key: key);

  @override
  State<MeanderBox> createState() => _MeanderBoxState();
}

class _MeanderBoxState extends State<MeanderBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  final Size tokenSize = const Size(30, 30);
  final Offset tokenSpeed = const Offset(1, 0);
  final double meanderWidth = 60;

  Offset tokenOffset = const Offset(0, 0);
  double plotStartY = 0;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    setStartOffset();
    controller = AnimationController(duration: _runningDuration, vsync: this);
    animation =
        Tween<double>(begin: 0, end: widget.size.height).animate(controller);
    animation.addListener(() => onAnimationCycle());
    _isRunningNotifier.addListener(() => onChangeRunning());
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    animation.removeListener(() => onAnimationCycle());
    _isRunningNotifier.removeListener(() => onChangeRunning());
    controller.dispose();
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
          MeanderToken(size: tokenSize, offset: tokenOffset)
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  double plotFunction(double y) {
    return 10 * sin(2 * pi / 150 * y + plotStartY) + 30;
  }

  // ---------------------------------------------------------------------------
  void setStartOffset() {
    // todo: verify not in collision
    tokenOffset = Offset(
      (widget.size.width - tokenSize.width) / 2,
      (widget.size.height - tokenSize.height) / 3,
    );
  }

  // ---------------------------------------------------------------------------
  void onAnimationCycle() {
    // todo: ensayar no cambiando el movimiento sino la posicion del token
    // todo: pensar en que se vaya rodando por el borde
    switch (widget.movement.direction) {
      case TokenDirection.left:
        tokenOffset -= tokenSpeed;
        if (collisionDetected()) {
          tokenOffset += tokenSpeed;
          widget.movement.direction = TokenDirection.right;
        }
        break;
      case TokenDirection.neutral:
        break;
      case TokenDirection.right:
        tokenOffset += tokenSpeed;
        if (collisionDetected()) {
          tokenOffset -= tokenSpeed;
          widget.movement.direction = TokenDirection.left;
        }
        break;
    }
    setState(() {
      plotStartY = animation.value;
    });
  }

  // ---------------------------------------------------------------------------
  void onChangeRunning() {
    if (_isRunningNotifier.value == true) {
      controller.reset();
      setStartOffset();
      setState(() {});
      controller.forward();
    } else {
      controller.stop();
    }
  }

  // ---------------------------------------------------------------------------
  bool collisionDetected() {
    double tolerance = 2.0;
    final y1 = tokenOffset.dy;
    final y2 = tokenOffset.dy + tokenSize.height;
    final x1 = plotFunction(y1);
    final x2 = plotFunction(y2);
    final x3 = x1 + meanderWidth;
    final x4 = x2 + meanderWidth;
    if (tokenOffset.dx + tolerance <= x1 ||
        tokenOffset.dx + tolerance <= x2 ||
        tokenOffset.dx <= plotFunction(tokenOffset.dy + tokenSize.height / 2) ||
        tokenOffset.dx + tokenSize.width - tolerance >= x3 ||
        tokenOffset.dx + tokenSize.width - tolerance >= x4 ||
        tokenOffset.dx + tokenSize.width >=
            plotFunction(tokenOffset.dy + tokenSize.height / 2) +
                meanderWidth) {
      return true;
    }
    return false;
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
      for (double y = 1; y < size.height; y += 1) Offset(plotFunction(y), y)
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

  const MeanderToken({
    Key? key,
    required this.size,
    required this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size.width,
      height: size.height,
      left: offset.dx,
      top: offset.dy,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }
}
