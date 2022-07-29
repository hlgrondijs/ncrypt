import 'dart:math';

import 'dart:io';

class Entropizer {
  final List<String> defaultClasses = [
    'lowercase',
    'uppercase',
    'numeric',
    'symbolsCommon',
    'symbolsUncommon'
  ];
  static String symbolsCommon = ' ,.?!';
  static String symbolsUncommon = '"£\$%^&*()-_=+[]{};:\'@#~<>/\\|`¬¦';

  List<Map<String, dynamic>> classes = [];

  var presetClasses = {
    'lowercase': { 'regex': RegExp(r"[a-z]"), 'size': 26},
    'uppercase': { 'regex': RegExp(r"[A-Z]"), 'size': 26 },
		'numeric': { 'regex': RegExp(r"[0-9]"), 'size': 10 },
		'symbols': { 'characters': symbolsCommon + symbolsUncommon },
		'symbolsCommon': { 'characters': symbolsCommon },
		'symbolsUncommon': { 'characters': symbolsUncommon },
		'hexadecimal': { 'regex': RegExp(r"[a-fA-F0-9]"), 'size': 16 }
  };

  Entropizer() {
    defaultClasses.forEach((dclass) {
      classes.add(presetClasses[dclass]);
    });
  }

  int evaluateClass(Map<String, dynamic> characterClass, String password) {
    if (characterClass.containsKey('regex') && characterClass['regex'].hasMatch(password)) {
      return characterClass['size'];
    } else if (characterClass.containsKey('characters')) {
      characterClass['characters'].split("").forEach((String char) {
        if (password.indexOf(char) > -1) {
          return characterClass['characters'].length;
        }
      });
    }
    return 0;
  }

  double evaluate(String password) {
    var alphabetSize = 0;

    classes.forEach((cclass) {
      alphabetSize += evaluateClass(cclass, password);
    });

    if (alphabetSize == 0) {
      return 0;
    }

    return log(alphabetSize) / log(2) * password.length;
  }
}