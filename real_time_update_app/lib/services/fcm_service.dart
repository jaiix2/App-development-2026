import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmMessageResult {
  const FcmMessageResult({
    required this.status,
    required this.diagnostic,
    this.assetPath,
  });

  final String status;
  final String diagnostic;
  final String? assetPath;

  bool get isValid => assetPath != null;
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _registrationSubscription;
  bool _disposed = false;

  Future<void> initialize({
    required void Function(RemoteMessage message, String handler) onMessage,
    required void Function(String status) onStatus,
  }) async {
    if (_disposed || _foregroundSubscription != null) {
      throw StateError('FCMService can only be initialized once.');
    }

    void receive(RemoteMessage message, String handler) {
      if (_disposed) return;
      debugPrint('$handler received message ${message.messageId ?? "(no ID)"}');
      onMessage(message, handler);
    }

    void reportStreamError(Object error, StackTrace stackTrace) {
      debugPrint('FCM stream error: $error\n$stackTrace');
      if (!_disposed) {
        onStatus('Messaging error: $error');
      }
    }

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) => receive(message, 'onMessage'),
      onError: reportStreamError,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => receive(message, 'onMessageOpenedApp'),
      onError: reportStreamError,
    );
    _registrationSubscription = _messaging.onRegistered.listen((
      installationId,
    ) {
      if (_disposed) return;
      debugPrint('FCM installation ID (development only): $installationId');
      onStatus('FCM registration completed. See the development log.');
    }, onError: reportStreamError);

    final initialMessage = await _messaging.getInitialMessage();
    if (_disposed) return;
    if (initialMessage != null) {
      receive(initialMessage, 'getInitialMessage');
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_disposed) return;
    onStatus('Notification permission: ${settings.authorizationStatus.name}');

    if (kIsWeb) {
      onStatus('Web FCM token retrieval requires a configured VAPID key.');
      return;
    }

    final registration = _messaging.onRegistered.first.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw StateError(
        'FCM registration timed out. Check network and Firebase setup.',
      ),
    );
    await _messaging.register();
    final installationId = await registration;
    if (_disposed) return;
    debugPrint('FCM installation ID (development only): $installationId');
  }

  static FcmMessageResult processMessage(RemoteMessage message) {
    final asset = message.data['asset'];
    const supportedAssets = {
      'default': 'assets/default.png',
      'promo': 'assets/promo.png',
    };
    final assetPath = supportedAssets[asset];
    if (assetPath == null) {
      final assetDescription = asset is String
          ? '"$asset"'
          : 'missing or non-text';
      return FcmMessageResult(
        status: 'Message was not applied',
        diagnostic:
            'Unsupported asset $assetDescription. Use "default" or "promo".',
      );
    }

    if (message.data['action'] != 'update_ui') {
      return const FcmMessageResult(
        status: 'Message was not applied',
        diagnostic: 'Invalid or missing action. Expected action=update_ui.',
      );
    }

    return FcmMessageResult(
      status: 'Message processed successfully. Current asset: $asset.',
      diagnostic:
          'Payload processed successfully (action=update_ui, asset=$asset).',
      assetPath: assetPath,
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _registrationSubscription?.cancel();
  }
}
