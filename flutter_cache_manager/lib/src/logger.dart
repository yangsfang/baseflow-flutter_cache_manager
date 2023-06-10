import 'package:logging/logging.dart';

/// Instance of the cache manager. Can be set to a custom one if preferred.
Logger cacheLogger = Logger('cacheLogger');

extension ConventionalLogger on Logger {
  void debug(Object? message, [Object? error, StackTrace? stackTrace]) =>
      config(message, error, stackTrace);

  void verbose(Object? message, [Object? error, StackTrace? stackTrace]) =>
      fine(message, error, stackTrace);

  void error(Object? message, [Object? error, StackTrace? stackTrace]) =>
      severe(message, error, stackTrace);

  void fatal(Object? message, [Object? error, StackTrace? stackTrace]) =>
      shout(message, error, stackTrace);
}
