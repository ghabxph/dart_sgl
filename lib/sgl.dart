class Principals implements Iterator {

  int iteratorIndex = -1;

  List<_Principal> _principals = <_Principal>[];

  //List<Map> get principals { var map = <Map>[]; for (var principal in _principals) { map.add(principal.map); } return map; }
  int get count => _principals.length;

  Principals([List<Map> principals]) {
    if (principals == null) return;
    for (var principal in principals) {
      _principals.add(_Principal(principal));
    }
  }

  Principals add(List<_Principal> principals) { _principals = _principals + principals; return this; }

  _Sgl sgl(Map rule) { var sgl = _Sgl(this); sgl.setRule(rule); return sgl; }

  Principals setKeyAlias(String key, String alias) {
    for (var principal in _principals) {
      principal.setKeyAlias(key, alias);
    }
    return this;
  }

  Principals transformKeyTo(String key, String transformTo) {
    for (var principal in _principals) {
      principal.transformKeyTo(key, transformTo);
    }
    return this;
  }

  /// Return if all qualities specified in the given query exist.
  List<_Principal> findPrincipals(Map query) {
    var principals = <_Principal>[];
    for (var principal in _principals) {
      var match = true;
      query.forEach((key, value) => { match = match && principal.key(key) is List });
      if (match) principals.add(principal);
    }
    return principals;
  }

  Principals get iterator { iteratorIndex = -1; return this; }

  @override
  _Principal get current => _principals[iteratorIndex];

  @override
  bool moveNext() => ++iteratorIndex < _principals.length;
}

class _Principal {

  final List<_Key> _keys = <_Key>[];

  Map get map { final map = {}; for (var key in _keys) map[key._key] = key._value; return map; }

  _Principal(Map principal) { principal.forEach((key, value) { _keys.add(_Key().setKeyValue(key, value)); }); }

  void setKeyAlias(String key, String alias) {
    for (var _key in _keys) {
      if (_key._key == key) {
        _key._keyModifier.setAlias(alias);
      }
    }
  }

  void transformKeyTo(String key, String transformTo) {
    for (var _key in _keys) {
      if (_key._key == key) {
        _key._keyModifier.setTransformTo(transformTo);
      }
    }
  }

  _Key key(String key) {

    // Look for given key
    for (var _key in _keys) if (_key._keyModifier.transformTo == key) return _key;

    // Return null if key does not exist
    return null;
  }
}

class _Key {

  _KeyModifier _keyModifier;

  String _key;

  dynamic _value;

  _Key() { _keyModifier = _KeyModifier(); }

  _Key setKeyValue(String key, dynamic value) { _key = key; _value = value; _keyModifier.setTransformTo(key); return this; }
}

class _KeyModifier {

  String _alias;

  String _transformTo;

  String get alias => _alias;

  String get transformTo => _transformTo;

  void setAlias(String alias) { _alias = alias; }

  void setTransformTo(String transformTo) { _transformTo = transformTo; }
}

class _Sgl {

  Principals _principals;

  final Principals _qualifyingPrincipals = Principals();

  Map _rule;

  Principals get qualifyingPrincipals => _qualifyingPrincipals;

  _Sgl(Principals principals) { _principals = principals; }

  _Sgl setRule(Map rule) {

    // Set SGL rule
    _rule = rule;

    // Get principal iterator
    var iterator = _principals.iterator;

    // Look from principals and add qualifying principals on match
    while (iterator.moveNext()) {

      // Qualify a principal if evaluation turns out to be true.
      if (_Condition.init(iterator.current).evaluate(_rule['when'])) qualifyingPrincipals.add(<_Principal>[iterator.current]);
    }

    // Return this instance
    return this;
  }

  /// TODO: Sgl.satisfies
  bool satisfies(List<_Principal> principals) {}
}

abstract class _Condition {

  _Principal _principal;

  static _Condition init(_Principal principal) { return _ConditionWithCustom(principal); }

  bool evaluate(Map rule);
}

class _ConditionWithCustom extends _Condition {

  _ConditionWithCustom(_Principal principal) { _principal = principal; }

  @override
  bool evaluate(Map rule) {
    var result = false;
    rule.forEach((key, value) {
        if (result) return;
        var k = _principal.key(key);
        if (key == 'any') result =  _ConditionWithAny(_principal).evaluate(rule);
        else if (key == 'all') result = _ConditionWithAll(_principal).evaluate(rule);
        else result = k != null && (k._value == value || k._value.contains(value));
    });
    return result;
  }
}

class _ConditionWithAny extends _Condition {

  _ConditionWithAny(_Principal principal) { _principal = principal; }

  @override
  bool evaluate(Map rule) {
    for (var _rule in rule['any']) if (_ConditionWithCustom(_principal).evaluate(_rule)) return true;
    return false;
  }
}

class _ConditionWithAll extends _Condition {

  _ConditionWithAll(_Principal principal) { _principal = principal; }

  @override
  bool evaluate(Map rule) {
    for (var _rule in rule['all']) if (!_ConditionWithCustom(_principal).evaluate(_rule)) return false;
    return true;
  }
}
