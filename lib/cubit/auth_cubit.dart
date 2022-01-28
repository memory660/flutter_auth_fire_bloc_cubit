import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthDefault());
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Login
  Future<User?> login(String email, String password) async {
    emit(const AuthLoginLoading());
    User? user;
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      //user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(AuthLoginSuccess(user: user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthLoginError(error: e.message!));
    }
    return user;
  }

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    User? user;
    emit(const AuthSignUpLoading());
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(const AuthSignUpSuccess());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
      emit(AuthSignUpError(e.message!));
    }
    return user;
  }

  // Forgot Password
  Future forgotPassword(String email) async {
    emit(const AuthForgotPasswordLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      emit(const AuthForgotPasswordSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthForgotPasswordError(e.message!));
    }
  }

  // Logout
  Future logout() async {
    await _firebaseAuth.signOut();
    emit(const AuthLogout());
  }
}
