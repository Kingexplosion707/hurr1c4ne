#!/bin/bash
set -euo pipefail

# hurr1c4ne: build an unsigned iOS IPA without an Xcode project.
# Requires macOS and Xcode command-line tools.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${ROOT_DIR}/hurr1c4ne"
BUILD_DIR="${ROOT_DIR}/build"
APP_NAME="hurr1c4ne"
APP_BUNDLE="${BUILD_DIR}/Payload/${APP_NAME}.app"
IPA_PATH="${BUILD_DIR}/${APP_NAME}.ipa"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: build.sh must run on macOS with the iOS SDK installed." >&2
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "error: xcrun not found. Install Xcode or Xcode command-line tools." >&2
  exit 1
fi

if [[ ! -f "${SOURCE_DIR}/Info.plist" ]]; then
  echo "error: missing ${SOURCE_DIR}/Info.plist" >&2
  exit 1
fi

SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --sdk iphoneos --find clang)"

rm -rf "${BUILD_DIR}"
mkdir -p "${APP_BUNDLE}"

# Find Objective-C implementation files.
SOURCE_FILES=()
while IFS= read -r source_file; do
  SOURCE_FILES+=("${source_file}")
done < <(find "${SOURCE_DIR}" -maxdepth 1 -type f -name '*.m' ! -name 'main.m' | sort)

if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
  echo "error: no Objective-C .m files found in ${SOURCE_DIR}" >&2
  exit 1
fi

# Use an existing main.m or generate a temporary application entry point.
GENERATED_MAIN="${BUILD_DIR}/hurr1c4ne-main.m"

if [[ -f "${SOURCE_DIR}/main.m" ]]; then
  MAIN_FILE="${SOURCE_DIR}/main.m"
else
  cat > "${GENERATED_MAIN}" <<'MAIN_EOF'
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(
            argc,
            argv,
            nil,
            NSStringFromClass([AppDelegate class])
        );
    }
}
MAIN_EOF
  MAIN_FILE="${GENERATED_MAIN}"
fi

MIN_IOS_VERSION="${MIN_IOS_VERSION:-15.0}"

# Compile and link the app.
"${CLANG}" \
  -fobjc-arc \
  -fmodules \
  -arch arm64 \
  -isysroot "${SDK_PATH}" \
  -miphoneos-version-min="${MIN_IOS_VERSION}" \
  -I "${SOURCE_DIR}" \
  "${SOURCE_FILES[@]}" \
  "${MAIN_FILE}" \
  -framework UIKit \
  -framework Foundation \
  -o "${APP_BUNDLE}/${APP_NAME}"

# Copy app metadata.
cp "${SOURCE_DIR}/Info.plist" "${APP_BUNDLE}/Info.plist"

/usr/libexec/PlistBuddy \
  -c "Print :CFBundleIdentifier" \
  "${APP_BUNDLE}/Info.plist" >/dev/null 2>&1 || {
    echo "error: Info.plist must define CFBundleIdentifier." >&2
    exit 1
  }

/usr/libexec/PlistBuddy \
  -c "Print :CFBundleExecutable" \
  "${APP_BUNDLE}/Info.plist" >/dev/null 2>&1 || \
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundleExecutable string ${APP_NAME}" \
    "${APP_BUNDLE}/Info.plist"

/usr/libexec/PlistBuddy \
  -c "Print :CFBundleName" \
  "${APP_BUNDLE}/Info.plist" >/dev/null 2>&1 || \
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundleName string ${APP_NAME}" \
    "${APP_BUNDLE}/Info.plist"

/usr/libexec/PlistBuddy \
  -c "Print :CFBundlePackageType" \
  "${APP_BUNDLE}/Info.plist" >/dev/null 2>&1 || \
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundlePackageType string APPL" \
    "${APP_BUNDLE}/Info.plist"

# Package the app into an IPA.
(
  cd "${BUILD_DIR}"
  /usr/bin/zip -qry "${IPA_PATH}" Payload
)

echo "Build complete: ${IPA_PATH}"
echo "Note: This IPA is unsigned and needs appropriate signing before installation."
