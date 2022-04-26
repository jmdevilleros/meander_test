// =============================================================================
// meander-proof-of-concept
// main.dart - App entry point
// =============================================================================

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

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
        const RemainingTime(),
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
class RemainingTime extends StatelessWidget {
  const RemainingTime({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// todo: show only after start
    /// todo: if started, timer else "press run button"
    return const Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Text(
        "30 seconds remaining",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class StartButton extends StatelessWidget {
  const StartButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        /// todo: do nothing if running
        await doCountDown(context);
        /// todo: start game
      },
      child: Icon(
        Icons.directions_run,

        /// todo: change color if running (disable?)
        color: Theme.of(context).textTheme.bodyText2?.color,
        size: 50,
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
/// todo: este es el que se convioerte a statful y controla las demas
class MeanderZone extends StatelessWidget {
  const MeanderZone({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        collisionTimer(context),
        const MeanderBox(),
        controlButtons(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget controlButtons(BuildContext context) {
    return Row(
      children: const [
        ControlButton(iconData: Icons.arrow_left),
        ControlButton(iconData: Icons.arrow_right),
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
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.bodyText2?.color,
      ),
      child: IconButton(
        iconSize: 40,
        icon: Icon(
          iconData,
        ),
        onPressed: () {},
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class MeanderBox extends StatelessWidget {
  const MeanderBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width / 1.618 / 2;
    final double height = MediaQuery.of(context).size.height / 1.618 / 1.618;

    /// todo: receive function as parameter? or choose from a global list?
    /// todo: must remain fixed after selecting it for each meander
    double meanderPlotFunction(double y) =>
        10 * sin(2 * pi / 100 * y + 0) + 0 + 30;

    return Container(
      width: width,
      height: height,
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
            size: Size(width, height),
            painter: MeanderPainter(plotFunction: meanderPlotFunction),
          ),
          const MeanderToken(),
        ],
      ),
    );
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
    return false;
  }
}

// -----------------------------------------------------------------------------
class MeanderToken extends StatelessWidget {
  const MeanderToken({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// todo: left, right as parameters
    return Positioned(
      width: 30,
      height: 30,
      left: 50,
      top: 120,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }
}
