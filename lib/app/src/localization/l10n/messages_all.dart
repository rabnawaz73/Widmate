import 'dart:async';
import 'package:intl/message_lookup_by_library.dart';

typedef LibraryLoader = Future<dynamic> Function();
Map<String, LibraryLoader> _deferredLibraries = {};

Future<dynamic> initializeMessages(String localeName) async {
  final lib = _deferredLibraries[localeName];
  if (lib == null) {
    return Future.value(null);
  }
  return lib();
}

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'en';

  @override
  final messages = _notInlinedMessages;

  static final _notInlinedMessages = <String, Function>{};

  static final MessageLookup _instance = MessageLookup();
  static MessageLookup get instance => _instance;
}
