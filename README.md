# BRABOTS ctrl

Flutter‑based Bluetooth controller for Arduino‑powered robots, developed for the **BRABOTS** robotics competition.

## Overview

This app connects to an HC‑05 (or compatible) Bluetooth module on an Arduino car. It sends single‑character commands to control movement, stop, and additional actions.

## Features

- Scan and connect to paired Bluetooth devices
- Visual connection status and error reporting
- Directional pad (Forward, Back, Left, Right)
- Four face buttons (A, B, X, Y) mapped to custom commands
- Haptic feedback on button press
- Automatic landscape orientation lock on the control screen
- Stop command (`S`) sent automatically when a button is released

## Command Mapping

| Button | Command |
|--------|---------|
| ↑ (Up) | `F` (Forward) |
| ↓ (Down) | `B` (Backward) |
| ← (Left) | `L` (Left turn) |
| → (Right) | `R` (Right turn) |
| A | `A` |
| B | `C` |
| X | `X` |
| Y | `Y` |

> All buttons send `S` (Stop) when released.

## Getting Started

1. Clone the repository  
   `git clone https://github.com/marcosschlick/brabots_ctrl.git`

2. Navigate to the project folder  
   `cd brabots_ctrl`

3. Get dependencies  
   `flutter pub get`

4. Run the app  
   `flutter run`

> On Android, ensure location and Bluetooth permissions are granted. The app requests them automatically.

## Project Structure

- `lib/views/` – Connection and control screens
- `lib/viewmodels/` – Bluetooth state management (Provider)
- `lib/services/` – Bluetooth communication logic
- `lib/widgets/` – Custom press‑sensitive buttons
- `lib/theme/` – App theme and styling

## Dependencies

- `flutter_bluetooth_serial` – Bluetooth communication
- `permission_handler` – Runtime permissions
- `provider` – State management
- `google_fonts` – Poppins font
