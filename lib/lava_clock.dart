import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_clock_helper/model.dart';
import 'lava_painter.dart';

List<Color> colors = [
  Color(0xfff857a6),
  Colors.blue,
  Colors.red,
  Colors.orange,
  Colors.deepPurpleAccent,
  Colors.yellow,
  Colors.green,
  Colors.deepPurple,
  Colors.cyan,
  Color(0xffff5858)
];

/// Lava clock.
class LavaClock extends StatefulWidget {
  const LavaClock(this.model);

  final ClockModel model;

  @override
  _LavaClockState createState() => _LavaClockState();
}

class _LavaClockState extends State<LavaClock> with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Lava lava = Lava(6);
  Timer _timer;
  AnimationController _animation;

  TweenSequence<Color> tweenColors = TweenSequence<Color>(colors
      .asMap()
      .map(
        (index, color) => MapEntry(
          index,
          TweenSequenceItem(
            weight: 1.0,
            tween: ColorTween(
              begin: color,
              end: colors[index + 1 < colors.length ? index + 1 : 0],
            ),
          ),
        ),
      )
      .values
      .toList());

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(duration: Duration(minutes: 5), vsync: this);
    _animation.repeat();

    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(LavaClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final defaultStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Rubik',
      shadows: [
        Shadow(
          blurRadius: 120,
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 0),
        ),
        Shadow(
          blurRadius: 60,
          color: Colors.black.withOpacity(0.2),
          offset: Offset(0, 0),
        ),
      ],
    );

    return Semantics(
        label: '$hour $minute',
        value: '$hour $minute',
        readOnly: true,
        child: ExcludeSemantics(
            child: LayoutBuilder(
                builder: (context, constraints) => AnimatedContainer(
                      duration: Duration(seconds: 1),
                      color: backgroundColor,
                      child: AnimatedBuilder(
                          animation: _animation,
                          builder: (BuildContext context, Widget child) {
                            final color = tweenColors.evaluate(
                                AlwaysStoppedAnimation(_animation.value));
                            return Container(
                              color: color.withOpacity(0.4),
                              child: CustomPaint(
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '$hour',
                                      style: defaultStyle.copyWith(
                                          fontSize: constraints.maxWidth / 4),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          20, 0, 20, constraints.maxWidth / 20),
                                      child: Text(
                                        ':',
                                        style: defaultStyle.copyWith(
                                            fontSize: constraints.maxWidth / 4),
                                      ),
                                    ),
                                    Text(
                                      '$minute',
                                      style: defaultStyle.copyWith(
                                          fontSize: constraints.maxWidth / 4),
                                    ),
                                  ],
                                )),
                                painter: LavaPainter(lava, color: color),
                              ),
                            );
                          }),
                    ))));
  }
}
