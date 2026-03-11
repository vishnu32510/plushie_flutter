#!/bin/sh

# Fail this script if any subcommand fails.
set -e

cd $CI_PRIMARY_REPOSITORY_PATH

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS.
flutter precache --ios

# Create .env file from Xcode Cloud environment variable.
echo "$ENV_FILE" > .env

# Create firebase_options.dart from Xcode Cloud environment variable.
echo "$FIREBASE_OPTIONS" > lib/firebase_options.dart

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install

exit 0
