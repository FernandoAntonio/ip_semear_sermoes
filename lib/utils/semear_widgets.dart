import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'audio_player_handler.dart';
import 'constants.dart';
import 'extensions.dart';

class SemearLoadingWidget extends StatelessWidget {
  const SemearLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Carregando, isso pode demorar vários segundos',
              style: TextStyle(fontSize: 16.0, color: semearGreen),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            CircularProgressIndicator(),
          ],
        )),
      );
}

class SemearErrorWidget extends StatelessWidget {
  final void Function() onRetryPressed;

  const SemearErrorWidget(this.onRetryPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Oops, algo deu errado.\n'
                'Por favor verifique sua conexão com a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: semearOrange),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: onRetryPressed,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
}

class SemearPullToRefresh extends StatelessWidget {
  final int index;

  const SemearPullToRefresh({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return index == 0
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Puxe para atualizar',
                  style: TextStyle(color: semearLightGrey),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: semearLightGrey,
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class SemearIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;

  const SemearIcon({
    Key? key,
    required this.onPressed,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 40.0,
      icon: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => semearLightGreyGradient.createShader(bounds),
        child: Text(
          String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontFamily: iconData.fontFamily,
            fontSize: 40.0,
            shadows: boxShadowsGreen,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class SemearBookCard extends StatelessWidget {
  final VoidCallback onPressed;
  final String sermonBookName;

  const SemearBookCard({
    Key? key,
    required this.onPressed,
    required this.sermonBookName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: const BoxDecoration(gradient: semearOrangeGradient),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.book_outlined,
                    color: semearGreenWithOpacity30,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    sermonBookName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: semearGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: semearOrangeWithOpacity30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemearSermonCard extends StatelessWidget {
  final ExpandableController controller;
  final Widget collapsed;
  final Widget expanded;

  const SemearSermonCard({
    Key? key,
    required this.controller,
    required this.collapsed,
    required this.expanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(gradient: semearOrangeGradient),
        child: ExpandableNotifier(
          child: Expandable(
            controller: controller,
            collapsed: collapsed,
            expanded: expanded,
          ),
        ),
      ),
    );
  }
}

class SemearSlider extends StatelessWidget {
  final ProgressBarState progressBarState;
  final Function(double) onSeekChanged;

  const SemearSlider({
    Key? key,
    required this.progressBarState,
    required this.onSeekChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          label: progressBarState.current.formatDuration(),
          divisions: progressBarState.total.inSeconds,
          max: progressBarState.total.inSeconds.toDouble(),
          value: progressBarState.current.inSeconds.toDouble(),
          onChanged: onSeekChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progressBarState.current.formatDuration(),
              style: const TextStyle(color: semearLightGrey, fontSize: 12.0),
            ),
            Text(
              progressBarState.total.formatDuration(),
              style: const TextStyle(color: semearLightGrey, fontSize: 12.0),
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  bool _animate = false;
  static bool _isStart = true;

  @override
  void initState() {
    super.initState();
    if (_isStart) {
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) {
          setState(() {
            _animate = true;
            _isStart = false;
          });
        }
      });
    } else {
      _animate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1400),
      opacity: _animate ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        curve: Curves.ease,
        offset: _animate ? const Offset(0.0, 0.0) : const Offset(10.0, 0.0),
        child: widget.child,
      ),
    );
  }
}

class BarVisualizer extends CustomPainter {
  final List<int> waveData;
  final double _height;
  final double _minimumHeight;
  final double width;
  final Paint wavePaint;
  final int _density;
  final int _gap;

  BarVisualizer({
    required this.waveData,
    required this.width,
  })  : _height = 20.0,
        _minimumHeight = 5.0 * -1,
        _density = 20,
        _gap = 1,
        wavePaint = Paint()
          ..color = semearOrange
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    double barWidth = width / _density;
    double div = waveData.length / _density;
    wavePaint.strokeWidth = barWidth - _gap;
    for (int i = 0; i < _density; i++) {
      int bytePosition = (i * div).ceil();
      double top = (_height / 2) - waveData[bytePosition].abs();
      double barX = (i * barWidth) + (barWidth / 2);
      if (top > _minimumHeight) {
        top = _minimumHeight;
      }

      if (waveData.every((e) => e == 128)) {
        canvas.drawLine(Offset(barX, 0), Offset(barX, -5), wavePaint);
      } else {
        canvas.drawLine(Offset(barX, (_height / 6)), Offset(barX, top), wavePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
