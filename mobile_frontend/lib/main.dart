import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      home: const AuthHome(),
    );
  }
}

class AuthHome extends StatefulWidget {
  const AuthHome({super.key});
  @override
  State<AuthHome> createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _output = '';

  Future<void> _tryRegister() async {
    final res = await ApiService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
    setState(() {
      _output = res.toString();
    });
  }

  Future<void> _tryLogin() async {
    final res = await ApiService.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      device: 'flutter-device',
    );
    setState(() {
      _output = res.toString();
    });
  }

  Future<void> _tryMe() async {
    final res = await ApiService.me();
    setState(() {
      _output = res.toString();
    });
  }

  Future<void> _tryLogout() async {
    final res = await ApiService.logout();
    setState(() {
      _output = res.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name (register)')),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: _tryRegister, child: const Text('Register')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _tryLogin, child: const Text('Login')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: _tryMe, child: const Text('Me')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _tryLogout, child: const Text('Logout')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_output))),
          ],
        ),
      ),
    );
  }
}
