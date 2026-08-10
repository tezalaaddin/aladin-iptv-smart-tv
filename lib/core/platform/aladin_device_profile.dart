import 'package:flutter/widgets.dart';

enum AladinDeviceClass { phone, tablet, television }

@immutable
class AladinDeviceProfile {
  const AladinDeviceProfile({
    required this.deviceClass,
    required this.orientation,
    required this.size,
  });

  final AladinDeviceClass deviceClass;
  final Orientation orientation;
  final Size size;

  bool get isPhone => deviceClass == AladinDeviceClass.phone;
  bool get isTablet => deviceClass == AladinDeviceClass.tablet;
  bool get isTelevision => deviceClass == AladinDeviceClass.television;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get useTvNavigation => isTelevision;
  bool get useCompactNavigation => !isTelevision;

  static AladinDeviceProfile of(BuildContext context) {
    final media = MediaQuery.of(context);
    return fromSize(
      media.size,
      directionalNavigation: media.navigationMode == NavigationMode.directional,
    );
  }

  @visibleForTesting
  static AladinDeviceProfile fromSize(
    Size size, {
    bool directionalNavigation = false,
  }) {
    final shortest = size.shortestSide;
    final longest = size.longestSide;
    final orientation = size.width >= size.height
        ? Orientation.landscape
        : Orientation.portrait;

    // Android TV Flutter surfaces are landscape and normally expose at least
    // 900 logical pixels. A landscape phone must never be promoted to TV UI.
    final deviceClass = orientation == Orientation.landscape &&
            directionalNavigation &&
            longest >= 854 &&
            shortest >= 480
        ? AladinDeviceClass.television
        : shortest >= 600
            ? AladinDeviceClass.tablet
            : AladinDeviceClass.phone;

    return AladinDeviceProfile(
      deviceClass: deviceClass,
      orientation: orientation,
      size: size,
    );
  }
}
