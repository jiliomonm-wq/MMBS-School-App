import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'localization.dart';
import 'theme_widgets.dart';
import 'main_screen.dart';

class SchoolApp extends StatefulWidget {
  const SchoolApp({super.key});

  @override
  State<SchoolApp> createState() => _SchoolAppState();
}

class _SchoolAppState extends State<SchoolApp> {
  String _lang = 'en';
  UserProfile? _currentUser;

  String t(String k) => loc[_lang]?[k] ?? k;

  void toggleLang() {
    setState(() => _lang = _lang == 'en' ? 'mm' : 'en');
  }

  void onLogin(UserProfile u) {
    setState(() => _currentUser = u);
  }

  void onLogout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg1,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Inter',
      ),
      home: _currentUser == null
          ? AuthScreen(
              lang: _lang,
              t: t,
              onToggleLang: toggleLang,
              onAuthSuccess: onLogin,
            )
          : MainScreen(
              user: _currentUser!,
              lang: _lang,
              t: t,
              onToggleLang: toggleLang,
              onLogout: onLogout,
            ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final String lang;
  final String Function(String) t;
  final VoidCallback onToggleLang;
  final Function(UserProfile) onAuthSuccess;

  const AuthScreen({
    super.key,
    required this.lang,
    required this.t,
    required this.onToggleLang,
    required this.onAuthSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  String _selectedRole = 'Student';

  String? _selectedGrade = 'Grade 1';
  String? _selectedTeacherGrade = 'Grade 1';
  String _userAvatarBase64 = '';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _pNameCtrl = TextEditingController();
  final _pPhoneCtrl = TextEditingController();
  final _skillCtrl = TextEditingController(text: 'Teaching, Planning');
  final _expCtrl = TextEditingController(text: '2 Years');

  final List<String> _grades = const [
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
    'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
  ];

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _userAvatarBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      _snack('Image selection error: $e');
    }
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _snack(widget.lang == 'mm' ? 'အချက်အလက်များ အကုန်ဖြည့်ပါ' : 'Please fill all fields');
      return;
    }

    // Owner Login သီးသန့်စနစ်
    if (_isLogin && email == 'admin@school.com') {
      if (pass == 'admin12345') {
        final admin = UserProfile(
          id: 'OWNER-MASTER-001',
          name: 'Principal (ကျောင်းအုပ်ကြီး)',
          role: 'Owner',
          email: 'admin@school.com',
          password: pass,
          className: 'Administration',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
        );
        _snack(widget.lang == 'mm' ? 'ကျောင်းအုပ်အဖြစ် ဝင်ရောက်ပြီး' : 'Welcome Principal!', isSuccess: true);
        widget.onAuthSuccess(admin);
        return;
      } else {
        _snack(widget.lang == 'mm' ? 'ကျောင်းအုပ် စကားဝှက် မှားယွင်းနေပါသည်' : 'Incorrect Principal Password');
        return;
      }
    }

    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      _snack(widget.lang == 'mm' ? 'နာမည် ထည့်ပေးပါ' : 'Please enter your name');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      if (_isLogin) {
        final query = await firestore.collection('users').where('email', isEqualTo: email).get();
        if (query.docs.isEmpty) {
          _snack(widget.lang == 'mm' ? 'အကောင့် မရှိသေးပါ (သို့မဟုတ်) အီးမေးလ် မှားယွင်းနေပါသည်' : 'Account not found');
          return;
        }

        final doc = query.docs.first;
        final data = doc.data();

        if (data['password'] != pass) {
          _snack(widget.lang == 'mm' ? 'စကားဝှက် မှားယွင်းနေပါသည်' : 'Incorrect password');
          return;
        }

        final user = UserProfile.fromFirestore(data, doc.id);
        _snack(widget.t('login_success'), isSuccess: true);
        widget.onAuthSuccess(user);
      } else {
        final existing = await firestore.collection('users').where('email', isEqualTo: email).get();
        if (existing.docs.isNotEmpty || email == 'admin@school.com') {
          _snack(widget.lang == 'mm' ? 'ဒီအီးမေးလ် အသုံးပြုပြီးသား ဖြစ်ပါသည်' : 'Email already in use');
          return;
        }

        final docRef = firestore.collection('users').doc();
        final user = UserProfile(
          name: _nameCtrl.text.trim(),
          id: docRef.id,
          role: _selectedRole,
          className: _selectedRole == 'Student' ? (_selectedGrade ?? 'Grade 1') : _subjectCtrl.text.trim(),
          email: email,
          password: pass,
          avatarUrl: _userAvatarBase64.isNotEmpty ? _userAvatarBase64 : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
          age: int.tryParse(_ageCtrl.text.trim()) ?? 16,
          location: _locCtrl.text.trim(),
          contact: _contactCtrl.text.trim(),
          parentName: _selectedRole == 'Student' ? _pNameCtrl.text.trim() : '',
          parentPhone: _selectedRole == 'Student' ? _pPhoneCtrl.text.trim() : '',
          gradesTaught: _selectedRole == 'Teacher' ? (_selectedTeacherGrade ?? 'Grade 1') : '',
          skills: _selectedRole == 'Teacher' ? _skillCtrl.text.trim() : 'Learning',
          experience: _selectedRole == 'Teacher' ? _expCtrl.text.trim() : 'Student',
          attendanceRate: 100,
        );

        await docRef.set(user.toMap());
        _snack(widget.t('register_success'), isSuccess: true);
        widget.onAuthSuccess(user);
      }
    } catch (e) {
      _snack('Database error: $e');
    }
  }

  void _snack(String m, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LightBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: widget.onToggleLang,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(widget.lang == 'en' ? 'မြန်မာ' : 'English', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: !_isLogin
                      ? GestureDetector(
                          onTap: _pickAvatar,
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            backgroundImage: _userAvatarBase64.isNotEmpty ? MemoryImage(base64Decode(_userAvatarBase64.split(',').last)) : null,
                            child: _userAvatarBase64.isEmpty
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: AppColors.primary, size: 24),
                                      SizedBox(height: 2),
                                      Text('ပုံတင်ရန်', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : null,
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.purple]),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.school, color: Colors.white, size: 34),
                        ),
                ),
                const SizedBox(height: 10),
                Text(widget.t('school_name'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isLogin) ...[
                        Text(widget.t('select_role'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Student', 'Teacher'].map((role) {
                            final selected = _selectedRole == role;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: role == 'Student' ? 6 : 0),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedRole = role),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: selected ? const LinearGradient(colors: [AppColors.primary, AppColors.purple]) : null,
                                      color: selected ? null : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(widget.t(role.toLowerCase()), style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        _buildInput(widget.t('name'), Icons.person_outline, _nameCtrl),
                        const SizedBox(height: 10),
                      ],
                      _buildInput(widget.t('email'), Icons.email_outlined, _emailCtrl, keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _buildInput(widget.t('password'), Icons.lock_outline, _passCtrl, obscure: true),
                      const SizedBox(height: 10),
                      if (!_isLogin) ...[
                        Row(
                          children: [
                            Expanded(child: _buildInput(widget.t('age'), Icons.cake_outlined, _ageCtrl, keyboard: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInput(widget.t('contact'), Icons.phone_outlined, _contactCtrl, keyboard: TextInputType.phone)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInput(widget.t('location'), Icons.location_on_outlined, _locCtrl),
                        const SizedBox(height: 10),
                      ],
                      if (!_isLogin && _selectedRole == 'Student') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedGrade,
                          decoration: InputDecoration(labelText: widget.t('select_grade'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _selectedGrade = v),
                        ),
                        const SizedBox(height: 10),
                        _buildInput(widget.t('parent_name'), Icons.person, _pNameCtrl),
                        const SizedBox(height: 8),
                        _buildInput(widget.t('parent_phone'), Icons.phone, _pPhoneCtrl, keyboard: TextInputType.phone),
                        const SizedBox(height: 10),
                      ],
                      if (!_isLogin && _selectedRole == 'Teacher') ...[
                        _buildInput(widget.t('subject'), Icons.book_outlined, _subjectCtrl),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedTeacherGrade,
                          decoration: InputDecoration(labelText: widget.t('select_grade'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _selectedTeacherGrade = v),
                        ),
                        const SizedBox(height: 10),
                        _buildInput('ကျွမ်းကျင်မှု (Skills)', Icons.star_border, _skillCtrl),
                        const SizedBox(height: 8),
                        _buildInput('လုပ်သက် (Experience)', Icons.timeline, _expCtrl),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submit,
                        child: Text(widget.t(_isLogin ? 'login' : 'register'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(widget.t(_isLogin ? 'no_account' : 'have_account'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.terminal, size: 14, color: AppColors.purple),
                        SizedBox(width: 6),
                        Text('Developer: Htet Wai Naing • 09692698685', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
