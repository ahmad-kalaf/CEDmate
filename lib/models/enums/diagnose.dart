enum Diagnose {
  colitisUlcerosa('Colitis Ulcerosa'),
  morbusCrohn('Morbus Crohn'),
  sonstigeCED('Sonstige CED Formen'),
  keine('Keine');

  final String label;
  const Diagnose(this.label);
}
