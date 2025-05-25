import 'dart:convert';
import 'package:bbtproje/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart'; // EN ÜSTE EKLE

part '../states/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  void setEmail(String email) {
    emit(AuthEmailIn(email: email));
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(
            scopes: ['https://www.googleapis.com/auth/calendar'],
          ).signIn();

      if (googleUser == null) {
        emit(AuthFailure('Google hesabı seçilmedi'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        final token = googleAuth.accessToken;

        if (doc.exists) {
          // 🔁 Zaten kayıtlı, veritabanından al
          final data = doc.data()!;
          emit(
            AuthLoggedIn(
              uid: user.uid,
              email: data['email'] ?? '',
              name: data['name'] ?? '',
              role: data['role'] ?? '',
              accessToken: token,
            ),
          );
        } else {
          // ✍️ Yeni kullanıcı, hala ismini soracağız
          emit(
            AuthLoggedIn(
              uid: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? '',
              role: '',
              accessToken: token,
            ),
          );
        }
      } else {
        emit(AuthFailure('Kullanıcı bulunamadı'));
      }
    } catch (e) {
      emit(AuthFailure('Google ile giriş sırasında hata oluştu: $e'));
    }
  }

  Future<void> loginOrRegisterWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(
        AuthLoggedIn(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          name: credential.user!.displayName ?? "",
          role: "",
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Kayıt ol

      if (e.code == 'wrong-password') {
        emit(AuthFailure("Şifre yanlış."));
      } else {
        print(email);
        print(password);
        final newUser = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        emit(
          AuthLoggedIn(
            uid: newUser.user!.uid,
            email: newUser.user!.email!,
            name: newUser.user!.displayName ?? "",
            role: "",
          ),
        );
      }
    } catch (e) {
      emit(AuthFailure("Beklenmedik hata: $e"));
    }
  }

  void setRoleAndName(String role, String name) async {
    if (state is AuthLoggedIn) {
      final current = getIt<AuthCubit>().state as AuthLoggedIn;

      final newState = AuthLoggedIn(
        email: current.email,
        name: name,
        uid: current.uid,
        role: role,
        accessToken: current.accessToken,
      );

      emit(newState);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .set({
              'uid': current.uid,
              'name': name,
              'email': current.email,
              'role': role,
              'accessToken': current.accessToken,
            });
        print("✅ Firestore'a kullanıcı eklendi");
      } catch (e) {
        print("❌ Firestore ekleme hatası: $e");
      }
    }
  }
}
