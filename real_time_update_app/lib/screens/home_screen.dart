import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:real_time_update_app/services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FCMService _fcmService = FCMService();

  String _status = 'Waiting for an FCM message';
  String _imagePath = 'assets/default.png';
  String _lastHandler = 'None';
  String _messageId = 'None';
  String _diagnostic = 'Initializing Firebase Messaging...';
  int _receiptCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeMessaging());
  }

  Future<void> _initializeMessaging() async {
    try {
      await _fcmService.initialize(
        onMessage: _processMessage,
        onStatus: _reportStatus,
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firebase initialization error: $error\n$stackTrace');
      _reportStatus('Messaging error (${error.code}): ${error.message}');
    } on StateError catch (error, stackTrace) {
      debugPrint('FCM setup error: $error\n$stackTrace');
      _reportStatus('Messaging setup error: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Unexpected FCM setup error: $error\n$stackTrace');
      _reportStatus('Messaging setup error: $error');
    }
  }

  void _reportStatus(String status) {
    if (!mounted) return;
    if (_receiptCount == 0 || status.startsWith('Messaging error')) {
      setState(() {
        _diagnostic = status;
      });
    }
  }

  void _processMessage(RemoteMessage message, String handler) {
    if (!mounted) return;
    final result = FCMService.processMessage(message);
    setState(() {
      _receiptCount += 1;
      _lastHandler = handler;
      _messageId = message.messageId ?? '(no message ID)';
      _status = result.status;
      _diagnostic = result.diagnostic;
      if (result.assetPath != null) {
        _imagePath = result.assetPath!;
      }
    });
  }

  @override
  void dispose() {
    unawaited(_fcmService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Cloud Messaging')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoCard(
            label: 'Current Status',
            child: Text(_status, key: const ValueKey('current-status')),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            label: 'Current Image',
            child: Image.asset(
              _imagePath,
              key: const ValueKey('current-image'),
              height: 190,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Could not load image "$_imagePath": $error');
                return Text('Could not load $_imagePath');
              },
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            label: 'Last Handler Used',
            child: Text(_lastHandler, key: const ValueKey('last-handler')),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            label: 'Receipt Count',
            child: Text('$_receiptCount', key: const ValueKey('receipt-count')),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            label: 'Message ID',
            child: Text(_messageId, key: const ValueKey('message-id')),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            label: 'Diagnostic Message',
            child: Text(
              _diagnostic,
              key: const ValueKey('diagnostic-message'),
              style: TextStyle(
                color: _diagnostic.startsWith('Unsupported') ||
                        _diagnostic.startsWith('Invalid')
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
