import 'dart:async';
import 'package:flutter/material.dart';
import 'package:igs_absensi/model/class_model.dart';
import 'package:igs_absensi/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ClassModel> _classes = [];
  String? _nextCursor;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  Timer? _debounce; // ← tunda request saat user mengetik

  @override
  void initState() {
    super.initState();
    _fetchData(); // load semua kelas saat pertama buka
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Dipanggil tiap kali teks berubah — debounce 500ms
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchData(query: value.trim());
    });
  }

  // Fetch dari awal (query baru / reset)
  Future<void> _fetchData({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _classes = [];
      _nextCursor = null;
    });

    try {
      final result = await _apiService.searchCourses(
        query ?? _searchController.text.trim(),
      );
      setState(() {
        _classes = result.classes;
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
      });
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK: $stackTrace');
      setState(() => _errorMessage = 'Gagal memuat data. Coba lagi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Load halaman berikutnya (infinite scroll / tombol)
  Future<void> _loadMore() async {
    if (!_hasMore || _nextCursor == null || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _apiService.searchCourses(
        _searchController.text.trim(),
        cursor: _nextCursor,
      );
      setState(() {
        _classes.addAll(result.classes);
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat lebih banyak data.')),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Kelas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              SearchBar(
                controller: _searchController,
                hintText: 'Cari kelas...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _fetchData();
                      },
                    ),
                ],
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),

              // Konten utama
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Loading awal
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // Kosong
    if (_classes.isEmpty) {
      return const Center(child: Text('Kelas tidak ditemukan.'));
    }

    // List kelas
    return ListView.separated(
      itemCount: _classes.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _classes.length) {
          return Center(
            child: _isLoadingMore
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _loadMore,
                    child: const Text('Muat lebih banyak'),
                  ),
          );
        }

        return _ClassCard(classModel: _classes[index]);
      },
    );
  }
}

// Widget kartu per kelas
class _ClassCard extends StatelessWidget {
  final ClassModel classModel;
  const _ClassCard({required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nama kelas + room pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    classModel.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (classModel.room != null) ...[
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
                      classModel.room!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0C447C),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 0.5),
            ),

            // Dosen
            _InfoRow(
              icon: Icons.person_outline,
              value: classModel.lecturerName ?? '-',
            ),
            const SizedBox(height: 6),

            // Jam
            _InfoRow(
              icon: Icons.access_time_outlined,
              value:
                  (classModel.startTime != null && classModel.endTime != null)
                  ? '${classModel.startTime} – ${classModel.endTime}'
                  : '-',
            ),
            const SizedBox(height: 10),

            // Badge prodi & semester
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (classModel.studyProgram != null)
                  _Badge(
                    label: classModel.studyProgram!,
                    bgColor: const Color(0xFFE1F5EE),
                    textColor: const Color(0xFF085041),
                  ),
                if (classModel.semester != null)
                  _Badge(
                    label: classModel.semester!,
                    bgColor: const Color(0xFFFAEEDA),
                    textColor: const Color(0xFF633806),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Baris icon + teks
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
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Badge pill
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
