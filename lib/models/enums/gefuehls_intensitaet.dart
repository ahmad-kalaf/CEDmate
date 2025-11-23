enum GefuehlsIntensitaet {
  sehrTraurig('Sehr traurig'),
  traurig('Traurig'),
  leichtTraurig('Leicht traurig'),
  neutral('Neutral bis leicht negativ'),
  ausgeglichen('Ausgeglichen'),
  leichtPositiv('Leicht positiv'),
  positiv('Positiv'),
  sehrPositiv('Sehr positiv'),
  gluecklich('Glücklich'),
  sehrGluecklich('Sehr glücklich');

  final String beschreibung;

  const GefuehlsIntensitaet(this.beschreibung);
}
