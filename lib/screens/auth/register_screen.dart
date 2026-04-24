// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:igs_absensi/config/api.dart';
import 'package:igs_absensi/model/faculty.dart';
import 'package:igs_absensi/model/study_program.dart';
import 'package:igs_absensi/screens/auth/verify_email_screen.dart';
import 'package:igs_absensi/services/api_service.dart';
import 'package:igs_absensi/widgets/password_field.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/screens/auth/login_screen.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/widgets/auth_text_button.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _facultyService = ApiService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Dropdown state
  List<FacultyModel> _faculties = [];
  List<StudyProgramModel> _studyPrograms = [];
  FacultyModel? _selectedFaculty;
  StudyProgramModel? _selectedStudyProgram;

  bool _loadingFaculties = false;
  bool _loadingStudyPrograms = false;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadFaculties() async {
    setState(() => _loadingFaculties = true);
    try {
      final result = await _facultyService.getFaculties();
      setState(() => _faculties = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat fakultas: $e')));
    } finally {
      setState(() => _loadingFaculties = false);
    }
  }

  Future<void> _onFacultyChanged(FacultyModel? faculty) async {
    setState(() {
      _selectedFaculty = faculty;
      _selectedStudyProgram = null; // reset program studi
      _studyPrograms = [];
    });

    if (faculty == null) return;

    setState(() => _loadingStudyPrograms = true);
    try {
      final result = await _facultyService.getStudyPrograms(faculty.id);
      setState(() => _studyPrograms = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat program studi: $e')));
    } finally {
      setState(() => _loadingStudyPrograms = false);
    }
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih fakultas terlebih dahulu')),
      );
      return;
    }
    if (_selectedStudyProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih program studi terlebih dahulu')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak sama')));
      return;
    }

    try {
      await auth.register(
        name: nameController.text,
        email: emailController.text,
        facultyId: _selectedFaculty!.id,
        studyProgramId: _selectedStudyProgram!.id,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerifyPage(email: emailController.text),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 320,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: 200, height: 100),
                const SizedBox(height: 40),
                const Text('ABSENSI DIGITAL'),
                const SizedBox(height: 45),

                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 16),

                // ── Dropdown Fakultas ──
                _buildFacultyDropdown(),
                const SizedBox(height: 16),

                // ── Dropdown Program Studi ──
                _buildStudyProgramDropdown(),
                const SizedBox(height: 16),

                PasswordField(
                  label: 'Password',
                  controller: passwordController,
                ),
                const SizedBox(height: 16),

                PasswordField(
                  label: 'Konfirmasi Password',
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return auth.isLoading
                        ? const CircularProgressIndicator()
                        : PrimaryButton(
                            text: 'Daftar',
                            onPressed: () => _handleRegister(auth),
                          );
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah memiliki akun?'),
                    AuthTextButton(
                      text: 'Login',
                      warnaText: Colors.blueAccent,
                      alignment: Alignment.center,
                      onPressed: _handleToLogin,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyDropdown() {
    return DropdownButtonFormField<FacultyModel>(
      value: _selectedFaculty,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Fakultas',
        prefixIcon: _loadingFaculties
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      hint: Text(
        _loadingFaculties ? 'Memuat...' : 'Pilih Fakultas',
        style: const TextStyle(fontSize: 14),
      ),
      items: _faculties
          .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
          .toList(),
      onChanged: _loadingFaculties ? null : _onFacultyChanged,
    );
  }

  Widget _buildStudyProgramDropdown() {
    final isDisabled = _selectedFaculty == null;

    return DropdownButtonFormField<StudyProgramModel>(
      value: _selectedStudyProgram,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Program Studi',
        prefixIcon: _loadingStudyPrograms
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Icon(
                Icons.menu_book,
                color: isDisabled ? Colors.grey.shade400 : null,
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        // Warna disabled saat belum pilih fakultas
        fillColor: isDisabled ? Colors.grey.shade100 : null,
        filled: isDisabled,
      ),
      hint: Text(
        isDisabled
            ? 'Pilih fakultas dulu'
            : _loadingStudyPrograms
            ? 'Memuat...'
            : 'Pilih Program Studi',
        style: TextStyle(
          fontSize: 14,
          color: isDisabled ? Colors.grey.shade400 : null,
        ),
      ),
      items: _studyPrograms
          .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
          .toList(),
      // null = disabled
      onChanged: (isDisabled || _loadingStudyPrograms)
          ? null
          : (val) {
              setState(() => _selectedStudyProgram = val);
            },
    );
  }
}
