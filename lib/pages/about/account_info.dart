import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/auth_service.dart';
import 'package:table_entry/pages/about/account_management_page.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSignIn() async {
    final success = await _auth.signInWithGoogle();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("loginFailed")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAuthenticated) {
      return _buildSignInButton();
    }
    return _buildAccountDetails();
  }

  Widget _buildSignInButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate("accountAndData"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 21),
        ),
        const SizedBox(height: 12),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: _auth.isLoading ? null : _handleSignIn,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: HexColor("#8332AC"),
                borderRadius: BorderRadius.circular(16)),
            child: _auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        translate("signInWithGoogle"),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            translate("email") + " :",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 21),
          ),
          Flexible(
            child: Text(
              _auth.email ?? "",
              style: TextStyle(
                  color: Colors.grey[100],
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate("remaining") + " :",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 21),
            ),
            Text(
              "600",
              style: TextStyle(
                  color: Colors.grey[100],
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Text(""),
        Row(
          children: [
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: _handleSignOut,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: HexColor("#8332AC"),
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    translate("logOut"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                )),
            const SizedBox(width: 12),
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AccountManagementPage()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3))),
                  child: Text(
                    translate("accountAndData"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                )),
          ],
        )
      ],
    );
  }
}
