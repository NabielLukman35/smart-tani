import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';
import '../../../data/local_db/database_helper.dart';

class VarietasTanamanPage extends StatefulWidget {
  const VarietasTanamanPage({super.key});

  @override
  State<VarietasTanamanPage> createState() => _VarietasTanamanPageState();
}

class _VarietasTanamanPageState extends State<VarietasTanamanPage> {
  List<Map<String, dynamic>> _varieties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVarieties();
  }

  Future<void> _loadVarieties() async {
    final list = await DatabaseHelper.instance.getAllVarietas();
    if (mounted) {
      setState(() {
        _varieties = list;
        _isLoading = false;
      });
    }
  }

  void _showAddVarietasDialog() {
    final namaCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    final panduanCtrl = TextEditingController();
    final umurCtrl = TextEditingController(text: '65');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.darkForest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Varietas Baru (FR-03)',
                    style: TextStyle(
                      color: AppTheme.creamWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textGrey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Nama Varietas (mis. Melon Golden F1)', namaCtrl),
              const SizedBox(height: 10),
              _buildField('Deskripsi Bibit', deskripsiCtrl),
              const SizedBox(height: 10),
              _buildField('Panduan Perawatan (pH, Nutrisi, Hama)', panduanCtrl),
              const SizedBox(height: 10),
              _buildField('Estimasi Umur Panen (Hari)', umurCtrl, isNumber: true),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    if (namaCtrl.text.trim().isEmpty) return;
                    await DatabaseHelper.instance.insertVarietas({
                      'nama_varietas': namaCtrl.text.trim(),
                      'deskripsi': deskripsiCtrl.text.trim(),
                      'panduan_perawatan': panduanCtrl.text.trim(),
                      'estimasi_umur': int.tryParse(umurCtrl.text) ?? 60,
                      'foto_path': null,
                      'sync_status': 'Menunggu Unggah',
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _loadVarieties();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Varietas berhasil disimpan ke database SQLite!'),
                          backgroundColor: AppTheme.neonLime,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonLime,
                    foregroundColor: AppTheme.darkForest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Simpan ke Database Lokal', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController ctrl, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.35)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13),
        cursorColor: AppTheme.neonLime,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.ground,
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'Varietas Tanaman',
                subtitle: 'Katalog Bibit Unggul & Riset Melon (FR-03, FR-09)',
                trailing: GestureDetector(
                  onTap: _showAddVarietasDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.neonLime.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neonLime.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: AppTheme.neonLime, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Tambah',
                          style: TextStyle(
                            color: AppTheme.neonLime,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.neonLime))
                    : _varieties.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada varietas terdaftar.',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: _varieties.length,
                            itemBuilder: (ctx, idx) {
                              final item = _varieties[idx];
                              final nama = item['nama_varietas']?.toString() ?? 'Varietas Unggul';
                              final deskripsi = item['deskripsi']?.toString() ?? '-';
                              final panduan = item['panduan_perawatan']?.toString() ?? '-';
                              final umur = item['estimasi_umur']?.toString() ?? '60';

                              final color = idx % 3 == 0
                                  ? const Color(0xFFFFD54F) // Gold/Melon
                                  : idx % 3 == 1
                                      ? const Color(0xFF2ECC71) // Green
                                      : const Color(0xFFFF5252); // Red

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppTheme.panel,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                    width: 1.2,
                                  ),

                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(Icons.grain_rounded, color: color, size: 26),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nama,
                                                style: const TextStyle(
                                                  color: AppTheme.creamWhite,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Umur Panen: ± $umur Hari',
                                                style: const TextStyle(
                                                  color: AppTheme.textGrey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'SQLite',
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      deskripsi,
                                      style: TextStyle(
                                        color: AppTheme.pastelLime.withValues(alpha: 0.9),
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.inputFill,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.tips_and_updates_rounded, size: 14, color: AppTheme.neonLime),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              panduan,
                                              style: const TextStyle(
                                                color: AppTheme.creamWhite,
                                                fontSize: 11,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
