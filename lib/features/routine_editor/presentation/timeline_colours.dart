import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../domain/routine_timeline.dart';

/// The colours of one kind of item (or of a DB and a DA together), in the
/// roles of a Material 3 custom colour: [colour] for text and marks on the
/// surface, [onColour] on top of it, and the softer [container] /
/// [onContainer] pair for filled backgrounds.
class ItemColours {
  const ItemColours({
    required this.colour,
    required this.onColour,
    required this.container,
    required this.onContainer,
  });

  final Color colour;
  final Color onColour;
  final Color container;
  final Color onContainer;

  /// The colours of [kind] in [scheme] (light or dark): DB blue, DA red,
  /// risks amber, S green.
  static ItemColours of(TimelineKind kind, ColorScheme scheme) =>
      _get(_hues[kind]!, scheme);

  /// The colours of a DB and a DA performed together: purple.
  static ItemColours pair(ColorScheme scheme) => _get(_pairHue, scheme);

  // Distinct hues, so items are told apart at a glance (e.g. from across
  // the gym in Play mode).
  static const _hues = {
    TimelineKind.db: Color(0xFF1E88E5),
    TimelineKind.da: Color(0xFFE53935),
    TimelineKind.risk: Color(0xFFFFB300),
    TimelineKind.danceStep: Color(0xFF43A047),
  };
  static const _pairHue = Color(0xFF8E24AA);

  static final _cache = <(Color, Color, Brightness), ItemColours>{};

  /// [hue] nudged towards the theme's colour (Material's "harmonise", so it
  /// sits in the warm theme while keeping its own hue), at the tones
  /// Material uses for custom colours in light and dark mode.
  static ItemColours _get(Color hue, ColorScheme scheme) =>
      _cache.putIfAbsent((hue, scheme.primary, scheme.brightness), () {
        final harmonised = Hct.fromInt(
          Blend.harmonize(hue.toARGB32(), scheme.primary.toARGB32()),
        );
        final palette = TonalPalette.of(harmonised.hue, harmonised.chroma);
        Color tone(int t) => Color(palette.get(t));
        return scheme.brightness == Brightness.light
            ? ItemColours(
                colour: tone(40),
                onColour: tone(100),
                container: tone(90),
                onContainer: tone(10),
              )
            : ItemColours(
                colour: tone(80),
                onColour: tone(20),
                container: tone(30),
                onContainer: tone(90),
              );
      });
}
