import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/xboard/config/utils/config_file_loader.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/features/remote_task/remote_task_manager.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_racing_service.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';

RemoteTaskManager? remoteTaskManager;

Future<void> _initializeXBoardServices() async {
  final configSettings = await ConfigFileLoader.loadFromFile();
  await _loadSecurityConfig();
  await XBoardConfig.initialize(settings: configSettings);
}

Future<void> _loadSecurityConfig() async {
  try {
    final certConfig = await ConfigFileLoaderHelper.getCertificateConfig();
    final certPath = certConfig['path'] as String?;
    final certEnabled = certConfig['enabled'] as bool? ?? true;
    if (certEnabled && certPath != null && certPath.isNotEmpty) {
      DomainRacingService.setCertificatePath(certPath);
    }
  } catch (_) {
    // Security config is optional; SDK/provider code will fall back to defaults.
  }
}

Future<void> _initializeRemoteTaskManager() async {
  try {
    remoteTaskManager = await RemoteTaskManager.create();
    remoteTaskManager
      ?..initialize()
      ..start();
  } catch (_) {
    remoteTaskManager = null;
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      remoteTaskManager?.dispose();
    }
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeXBoardServices();
    await _initializeRemoteTaskManager();
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
    final version = await system.version;
    final container = await globalState.init(version);
    HttpOverrides.global = FlClashHttpOverrides();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    return runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}
