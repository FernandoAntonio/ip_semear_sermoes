import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../database/semear_database.dart';
import 'audio_player_handler.dart';
import 'constants.dart';
import 'extensions.dart';
import 'theme.dart';

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
  final LinearGradient colorGradient;

  const SemearIcon({
    Key? key,
    required this.onPressed,
    required this.iconData,
    this.colorGradient = semearLightGreyGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      icon: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => colorGradient.createShader(bounds),
        child: Text(
          String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontFamily: iconData.fontFamily,
            fontSize: 30.0,
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
          decoration: const BoxDecoration(gradient: semearTransparentOrangeGradient),
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
      child: ExpandableNotifier(
        child: Expandable(
          controller: controller,
          collapsed: collapsed,
          expanded: expanded,
        ),
      ),
    );
  }
}

class SemearCollapsedSermonCard extends StatelessWidget {
  final Sermon sermon;
  final void Function() onPressed;
  final Function(bool completed) onCheckboxPressed;

  const SemearCollapsedSermonCard({
    Key? key,
    required this.sermon,
    required this.onPressed,
    required this.onCheckboxPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: sermon.completed
              ? semearTransparentGreenGradient
              : semearTransparentOrangeGradient),
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          Checkbox(
            value: sermon.completed,
            onChanged: (value) => onCheckboxPressed(value ?? false),
          ),
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            sermon.bookmarkInSeconds != null
                                ? const Icon(
                                    Icons.bookmark,
                                    size: 15.0,
                                    color: semearGreen,
                                  )
                                : const SizedBox.shrink(),
                            sermon.bookmarkInSeconds != null
                                ? const SizedBox(width: 4.0)
                                : const SizedBox.shrink(),
                            SizedBox(
                              width: 240.0,
                              child: Text(
                                sermon.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: sermon.completed ? semearGreen : semearOrange,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          sermon.passage,
                          style: const TextStyle(color: semearLightGrey),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: semearLightGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SemearExpandedSermonCard extends StatelessWidget {
  final Sermon sermon;
  final void Function() onPressed;
  final Function(bool completed) onCheckboxPressed;
  final Widget playerWidget;

  const SemearExpandedSermonCard({
    Key? key,
    required this.sermon,
    required this.onPressed,
    required this.onCheckboxPressed,
    required this.playerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: sermon.completed
              ? semearTransparentGreenGradient
              : semearTransparentOrangeGradient),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: Checkbox(
                  value: sermon.completed,
                  onChanged: (value) => onCheckboxPressed(value ?? false),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                sermon.bookmarkInSeconds != null
                                    ? const Icon(
                                        Icons.bookmark,
                                        size: 15.0,
                                        color: semearGreen,
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 4.0),
                                SizedBox(
                                  width: 240.0,
                                  child: AutoScrollText(
                                    sermon.title,
                                    pauseBetween: const Duration(seconds: 3),
                                    mode: AutoScrollTextMode.bouncing,
                                    velocity:
                                        const Velocity(pixelsPerSecond: Offset(30, 0)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color:
                                          sermon.completed ? semearGreen : semearOrange,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              sermon.passage,
                              style: const TextStyle(color: semearLightGrey),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Pregador: ${sermon.preacher}',
                              style: const TextStyle(color: semearLightGrey),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              sermon.date,
                              style: const TextStyle(color: semearLightGrey),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 13.0),
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: semearLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          playerWidget,
        ],
      ),
    );
  }
}

class SemearSlider extends StatelessWidget {
  final ProgressBarState progressBarState;
  final Function(double) onSeekChanged;
  final int? bookmarkInSeconds;

  const SemearSlider({
    Key? key,
    required this.progressBarState,
    required this.onSeekChanged,
    this.bookmarkInSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            SizedBox(
              height: 20.0,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: bookmarkInSeconds != null
                      ? const CustomSliderThumbShape()
                      : SliderComponentShape.noThumb,
                ),
                child: Slider(
                  activeColor: Colors.transparent,
                  inactiveColor: Colors.transparent,
                  thumbColor: semearGreen,
                  label: progressBarState.current.formatDuration(),
                  max: progressBarState.total.inSeconds.toDouble(),
                  value: bookmarkInSeconds?.toDouble() ?? 0.0,
                  onChanged: (value) =>
                      onSeekChanged(bookmarkInSeconds?.toDouble() ?? value),
                ),
              ),
            ),
            Slider(
              label: progressBarState.current.formatDuration(),
              max: progressBarState.total.inSeconds.toDouble(),
              divisions: progressBarState.total.inSeconds,
              value: progressBarState.current.inSeconds.toDouble(),
              onChanged: onSeekChanged,
            ),
          ],
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
