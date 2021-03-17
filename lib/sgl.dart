class Principals implements Iterator {

  int iteratorIndex = -1;

  List<Principal> _principals = <Principal>[];

  List<Map> get principals { var map = <Map>[]; for (var principal in _principals) { map.add(principal.map); } return map; }

  Principals();

  Principals add(List<Principal> principals) { _principals = _principals + principals; return this; }

  _Sgl sgl(Map rule) { var sgl = _Sgl(this); sgl.setRule(rule); return sgl; }

  /// Return if all qualities specified in the given query exist.
  List<Principal> findPrincipals(Map query) {
    var principals = <Principal>[];
    for (var principal in _principals) {
      var match = true;
      query.forEach((key, value) => { match = match && principal.key(key) is List });
      if (match) principals.add(principal);
    }
    return principals;
  }

  Iterator get iterator { iteratorIndex = -1; return this; }

  @override
  // TODO: implement current
  Principal get current => _principals[iteratorIndex];

  @override
  bool moveNext() => ++iteratorIndex < _principals.length;
}

class Principal {

  final List<_Key> _keys = <_Key>[];

  Map get map { Map map; for (var key in _keys) { map[key.key] = key.value; } return map; }

  Principal(Map principal) { principal.forEach((key, value) { _keys.add(_Key(this).setKeyValue(key, value)); }); }

  _Key key(String key) {

    // Look for given key
    for (var _key in _keys) if (_key.keyModifier.transformTo == key) return _key;

    // Throw exception if key does not exist.
    throw Exception('Given key does not exist.');
  }
}

class _Key {

  Principal _principal;

  _KeyModifier _keyModifier;

  String _key;

  dynamic _value;

  _KeyModifier get keyModifier => _keyModifier;

  String get key => _key;

  dynamic get value => _value;

  _Key(Principal principal) { _principal = principal; _keyModifier = _KeyModifier(this); }

  _Key setKeyValue(String key, dynamic value) { _key = key; _value = value; return this; }
}

class _KeyModifier {

  _Key _key;

  String _alias;

  String _transformTo;

  String get alias => _alias;

  String get transformTo => transformTo;

  _KeyModifier(_Key key) { _key = key; _transformTo = key.key; }

  void setAlias(String alias) { _alias = alias; }

  void setTransformTo(String transformTo) { _transformTo = transformTo; }
}

class _Sgl {

  Principals _principals;

  final Principals _qualifyingPrincipals = Principals();

  Map _rule;

  Map get rule => _rule;

  Principals get qualifyingPrincipals => _qualifyingPrincipals;

  _Sgl(Principals principals) { _principals = principals; }

  /// TODO: Sgl.setRule
  _Sgl setRule(Map rule) {

    // Set SGL rule
    _rule = rule;

    // Get principal iterator
    var iterator = _principals.iterator;

    // Look from principals and add qualifying principals on match
    while (iterator.moveNext()) _Evaluator.init(this).evaluate( iterator.current);

    // Return this instance
    return this;
  }

  /// TODO: Sgl.satisfies
  bool satisfies(List<Principal> principals) {}
}

abstract class _Evaluator implements Iterator {

  _Sgl _sgl;

  static _Evaluator _firstEvaluator;

  static _Evaluator _currentEvaluator;

  _Evaluator _nextEvaluator;

  String get evaluatorName;

  Iterator get iterator { _Evaluator._currentEvaluator = null; return this; }

  static _Evaluator init(_Sgl sgl) {

    var nextEvaluator = _DefaultEvaluator();

    nextEvaluator.setAsFirstEvaluator();

    nextEvaluator.setSgl(sgl);

    nextEvaluator.addToChain(_AnyEvaluator());

    return nextEvaluator;
  }

  void setAsFirstEvaluator() { _Evaluator._firstEvaluator = this; }

  void setSgl(_Sgl sgl) { _sgl = sgl; }

  _Evaluator addToChain(_Evaluator evaluator) { _nextEvaluator = evaluator; _nextEvaluator.setSgl(_sgl); return _nextEvaluator; }

  void evaluate(Principal principal);

  void next(Principal principal) { _nextEvaluator.evaluate(principal); }

  _Evaluator findEvaluator(_Evaluator matchingEvaluator) {
    var _iterator = iterator;

    while (iterator.moveNext()) if (iterator.current.isTypeOf(matchingEvaluator)) return iterator.current;

    throw Exception('Iterator ${matchingEvaluator.evaluatorName} does not exist.');
  }

  bool isTypeOf(_Evaluator matchingIterator) => evaluatorName == matchingIterator.evaluatorName;

  @override
  // TODO: implement current
  get current => throw UnimplementedError();

  @override
  bool moveNext() {

    if (_Evaluator._currentEvaluator == null) {
      _Evaluator._currentEvaluator = _Evaluator._firstEvaluator;
    } else {
      _Evaluator._currentEvaluator = _nextEvaluator;
    }
    // TODO: implement moveNext
    throw UnimplementedError();
  }
}

class _DefaultEvaluator extends _Evaluator {

  @override
  // TODO: implement evaluatorName
  String get evaluatorName => throw UnimplementedError();

  @override
  void evaluate(Principal principal) {
    // TODO: implement evaluate
  }
}

class _AnyEvaluator extends _Evaluator {

  @override
  // TODO: implement current
  get current => throw UnimplementedError();

  @override
  bool moveNext() {
    // TODO: implement moveNext
    throw UnimplementedError();
  }

  @override
  // TODO: implement evaluatorName
  String get evaluatorName => throw UnimplementedError();

  @override
  void evaluate(Principal principal) {
    // TODO: implement evaluate
  }
}
