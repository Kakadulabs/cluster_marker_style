# cluster_marker_style example

A Google Map clustering ~3,000 generated points with
[`google_maps_cluster_manager_2`](https://pub.dev/packages/google_maps_cluster_manager_2),
styled by `cluster_marker_style` via the one-line `clusterMarkerBuilder`. A
segmented control switches between the `.soft`, `.flat`, and `.outlined` styles
live; pan and zoom stay smooth thanks to the icon cache.

## Run it

1. Get a Google Maps API key and enable the **Maps SDK for Android / iOS** and/or
   the **Maps JavaScript API** as needed:
   <https://developers.google.com/maps/flutter-package>.
2. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your key in:
   - `android/app/src/main/AndroidManifest.xml`
   - `web/index.html`
   - (iOS) add the key in `ios/Runner/AppDelegate.swift` per the link above.
3. From this directory:

   ```sh
   flutter pub get
   flutter run        # or: flutter run -d chrome
   ```

The key cluster-styling code is in [`lib/main.dart`](lib/main.dart).
