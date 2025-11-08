// dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthService _authService = AuthService();
  bool? _valid;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final ok = await _authService.checkToken();
    if (!mounted) return;
    setState(() => _valid = ok);
    if (!ok) {
      // Redirige al login si token inválido
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_valid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}