# BRABOTS ctrl

Flutter app for controlling Arduino-powered robot cars in the BRABOTS robotics competition.

Connect to a paired HC-05/HC-06 module over Bluetooth Classic SPP and send single-character commands to the Arduino. Use the demo screen to preview the controls without a Bluetooth connection.

## Features

- Paired Bluetooth device listing and connection flow
- Directional controls for forward, backward, left, and right
- Four custom action buttons: A, B, X, and Y
- Automatic stop command when a control is released or touch is canceled
- Connection status, recoverable errors, and retry support
- Landscape control screen for gamepad-style use
- Control demo available from the connection screen; demo buttons do not send commands

## Requirements

- Android phone or tablet with Bluetooth Classic support
- HC-05, HC-06, or compatible serial Bluetooth module
- Arduino firmware that reads single-character serial commands
- The Bluetooth module must be paired in Android settings before opening the app

> Real robot control currently targets Android. The `flutter_bluetooth_serial` plugin used by this project does not provide HC-05/SPP support for iOS or web.

## Command Protocol

Commands are sent as a single ASCII character with no trailing newline.

| Control | Command | Meaning |
| --- | --- | --- |
| Up | `F` | Forward |
| Down | `B` | Backward |
| Left | `L` | Turn left |
| Right | `R` | Turn right |
| A | `A` | Custom action |
| B | `C` | Custom action |
| X | `X` | Custom action |
| Y | `Y` | Custom action |
| Release | `S` | Stop |

Example Arduino-side logic:

```cpp
if (Serial.available()) {
  char command = Serial.read();
  // Handle F, B, L, R, S, A, C, X, Y
}
```

## Android Permissions

The app requests Bluetooth scan/connect and location permissions. The Bluetooth serial plugin may require location access to list paired devices on some Android versions.

If no devices appear:

- Pair the HC-05/HC-06 in Android Bluetooth settings first
- Grant Bluetooth and location permissions
- Tap refresh in the app
- Restart Bluetooth if the module was recently powered off

## Getting Started

```bash
flutter pub get
flutter run
```

Build a debug APK:

```bash
flutter build apk --debug
```

Check the code:

```bash
flutter analyze
```

## Project Structure

- `lib/services/` - Bluetooth transport and command sending
- `lib/viewmodels/` - Provider-based Bluetooth state management
- `lib/views/` - Connection and control screens
- `lib/widgets/` - Press-sensitive control buttons
- `lib/theme/` - App colors and Material theme

## Dependencies

- `flutter_bluetooth_serial` - Classic Bluetooth serial communication
- `permission_handler` - Runtime permission requests
- `provider` - State management
- `google_fonts` - App typography
