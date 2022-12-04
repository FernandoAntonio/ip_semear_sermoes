import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'audio_player_handler.dart';
import 'utils/constants.dart';
import 'utils/extensions.dart';

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
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 4.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: semearGreenAndDarkGreyGradient,
              ),
            ),
            Slider(
              label: progressBarState.current.formatDuration(),
              divisions: progressBarState.total.inSeconds,
              max: progressBarState.total.inSeconds.toDouble(),
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
