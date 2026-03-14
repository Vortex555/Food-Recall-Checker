# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Build for simulator
xcodebuild -project Food Recall Checker.xcodeproj -scheme 'Food Recall Checker' -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Build for physical device (Ricky Rat)
xcodebuild -project Food Recall Checker.xcodeproj -scheme 'Food Recall Checker' -destination 'id=00008140-001C59381123001C' build

# Install on device
BUILT_DIR=$(xcodebuild -project Food Recall Checker.xcodeproj -scheme 'Food Recall Checker' -destination 'id=00008140-001C59381123001C' -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')
xcrun devicectl device install app --device 00008140-001C59381123001C "$BUILT_DIR/FoodRecall.app"

# Launch on device
xcrun devicectl device process launch --device 00008140-001C59381123001C com.foodrecall.iosapp
```

The project uses `project.yml` (XcodeGen format) as the source of truth for build settings. The Xcode project file is generated from it. When changing build settings, update both `project.yml` and `project.pbxproj`.

## Architecture

SwiftUI + Swift 6 strict concurrency app targeting iOS 17+. Uses MVVM with `@Observable` view models, all annotated `@MainActor`.

**Data flow:** Barcode scan → Open Food Facts API (product lookup) → FDA openFDA API (recall check) → display results and persist to SwiftData.

**Two external APIs (no keys required):**
- **FDA openFDA** (`api.fda.gov/food/enforcement.json`) — recall enforcement data, rate limited ~240 req/min
- **Open Food Facts** (`world.openfoodfacts.net/api/v2/product`) — barcode-to-product resolution with UPC-A/EAN-13 fallback

**Networking layer:** `Endpoint` protocol → concrete endpoint structs → `APIClient` actor (singleton, handles HTTP) → service structs (`FDARecallService`, `OpenFoodFactsService`).

**Recall matching:** When a barcode is scanned, the product name and brand are searched against FDA recalls. Results are filtered using Jaccard similarity (`String.relevanceScore`) with a 0.15 threshold to reduce false positives.

**Persistence:** SwiftData `ScannedItem` model stores scan history with recall status. Items can be rechecked against the FDA API from the History tab.

**Four tabs:** Scan (camera barcode scanner) · Search (text search FDA recalls) · Recalls (recent FDA recall feed with class filter) · History (SwiftData persisted scan history).

## Key Conventions

- Swift 6 with `SWIFT_STRICT_CONCURRENCY: complete` — all `@Observable` view models must be `@MainActor`
- Camera delegate conformances use `@preconcurrency` for AVFoundation protocols
- Bundle ID: `com.foodrecall.iosapp`, Display Name: "Food Recall Checker"
- App icon must be 1024x1024 PNG with **no alpha channel** (RGB only) for App Store submission
