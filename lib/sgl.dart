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

    // Return null if key does not exist
    return null;
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

  final List<_Condition> _satisfiedConditions = <_Condition>[];

  Map _rule;

  Map get rule => _rule;

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
      if (_Condition.init(iterator.current).evaluate(rule)) qualifyingPrincipals.add(iterator.current);
    }

    // Return this instance
    return this;
  }

  /// TODO: Sgl.satisfies
  bool satisfies(List<Principal> principals) {}
}

abstract class _Condition {

  Principal _principal;

  static _Condition init(Principal principal) {
    var condition = _ConditionWithCustom();
    condition._principal = principal;
    return condition;
  }

  bool evaluate(Map rule);
}

class _ConditionWithCustom extends _Condition {

  @override
  bool evaluate(Map rule) {
    rule.forEach((key, value) {
        var k = _principal.key(key);
        if (key == 'any') return _ConditionWithAny().evaluate(rule);
        else if (key == 'all') return _ConditionWithAll().evaluate(rule);
        return k != null && (k.value == value || k.value.contains(value));
    });
  }
}

class _ConditionWithAny extends _Condition {
  @override
  bool evaluate(Map rule) {
    for (var _rule in rule['any']) if (_ConditionWithCustom().evaluate(_rule)) return true;
    return false;
  }
}

class _ConditionWithAll extends _Condition {
  @override
  bool evaluate(Map rule) {
    for (var _rule in rule['all']) if (!_ConditionWithCustom().evaluate(_rule)) return false;
    return true;
  }
}
