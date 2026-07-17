// ──────────────────────────────────────────────────────────────
// LOGGER SERVICE
// ──────────────────────────────────────────────────────────────
// Centralized logging with level-based filtering.
//
// Why not just use print() everywhere?
//   1. In production you want to disable debug logs — one flag here.
//   2. Formatting is consistent across the codebase.
//   3. Easy to swap for a proper logger (dart:developer, Sentry, etc.).
//
// Usage:
//   final log = LoggerService(minLevel: LogLevel.warning);
//   log.debug('This will NOT print');
//   log.error('This WILL print');

import 'package:flutter/material.dart';

enum LogLevel { debug, info, warning, error }

class LoggerService {
  const LoggerService({LogLevel minLevel = .debug}) : _minLevel = minLevel;
  final LogLevel _minLevel;

  void debug(String message) => _log(.debug, message);

  void info(String message) => _log(.info, message);

  void warning(String message) => _log(.warning, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(.error, message);
    if (error != null) {
      debugPrint('Error Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void _log(LogLevel level, String message) {
    if (level.index >= _minLevel.index) {
      final prefix = switch (level) {
        .info => '[INFO]',
        .error => '[ERROR]',
        .debug => '[DEBUG]',
        .warning => '[WARNING]',
      };
      debugPrint('$prefix $message');
    }
  }
}
