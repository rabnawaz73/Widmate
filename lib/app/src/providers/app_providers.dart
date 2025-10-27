import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final accentColorProvider = StateProvider<Color>((ref) => const Color(0xFF3B82F6));
final layoutProvider = StateProvider<String>((ref) => 'Comfortable');
