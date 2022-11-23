import 'package:flutter/material.dart';

import 'main.dart';

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
