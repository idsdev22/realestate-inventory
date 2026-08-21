import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init error in background handler: $e');
  }
  debugPrint('FCM Background message received: ${message.messageId}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  StorageService? _storageService;
  String? _fcmToken;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken ?? _storageService?.getFcmToken();

  /// Initialize Firebase & FCM
  Future<void> initialize({required StorageService storageService}) async {
    _storageService = storageService;

    // Load any previously cached token
    _fcmToken = _storageService?.getFcmToken();

    try {
      // Initialize Firebase App if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Register background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions
      await requestPermission();

      // Configure foreground notification presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Fetch FCM Token
      await fetchFcmToken();

      // Listen for token refreshes
      _setupTokenRefreshListener();

      // Setup message listeners
      _setupMessageListeners();

      _isInitialized = true;
      debugPrint('FcmService initialized successfully. Token: $_fcmToken');
    } catch (e, stack) {
      debugPrint('FcmService initialization skipped or failed: $e\n$stack');
      // If Firebase config is not yet placed in native folders, app continues safely.
    }
  }

  /// Request notification permission for iOS and Android 13+
  Future<NotificationSettings?> requestPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Notification permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return null;
    }
  }

  /// Fetch and cache current FCM Token
  Future<String?> fetchFcmToken() async {
    try {
      String? token;
      if (kIsWeb) {
        token = await FirebaseMessaging.instance.getToken();
      } else if (Platform.isIOS || Platform.isMacOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null || kDebugMode) {
          token = await FirebaseMessaging.instance.getToken();
        }
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token != null && token.isNotEmpty) {
        _fcmToken = token;
        await _storageService?.saveFcmToken(token);
        debugPrint('FCM Token retrieved and saved: $token');
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return _fcmToken;
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        await _storageService?.saveFcmToken(newToken);
      }).onError((err) {
        debugPrint('Error onTokenRefresh: $err');
      });
    } catch (e) {
      debugPrint('Error setting up onTokenRefresh listener: $e');
    }
  }

  /// Listen for incoming messages
  void _setupMessageListeners() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title} - ${message.notification?.body}');
      });

      // Handle message when user taps notification to open app from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Notification opened from background: ${message.data}');
      });

      // Handle initial message when app opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('FCM Initial message from terminated state: ${message.data}');
        }
      });
    } catch (e) {
      debugPrint('Error setting up message listeners: $e');
    }
  }

  /// Get current token or fetch fresh one if missing
  Future<String?> getOrFetchToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      return _fcmToken;
    }
    final cached = _storageService?.getFcmToken();
    if (cached != null && cached.isNotEmpty) {
      _fcmToken = cached;
      return cached;
    }
    return await fetchFcmToken();
  }
}
