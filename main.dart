// =============================================================================
// meander-proof-of-concept
// main.dart - App entry point
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

final _isRunningNotifier = ValueNotifier<bool>(false);
const _runningDuration = Duration(seconds: 60);

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
        buildPlayZone(),
        const StartButton(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Row buildPlayZone() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        MeanderZone(),
        MeanderZone(),
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
            if (isRunning) {
              return const CountDownTimer(lapse: _runningDuration);
            } else {
              return const SizedBox(height: 15);
            }
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
    final String remainRepr = remain.toString();
    return Text(
      remainRepr.substring(
          remainRepr.indexOf(":") + 1, remainRepr.lastIndexOf(".")),
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
            style: const TextStyle(
              fontSize: 100,
              color: Colors.yellow,
            ),
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
    final width = MediaQuery.of(context).size.width / 1.618 / 2;
    final height = MediaQuery.of(context).size.height / 1.618 / 1.618;
    return Column(
      children: [
        collisionTimer(context),
        MeanderBox(size: Size(width, height)),
        controlButtons(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget controlButtons(BuildContext context) {
    return Row(
      children: const [
        ControlButton(iconData: Icons.arrow_back),
        ControlButton(iconData: Icons.arrow_forward),
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

  const ControlButton({
    Key? key,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.bodyText2?.color,
      ),
      child: IconButton(
        iconSize: 40,
        icon: Icon(iconData),
        onPressed: () {},
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MeanderBox extends StatefulWidget {
  final Size size;

  const MeanderBox({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<MeanderBox> createState() => _MeanderBoxState();
}

class _MeanderBoxState extends State<MeanderBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  double plotStartY = 0;

  // ---------------------------------------------------------------------------
  double plotFunction(double y) {
    return 10 * sin(2 * pi / 100 * y + plotStartY) + 0 + 30;
  }

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: _runningDuration, vsync: this);
    animation =
        Tween<double>(begin: 0, end: widget.size.height).animate(controller);
    animation.addListener(() => moveCurve());
    _isRunningNotifier.addListener(() => checkIfRunning());
  }

  // ---------------------------------------------------------------------------
  void checkIfRunning() {
    if (_isRunningNotifier.value == true) {
      controller.reset();
      setState(() {});
      controller.forward();
    } else {
      controller.stop();
    }
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    animation.removeListener(() => moveCurve());
    controller.dispose();
    _isRunningNotifier.removeListener(() => checkIfRunning());
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
            painter: MeanderPainter(plotFunction: plotFunction),
          ),
          const MeanderToken(size: Size(30, 30), offset: Offset(50, 120))
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  void moveCurve() {
    setState(() => plotStartY = animation.value);
  }
}

// -----------------------------------------------------------------------------
class MeanderPainter extends CustomPainter {
  final double meanderWidth;
  final double Function(double y) plotFunction;

  MeanderPainter({
    required this.plotFunction,
    this.meanderWidth = 60,
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
    /// todo: left, right as parameters
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
