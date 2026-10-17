import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/firebase_social_sign_in.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';

/// 가짜 Firebase 회원: 재인증·삭제 호출 기록
class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;
  int reauthenticateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    reauthenticateCalls++;
    return _FakeUserCredential(this, isNewUser: false);
  }

  @override
  Future<void> delete() async => deleteCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  _FakeUserCredential(this.user, {required bool isNewUser})
    : additionalUserInfo = AdditionalUserInfo(isNewUser: isNewUser);

  @override
  final User? user;
  @override
  final AdditionalUserInfo? additionalUserInfo;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 가짜 Firebase 인증: 현재 세션, 새 로그인 결과(재인증한 계정), 로그아웃 기록
class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth({
    this.currentUser,
    required this.signInResultUser,
    this.isNewUser = false,
  });

  @override
  User? currentUser;
  final _FakeUser signInResultUser;
  final bool isNewUser;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    signInCalls++;
    currentUser = signInResultUser;
    return _FakeUserCredential(signInResultUser, isNewUser: isNewUser);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    currentUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 탈퇴 재인증 자격 (내용은 대조에 쓰이지 않음)
final _credential = GoogleAuthProvider.credential(idToken: 'reauth-id-token');

const _mismatchMessage = '가입한 계정으로 다시 인증해 주세요.';

Matcher get _throwsAccountMismatch => throwsA(
  isA<SocialSignInException>().having(
    (exception) => exception.message,
    'message',
    _mismatchMessage,
  ),
);

/// 탈퇴 재인증 계정 대조: 재인증 결과 Firebase uid <-> 서버 providerUserId (#516)
void main() {
  test('가입 계정의 Firebase 세션이면 재인증만 하고 새 로그인은 하지 않는다', () async {
    final signedUpUser = _FakeUser('uid-signed-up');
    final auth = _FakeFirebaseAuth(
      currentUser: signedUpUser,
      signInResultUser: _FakeUser('unused'),
    );

    await FirebaseSocialSignIn(
      auth: auth,
    ).confirmSignedUpAccount(_credential, 'uid-signed-up');

    expect(signedUpUser.reauthenticateCalls, 1);
    expect(auth.signInCalls, 0);
  });

  test('Firebase 세션이 없으면 새 로그인 후 uid 가 같을 때만 통과한다', () async {
    final auth = _FakeFirebaseAuth(
      signInResultUser: _FakeUser('uid-signed-up'),
    );

    await FirebaseSocialSignIn(
      auth: auth,
    ).confirmSignedUpAccount(_credential, 'uid-signed-up');

    expect(auth.signInCalls, 1);
  });

  test('다른 계정으로 재인증하면 새로 생긴 Firebase 회원을 지우고 안내를 던진다', () async {
    final otherUser = _FakeUser('uid-other');
    final auth = _FakeFirebaseAuth(
      signInResultUser: otherUser,
      isNewUser: true,
    );

    await expectLater(
      FirebaseSocialSignIn(
        auth: auth,
      ).confirmSignedUpAccount(_credential, 'uid-signed-up'),
      _throwsAccountMismatch,
    );
    expect(otherUser.deleteCalls, 1);
    expect(auth.signOutCalls, 1);
  });

  test('기존 Firebase 회원인 다른 계정은 지우지 않고 로그아웃만 한다', () async {
    final otherUser = _FakeUser('uid-other');
    final auth = _FakeFirebaseAuth(signInResultUser: otherUser);

    await expectLater(
      FirebaseSocialSignIn(
        auth: auth,
      ).confirmSignedUpAccount(_credential, 'uid-signed-up'),
      _throwsAccountMismatch,
    );
    expect(otherUser.deleteCalls, 0);
    expect(auth.signOutCalls, 1);
  });

  test('기기 Firebase 세션이 다른 계정이면 정리 후 새 로그인으로 대조한다', () async {
    final auth = _FakeFirebaseAuth(
      currentUser: _FakeUser('uid-other'),
      signInResultUser: _FakeUser('uid-signed-up'),
    );

    await FirebaseSocialSignIn(
      auth: auth,
    ).confirmSignedUpAccount(_credential, 'uid-signed-up');

    expect(auth.signOutCalls, 1);
    expect(auth.signInCalls, 1);
  });

  test('서버 providerUserId 를 모르면 대조할 수 없어 탈퇴를 중단한다', () async {
    final auth = _FakeFirebaseAuth(
      signInResultUser: _FakeUser('uid-signed-up'),
    );

    await expectLater(
      FirebaseSocialSignIn(
        auth: auth,
      ).confirmSignedUpAccount(_credential, null),
      _throwsAccountMismatch,
    );
    expect(auth.signInCalls, 0);
  });

  test('Google 은 Firebase 세션이 가입 계정이면 재인증 화면 없이 통과한다', () async {
    final auth = _FakeFirebaseAuth(
      currentUser: _FakeUser('uid-signed-up'),
      signInResultUser: _FakeUser('unused'),
    );

    expect(
      await FirebaseSocialSignIn(
        auth: auth,
      ).confirmGoogleAccount(expectedUid: 'uid-signed-up'),
      isTrue,
    );
    expect(auth.signInCalls, 0);
  });
}
