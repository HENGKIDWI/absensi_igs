import 'dart:async';
import 'package:flutter/material.dart';
import 'package:igs_absensi/model/class.dart';
import 'package:igs_absensi/model/sks_quota_model.dart';
import 'package:igs_absensi/screens/class_list/class_list_detail_screen.dart';
import 'package:igs_absensi/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onEnrollSuccess;
  const SearchScreen({super.key, this.onEnrollSuccess});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  SksQuota? _quota;
  bool _isLoadingQuota = false;

  List<ClassModel> _courses = [];
  String? _nextCursor;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _fetchData();
    _fetchQuota();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchData(query: value.trim());
    });
  }

  Future<void> _fetchData({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _courses = [];
      _nextCursor = null;
    });

    try {
      final result = await _apiService.searchCourses(
        query ?? _searchController.text.trim(),
      );
      setState(() {
        _courses = result.courses;
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      setState(() => _errorMessage = 'Gagal memuat data. Coba lagi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchQuota() async {
    try {
      setState(() {
        _isLoadingQuota = true;
      });

      final result = await _apiService.getSksQuota();

      setState(() {
        _quota = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoadingQuota = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _nextCursor == null || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _apiService.searchCourses(
        _searchController.text.trim(),
        cursor: _nextCursor,
      );
      setState(() {
        _courses.addAll(result.courses);
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat lebih banyak data.')),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _openDetail(ClassModel classModel) async {
    final enrolled = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClassDetailScreen(classModel: classModel),
      ),
    );

    if (enrolled == true) {
      widget.onEnrollSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text(
          'Daftar Kelas',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_quota != null) ...[
                _SksBanner(quota: _quota!),
                const SizedBox(height: 16),
              ],

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
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (_courses.isEmpty) {
      return const Center(child: Text('Kelas tidak ditemukan.'));
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _courses.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _courses.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _ClassCard(
          classModel: _courses[index],
          onTap: () => _openDetail(_courses[index]),
        );
      },
    );
  }
}

// ── Widget kartu per kelas ────────────────────────────────
class _ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const _ClassCard({required this.classModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge, // agar InkWell mengikuti border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${classModel.sks} SKS',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
            style: const TextStyle(fontSize: 12),
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

class _QuotaItem extends StatelessWidget {
  final String title;
  final String value;

  const _QuotaItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _SksBanner extends StatelessWidget {
  final SksQuota quota;

  const _SksBanner({required this.quota});

  @override
  Widget build(BuildContext context) {
    final progress = quota.maxSks == 0 ? 0.0 : quota.currentSks / quota.maxSks;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kuota Pengambilan SKS',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 4),

          Text(
            'IPS ${quota.ips}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BannerItem(label: 'Maks', value: quota.maxSks.toString()),

              _BannerItem(label: 'Diambil', value: quota.currentSks.toString()),

              _BannerItem(label: 'Sisa', value: quota.remainingSks.toString()),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String label;
  final String value;

  const _BannerItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
