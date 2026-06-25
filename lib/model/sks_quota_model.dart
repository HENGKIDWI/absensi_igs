class SksQuota {
  final double ips;
  final String ipsRange;
  final int maxSks;
  final int currentSks;
  final int remainingSks;

  SksQuota({
    required this.ips,
    required this.ipsRange,
    required this.maxSks,
    required this.currentSks,
    required this.remainingSks,
  });

  factory SksQuota.fromJson(Map<String, dynamic> json) {
    return SksQuota(
      ips: (json['ips'] as num).toDouble(),
      ipsRange: json['ips_range'],
      maxSks: json['max_sks'],
      currentSks: json['current_sks'],
      remainingSks: json['remaining_sks'],
    );
  }
}
