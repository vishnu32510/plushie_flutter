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
[ -n "$ENV_FILE" ] || { echo "ENV_FILE is missing"; exit 1; }
printf "%s" "$ENV_FILE" > .env

# Create firebase_options.dart from Xcode Cloud environment secrets.
# Prefer the base64 version to avoid truncation/newline issues with multiline secrets.
if [ -n "$FIREBASE_OPTIONS_B64" ]; then
  printf "%s" "$FIREBASE_OPTIONS_B64" | base64 -D > lib/firebase_options.dart
else
  [ -n "$FIREBASE_OPTIONS" ] || { echo "FIREBASE_OPTIONS is missing"; exit 1; }
  printf "%s" "$FIREBASE_OPTIONS" > lib/firebase_options.dart
fi

# Firebase iOS config file expected by Xcode project.
# The repository ignores `ios/Runner/GoogleService-Info.plist`, so we must
# recreate it from an Xcode Cloud secret during CI.
GOOGLE_PLIST_PATH="ios/Runner/GoogleService-Info.plist"
if [ ! -s "$GOOGLE_PLIST_PATH" ]; then
  if [ -n "$GOOGLE_SERVICE_INFO_PLIST_B64" ]; then
    mkdir -p "$(dirname \"$GOOGLE_PLIST_PATH\")"
    printf "%s" "$GOOGLE_SERVICE_INFO_PLIST_B64" | base64 -D > "$GOOGLE_PLIST_PATH"
  else
    echo "GoogleService-Info.plist missing at $GOOGLE_PLIST_PATH"
    echo "Set Xcode Cloud secret: GOOGLE_SERVICE_INFO_PLIST_B64"
    exit 1
  fi
fi

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install

# Debug checks for CI artifacts written from secrets.
cd "$CI_PRIMARY_REPOSITORY_PATH"
echo "ENV_FILE bytes: $(wc -c < .env)"
echo "firebase_options.dart bytes: $(wc -c < lib/firebase_options.dart)"
test -s .env || { echo ".env empty"; exit 1; }
test -s lib/firebase_options.dart || { echo "firebase_options.dart empty"; exit 1; }

exit 0
