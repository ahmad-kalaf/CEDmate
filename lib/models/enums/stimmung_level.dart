/// Enum für das allgemeine Stimmungs-Level.
enum StimmungLevel { sehrSchlecht, schlecht, neutral, gut, sehrGut }

StimmungLevel parseStimmungLevel(dynamic value) {
  if (value is String) {
    return StimmungLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StimmungLevel.neutral,
    );
  }
  return StimmungLevel.neutral;
}
