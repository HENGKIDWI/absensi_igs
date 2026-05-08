import 'package:flutter/material.dart';
import 'package:igs_absensi/model/class.dart';
import 'package:igs_absensi/screens/my_class/my_class_detail_screen.dart';
import 'package:igs_absensi/services/api_service.dart';

class MyClassScreen extends StatefulWidget {
  const MyClassScreen({super.key});

  @override
  State<MyClassScreen> createState() => MyClassScreenState();
}

class MyClassScreenState extends State<MyClassScreen> {
  final ApiService _apiService = ApiService();

  List<ClassModel> _courses = [];
  List<ClassModel> _filtered = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  // ✅ Sesudah
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // tidak fetch di sini
    _searchController.addListener(_onSearchChanged);
  }

  /// Dipanggil pertama kali saat tab dibuka
  void loadData() {
    if (_hasLoaded) return;
    print('LOADDATA CALLED');
    _fetchEnrolledClasses();
  }

  /// Dipanggil setelah enroll berhasil
  void refreshData() {
    _hasLoaded = false;
    _fetchEnrolledClasses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _courses
          : _courses
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(q) ||
                      (c.lecturerName?.toLowerCase().contains(q) ?? false) ||
                      (c.room?.toLowerCase().contains(q) ?? false),
                )
                .toList();
    });
  }

  Future<void> _fetchEnrolledClasses() async {
    setState(() {
      _isLoading = true; // ✅ hapus _hasLoaded = true dari sini
      _error = null;
    });

    try {
      final result = await _apiService.getEnrolledClasses();
      if (!mounted) return;
      setState(() {
        _courses = result;
        _filtered = result;
        _isLoading = false;
        _hasLoaded = true; // ✅ pindah ke sini, hanya set true kalau berhasil
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat kelas. Coba lagi.';
        _isLoading = false;
        _hasLoaded =
            false; // ✅ kalau gagal, biarkan bisa retry lewat loadData()
      });
    }
  }

  void _openDetail(ClassModel classModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyClassDetailScreen(classModel: classModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      appBar: AppBar(
        title: const Text(
          'Kelas Saya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 4),
              // ── Search bar ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari kelas, dosen, ruangan...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasLoaded && !_isLoading) {
      return const SizedBox.shrink();
    }
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0C447C)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEnrolledClasses,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C447C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada kelas yang diikuti',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          'Kelas tidak ditemukan',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEnrolledClasses,
      color: const Color(0xFF0C447C),
      child: ListView.separated(
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        padding: const EdgeInsets.only(bottom: 24),
        itemBuilder: (_, i) => _ClassCard(
          classModel: _filtered[i],
          onTap: () => _openDetail(_filtered[i]),
        ),
      ),
    );
  }
}

// ── Kartu Kelas ───────────────────────────────────────────
class _ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const _ClassCard({required this.classModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = classModel;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama + ruangan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      c.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (c.room != null && c.room!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.room!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0C447C),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey.shade200,
                ),
              ),

              // Dosen
              _InfoRow(
                icon: Icons.person_outline,
                value: c.lecturerName ?? '-',
              ),
              const SizedBox(height: 6),

              // Waktu
              _InfoRow(
                icon: Icons.access_time_outlined,
                value: (c.startTime != null && c.endTime != null)
                    ? '${c.startTime} – ${c.endTime}'
                    : '-',
              ),
              const SizedBox(height: 10),

              // Badge prodi & semester
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (c.studyProgram != null)
                    _Badge(
                      label: c.studyProgram!,
                      bgColor: const Color(0xFFE1F5EE),
                      textColor: const Color(0xFF085041),
                    ),
                  if (c.semester != null)
                    _Badge(
                      label: c.semester!,
                      bgColor: const Color(0xFFFAEEDA),
                      textColor: const Color(0xFF633806),
                    ),
                ],
              ),

              // Chevron hint
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat riwayat absensi',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor)),
    );
  }
}
