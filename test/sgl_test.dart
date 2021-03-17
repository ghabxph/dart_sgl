import 'package:test/test.dart';
import 'package:sgl/sgl.dart';

void testSgl(String description, Principals principals, Map rule, int count, List<Map> matchingPrincipals) {
  test(description, () {
      var i = 0;
      var sgl = principals.sgl(rule);
      var iterator = sgl.qualifyingPrincipals.iterator;
      expect(iterator.count, equals(count));
      while(iterator.moveNext()) {
        expect(iterator.current.map, equals(matchingPrincipals[i++]));
      }
  });
}

void main() {

  var did = didAuthorizationSection();
  var p = Principals(did['authorization']['profiles']).transformKeyTo('key', 'id');
  var rules = did['authorization']['rules'];
  var profiles = did['authorization']['profiles'];

  testSgl('Testing register rule', p, rules[0], 1, [profiles[0]]);
  testSgl('Testing cloud rule', p, rules[1], 1, [profiles[2]]);
  testSgl('Testing edge rule', p, rules[2], 2, [profiles[0], profiles[1]]);
  testSgl('Testing super admin rule', p, rules[3], 2, [profiles[1], profiles[3]]);
}

Map didAuthorizationSection() {
  return {
    'authorization': {
      'profiles': [
        {'key': '#Mv6gmMNa', 'roles': ['edge']},              // an 'edge' key
        {'key': '#izfrNTmQ', 'roles': ['edge', 'biometric']}, // an 'edge' and a 'biometric' key
        {'key': '#02b97c30', 'roles': ['cloud']},             // a 'cloud' key
        {'key': '#H3C2AVvL', 'roles': ['offline']},           // an 'offline' key
      ],
      'rules': [
        {
          'grant': ['register'],
          'when': {'id': '#Mv6gmMNa'},
          'id': '7ac4c6be'
        },
        {
          'grant': ['route', 'authcrypt'],
          'when': {'roles': 'cloud'},
          'id': '98c2c9cc'
        },
        {
          'grant': ['authcrypt', 'plaintext', 'sign'],
          'when': {'roles': 'edge'},
          'id': 'e1e7d7bc'
        },
        {
          'grant': ['key_admin', 'se_admin', 'rule_admin'],
          'when': {
            'any': [{'roles': 'offline'}, {'roles': 'biometric'}],
            'n': 2
          },
          'id': '8586d26c'
        }
      ]
    }
  };
}
