
enum NotificationScheduled {
  oneTime(0),
  daily(1),
  weekly(2),
  ;

  const NotificationScheduled(this.type);
  final int type;
}
