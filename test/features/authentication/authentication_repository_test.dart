import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plushie_yourself/features/authentication/authentication_repository.dart';
import 'package:plushie_yourself/features/authentication/cache.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockCacheClient extends Mock implements CacheClient {}

void main() {
  group('FirebaseAuthenticationRepository', () {
    late firebase_auth.FirebaseAuth firebaseAuth;
    late CacheClient cacheClient;
    late FirebaseAuthenticationRepository authenticationRepository;

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      cacheClient = MockCacheClient();

      authenticationRepository = FirebaseAuthenticationRepository(
        firebaseAuth: firebaseAuth,
        cache: cacheClient,
      );
    });

    group('signUpWithEmailAndPassword', () {
      const email = 'test@example.com';
      const password = 'password123';

      test(
        'throws SignUpWithEmailAndPasswordFailure when an unknown exception occurs',
        () async {
          when(
            () => firebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(Exception('oops'));

          expect(
            () => authenticationRepository.signUpWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<SignUpWithEmailAndPasswordFailure>()),
          );
        },
      );
    });
  });
}
