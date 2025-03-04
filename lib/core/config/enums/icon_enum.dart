import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

enum HabitIcon {
  home(LineIcons.home, 'home'),
  heart(LineIcons.heart, 'heart'),
  running(LineIcons.running, 'running'),
  book(LineIcons.book, 'book'),
  pen(LineIcons.pen, 'pen'),
  calendar(LineIcons.calendar, 'calendar'),
  clock(LineIcons.clock, 'clock'),
  smilingFace(LineIcons.smilingFace, 'smilingFace'),
  star(LineIcons.star, 'star'),
  coffee(LineIcons.coffee, 'coffee'),
  guitar(LineIcons.guitar, 'guitar'),
  bicycle(LineIcons.bicycle, 'bicycle'),
  music(LineIcons.music, 'music'),
  sun(LineIcons.sun, 'sun'),
  moon(LineIcons.moon, 'moon'),
  leaf(LineIcons.leaf, 'leaf');

  final IconData icon;
  final String name;

  const HabitIcon(this.icon, this.name);

  // Get icon from name
  static HabitIcon fromName(String name) {
    return HabitIcon.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HabitIcon.star, // Default icon
    );
  }

  // Get icon data from name
  static IconData getIconData(String name) {
    return fromName(name).icon;
  }

  // Get all available icons
  static List<IconData> getAllIcons() {
    return HabitIcon.values.map((e) => e.icon).toList();
  }
}
