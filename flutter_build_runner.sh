#!/bin/bash

echo "Running Build Runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Build Runner build complete!"