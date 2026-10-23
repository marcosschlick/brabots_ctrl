import 'dart:async';

import 'package:ctrl/services/bluetooth_service.dart';
import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/viewmodels/bluetooth_viewmodel.dart';
import 'package:ctrl/views/connection_screen.dart';
import 'package:ctrl/views/control_screen.dart';
import 'package:ctrl/widgets/direction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeBluetoothTransport implements BluetoothTransport {
  bool connected = false;
  final List<String> sentCommands = [];
  final StreamController<void> _connectionLostController =
      StreamController<void>.broadcast();
  final List<BluetoothDevice> devices = const [
    BluetoothDevice(name: 'HC-05', address: '00:11:22:33:44:55'),
  ];

  @override
  bool get isConnected => connected;

  @override
  List<BluetoothDevice> get bondedDevices => devices;

  @override
  Stream<void> get onConnectionLost => _connectionLostController.stream;

  @override
  Future<bool> enableBluetooth() async => true;

  @override
  Future<List<BluetoothDevice>> loadBondedDevices() async => devices;

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    connected = true;
    return true;
  }

  @override
  Future<bool> sendCommand(String command) async {
    sentCommands.add(command);
    return connected;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  void dispose() {
    unawaited(_connectionLostController.close());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<BluetoothViewModel> pumpConnectionScreen(
    WidgetTester tester, {
    required Size size,
    bool disableAnimations = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    final viewModel = BluetoothViewModel(service: FakeBluetoothTransport());
    await viewModel.init();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: MaterialApp(
          theme: AppTheme.theme,
          home: const ConnectionScreen(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return viewModel;
  }

  Future<BluetoothViewModel> pumpControlScreen(
    WidgetTester tester, {
    required Size size,
    FakeBluetoothTransport? transport,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    final bluetooth = transport ?? FakeBluetoothTransport();
    final viewModel = BluetoothViewModel(service: bluetooth);
    await viewModel.connectToDevice(
      const BluetoothDevice(name: 'HC-05', address: '00:11:22:33:44:55'),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: MaterialApp(theme: AppTheme.theme, home: const ControlScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DirectionButton), findsNWidgets(8));
    return viewModel;
  }

  Future<void> disposeScreen(
    WidgetTester tester,
    BluetoothViewModel viewModel,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('connection screen fits portrait phone layout', (tester) async {
    final viewModel = await pumpConnectionScreen(
      tester,
      size: const Size(360, 800),
    );

    expect(find.text('Dispositivos pareados'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsNothing);

    await disposeScreen(tester, viewModel);
  });

  testWidgets('connection screen stacks on compact landscape phones', (
    tester,
  ) async {
    final viewModel = await pumpConnectionScreen(
      tester,
      size: const Size(640, 360),
    );

    expect(find.text('HC-05'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsNothing);

    await disposeScreen(tester, viewModel);
  });

  testWidgets('connection screen uses two panels on wide tablets', (
    tester,
  ) async {
    final viewModel = await pumpConnectionScreen(
      tester,
      size: const Size(1024, 768),
    );

    expect(find.byType(VerticalDivider), findsOneWidget);

    await disposeScreen(tester, viewModel);
  });

  testWidgets('connection status transition respects reduced motion', (
    tester,
  ) async {
    final viewModel = await pumpConnectionScreen(
      tester,
      size: const Size(360, 800),
      disableAnimations: true,
    );

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, Duration.zero);

    await disposeScreen(tester, viewModel);
  });

  for (final size in const [Size(640, 360), Size(915, 412), Size(1280, 800)]) {
    testWidgets('landscape controls fit ${size.width}x${size.height}', (
      tester,
    ) async {
      final viewModel = await pumpControlScreen(tester, size: size);

      await disposeScreen(tester, viewModel);
    });
  }

  testWidgets('compact landscape controls still send press and release', (
    tester,
  ) async {
    final transport = FakeBluetoothTransport();
    final viewModel = await pumpControlScreen(
      tester,
      size: const Size(640, 360),
      transport: transport,
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DirectionButton).first),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(transport.sentCommands, ['F', 'S']);

    await disposeScreen(tester, viewModel);
  });
}
