class WeekMetrics {
  final String? linebreak;
  final String? background;
  final String? icon;
  final String? iconColor;
  final String? label;
  final String? value;
  final String? labelColor;
  final String? valueColor;

  WeekMetrics({
    this.linebreak,
    this.background,
    this.icon,
    this.iconColor,
    this.label,
    this.value,
    this.labelColor,
    this.valueColor,
  });

  factory WeekMetrics.fromJson(Map<String, dynamic> json) {
    return WeekMetrics(
      linebreak: json['linebreak'] as String?,
      background: json['background'] as String?,
      icon: json['icon'] as String?,
      iconColor: json['iconColor'] as String?,
      label: json['label'] as String?,
      value: json['value'] as String?,
      labelColor: json['labelColor'] as String?,
      valueColor: json['valueColor'] as String?,
    );
  }
}
