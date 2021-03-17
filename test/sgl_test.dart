import 'package:test/test.dart';
import 'package:sgl/sgl.dart';

void main() {

  test('Test peer did authorization', () {
      var did = didAuthorizationSection();
      var p = Principals(did['authorization']['profiles']).transformKeyTo('key', 'id');
      var rule1 = p.sgl(did['authorization']['rules'][0]);
      var rule2 = p.sgl(did['authorization']['rules'][1]);
      var rule3 = p.sgl(did['authorization']['rules'][2]);
      var rule4 = p.sgl(did['authorization']['rules'][3]);
  });
/*
  test('????', () {
      var p = Principals(<Principal>[
          Principal({'key': '#Mv6gmMNa', 'roles': ['edge']}),
          Principal({'key': '#izfrNTmQ', 'roles': ['edge', 'biometric']}),
          Principal({'key': '#02b97c30', 'roles': ['cloud']}),
          Principal({'key': '#H3C2AVvL', 'roles': ['offline']})
      ]).transformKeyTo('key', 'id');
      var registerSgl = p.sgl({
          'grant': ['register'],
          'when': {'id': '#Mv6gmMNa'},
          'id': '7ac4c6be'
      });
      var authcryptSgl = p.sgl({
          'grant': ['route', 'authcrypt'],
          'when': {'roles': 'cloud'},
          'id': '98c2c9cc'
      });
      var edgeSgl = p.sgl({
          'grant': ['authcrypt', 'plaintext', 'sign'],
          'when': {'roles': 'edge'},
          'id': 'e1e7d7bc'
      });
      var adminSgl = p.sgl({
          'grant': ['key_admin', 'se_admin', 'rule_admin'],
          'when': {
            'any': [{'roles': 'offline'}, {'roles': 'biometric'}],
            'n': 2
          },
          'id': '8586d26c'
      });
      var edgebioSgl = p.sgl({
          'grant': [],
          'when': {
            'all':[{'roles': 'edge'}, {'roles': 'biometric'}]
          }
      });

      var registerIterator = registerSgl.qualifyingPrincipals.iterator;
      print(registerIterator.count);
      while(registerIterator.moveNext()) {
        print(registerIterator.current.map);
      }

      var authcryptIterator = authcryptSgl.qualifyingPrincipals.iterator;
      print(authcryptIterator.count);
      while(authcryptIterator.moveNext()) {
        print(authcryptIterator.current.map);
      }

      var edgeIterator = edgeSgl.qualifyingPrincipals.iterator;
      print(edgeIterator.count);
      while(edgeIterator.moveNext()) {
        print(edgeIterator.current.map);
      }

      var adminIterator = adminSgl.qualifyingPrincipals.iterator;
      print(adminIterator.count);
      while(adminIterator.moveNext()) {
        print(adminIterator.current.map);
      }

      var edgebioIterator = edgebioSgl.qualifyingPrincipals.iterator;
      print(edgebioIterator.count);
      while(edgebioIterator.moveNext()) {
        print(edgebioIterator.current.map);
      }


      //var string = 'foo,bar,baz';
      //expect(string.split(','), equals(['foo', 'bar', 'baz']));
  });

  test('??????', () {
      Principals(<Principal>[
          Principal({'key': '#Mv6gmMNa', 'roles': ['edge']}),
          Principal({'key': '#izfrNTmQ', 'roles': ['edge', 'biometric']}),
          Principal({'key': '#02b97c30', 'roles': ['cloud']}),
          Principal({'key': '#H3C2AVvL', 'roles': ['offline']})
      ]).transformKeyTo('key', 'id').sgl({
          'grant': ['register'],
          'when': {'id': '#Mv6gmMNa'},
          'id': '7ac4c6be'
      });
  }); */
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
