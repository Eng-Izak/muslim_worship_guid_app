enum RoutingNames {
  splash("/"),
  home("/home"),
  prayerTimes("/prayerTimes"),
  azkar("/azkar"),
  hadis("/hadis"),
  userSettings("/user_settings"),
  quran("/quran"),
  radio("/radio"),
  qibla("/qibla"),
  adhanAlarm("/adhan_alarm");

  final String route;
  const RoutingNames(this.route);

  static RoutingNames? fromRoute(String? route) {
    return RoutingNames.values.firstWhere(
      (e) => e.route == route,
      orElse: () => RoutingNames.splash,
    );
  }
}
