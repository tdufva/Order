#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODE_BUILD_ROOT="${TMPDIR:-/tmp}/Order-XcodeBuildCheck"
MAC_DERIVED_DATA="${TMPDIR:-/tmp}/OrderDerived-mac"
IOS_DERIVED_DATA="${TMPDIR:-/tmp}/OrderDerived-ios"
MAC_APP="$MAC_DERIVED_DATA/Build/Products/Debug/Order.app"

stage_xcode_project() {
  rm -rf "$XCODE_BUILD_ROOT"
  mkdir -p "$XCODE_BUILD_ROOT"
  rsync -a --exclude='.git' --exclude='.build' --exclude='.swiftpm' --exclude='build' "$ROOT_DIR/" "$XCODE_BUILD_ROOT/"
}

cd "$ROOT_DIR"

case "$MODE" in
  run)
    pkill -x Order >/dev/null 2>&1 || true
    stage_xcode_project
    xcodebuild -project "$XCODE_BUILD_ROOT/Order.xcodeproj" -scheme "Order macOS" -configuration Debug -derivedDataPath "$MAC_DERIVED_DATA" CODE_SIGNING_ALLOWED=NO build
    /usr/bin/open -n "$MAC_APP"
    ;;
  --verify|verify)
    stage_xcode_project
    xcodebuild -project "$XCODE_BUILD_ROOT/Order.xcodeproj" -scheme "Order macOS" -configuration Debug -derivedDataPath "$MAC_DERIVED_DATA" CODE_SIGNING_ALLOWED=NO build
    xcodebuild -project "$XCODE_BUILD_ROOT/Order.xcodeproj" -scheme "Order iOS" -configuration Debug -derivedDataPath "$IOS_DERIVED_DATA" -sdk iphonesimulator -destination "generic/platform=iOS Simulator" build
    ;;
  --debug|debug|--logs|logs|--telemetry|telemetry)
    echo "Debug/log modes are not wired yet; building and opening the macOS app instead." >&2
    pkill -x Order >/dev/null 2>&1 || true
    stage_xcode_project
    xcodebuild -project "$XCODE_BUILD_ROOT/Order.xcodeproj" -scheme "Order macOS" -configuration Debug -derivedDataPath "$MAC_DERIVED_DATA" CODE_SIGNING_ALLOWED=NO build
    /usr/bin/open -n "$MAC_APP"
    ;;
  *)
    echo "usage: $0 [run|--verify|--debug|--logs|--telemetry]" >&2
    exit 2
    ;;
esac
