enum StarterPlatform {
  android('android'),
  ios('ios'),
  web('web'),
  linux('linux'),
  macos('macos'),
  windows('windows');

  const StarterPlatform(this.name);

  final String name;

  static StarterPlatform? fromName(String name) {
    for (final platform in values) {
      if (platform.name == name) return platform;
    }

    return null;
  }
}

enum StarterPlatformGroup {
  mobile('mobile', 'Mobile (Android + iOS)', [
    StarterPlatform.android,
    StarterPlatform.ios,
  ]),
  desktop('desktop', 'Desktop (Linux + macOS + Windows)', [
    StarterPlatform.linux,
    StarterPlatform.macos,
    StarterPlatform.windows,
  ]),
  web('web', 'Web', [StarterPlatform.web]);

  const StarterPlatformGroup(this.name, this.label, this.platforms);

  final String name;
  final String label;
  final List<StarterPlatform> platforms;

  static StarterPlatformGroup? fromName(String name) {
    for (final group in values) {
      if (group.name == name) return group;
    }

    return null;
  }
}
