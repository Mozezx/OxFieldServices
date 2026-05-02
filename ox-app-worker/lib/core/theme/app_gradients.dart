import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF092F3D), Color(0xFF0D3F52)],
  );

  static const card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D3F52), Color(0xFF092F3D)],
  );

  static const accent = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF03FC30), Color(0xFF00C828)],
  );

  static const surface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A4A62), Color(0xFF0D3F52)],
  );

  static const overlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xF2092F3D)],
  );
}
