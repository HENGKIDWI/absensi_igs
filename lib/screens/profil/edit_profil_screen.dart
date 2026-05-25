import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  String? _gender;
  DateTime? _dateOfBirth;
  bool _isLoading = false;
  bool _showPasswordSection = false;
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _currentPasswordController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _gender = user?.student?.gender;
    _dateOfBirth = user?.student?.dateOfBirth != null
        ? DateTime.tryParse(user!.student!.dateOfBirth!)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final message = await context.read<AuthProvider>().updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth?.toIso8601String().split('T').first,
        currentPassword: _showPasswordSection
            ? _currentPasswordController.text
            : null,
        password: _showPasswordSection && _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        passwordConfirmation:
            _showPasswordSection && _confirmPasswordController.text.isNotEmpty
            ? _confirmPasswordController.text
            : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF4CAF82),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0C447C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Informasi Dasar ──
                _SectionLabel(label: 'Informasi Dasar'),
                const SizedBox(height: 10),
                _FormCard(
                  children: [
                    _InputField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email wajib diisi';
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _addressController,
                      label: 'Alamat',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Data Mahasiswa ──
                _SectionLabel(label: 'Data Mahasiswa'),
                const SizedBox(height: 10),
                _FormCard(
                  children: [
                    // Gender dropdown
                    _DropdownField(
                      label: 'Jenis Kelamin',
                      icon: Icons.wc_outlined,
                      value: _gender,
                      items: const [
                        DropdownMenuItem(
                          value: 'male',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 16),
                    // Tanggal lahir
                    GestureDetector(
                      onTap: _pickDate,
                      child: _ReadOnlyField(
                        label: 'Tanggal Lahir',
                        icon: Icons.cake_outlined,
                        value: _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : 'Pilih tanggal',
                        isPlaceholder: _dateOfBirth == null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Ubah Password ──
                _SectionLabel(label: 'Keamanan'),
                const SizedBox(height: 10),
                _FormCard(
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                        () => _showPasswordSection = !_showPasswordSection,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F1FB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 17,
                              color: Color(0xFF0C447C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Ubah Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            _showPasswordSection
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (_showPasswordSection) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _currentPasswordController,
                        label: 'Password Saat Ini',
                        obscure: _obscureCurrentPassword,
                        onToggle: () => setState(
                          () => _obscureCurrentPassword =
                              !_obscureCurrentPassword,
                        ),
                        validator: (v) {
                          if (_showPasswordSection &&
                              (v == null || v.isEmpty)) {
                            return 'Password saat ini wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _passwordController,
                        label: 'Password Baru',
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (v) {
                          if (_showPasswordSection &&
                              v != null &&
                              v.isNotEmpty &&
                              v.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Password Baru',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (_showPasswordSection &&
                              v != _passwordController.text) {
                            return 'Password tidak sama';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 28),

                // ── Tombol Simpan ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C447C),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF0C447C,
                      ).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0C447C)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: Colors.grey.shade500,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
            color: Colors.grey.shade500,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0C447C)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0C447C)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isPlaceholder;

  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isPlaceholder
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
