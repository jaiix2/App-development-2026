import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_update_app/services/fcm_service.dart';

void main() {
  group('FCMService.processMessage', () {
    test('maps the default asset', () {
      final result = FCMService.processMessage(
        RemoteMessage(data: {'action': 'update_ui', 'asset': 'default'}),
      );

      expect(result.isValid, isTrue);
      expect(result.assetPath, 'assets/default.png');
      expect(result.status, contains('processed successfully'));
    });

    test('maps the promo asset', () {
      final result = FCMService.processMessage(
        RemoteMessage(data: {'action': 'update_ui', 'asset': 'promo'}),
      );

      expect(result.isValid, isTrue);
      expect(result.assetPath, 'assets/promo.png');
    });

    test('rejects unknown assets without selecting a replacement image', () {
      final result = FCMService.processMessage(
        RemoteMessage(data: {'asset': 'unknown'}),
      );

      expect(result.isValid, isFalse);
      expect(result.assetPath, isNull);
      expect(result.diagnostic, contains('Unsupported asset "unknown"'));
    });

    test('rejects missing or invalid actions safely', () {
      final result = FCMService.processMessage(
        RemoteMessage(data: {'asset': 'promo'}),
      );

      expect(result.isValid, isFalse);
      expect(result.assetPath, isNull);
      expect(result.diagnostic, contains('Invalid or missing action'));
    });
  });
}
