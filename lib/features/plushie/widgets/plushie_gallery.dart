import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/plushie_storage_service.dart';
import 'package:plushie_yourself/features/plushie/widgets/plushie_result_card.dart';
import 'package:plushie_yourself/features/theme/app_colors.dart';

class PlushieGallery extends StatefulWidget {
  const PlushieGallery({super.key});

  @override
  State<PlushieGallery> createState() => _PlushieGalleryState();
}

class _PlushieGalleryState extends State<PlushieGallery> {
  List<File> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final files = await PlushieStorageService.loadAll();
    if (mounted) {
      setState(() {
        _files = files;
        _loading = false;
      });
    }
  }

  Future<void> _delete(File file) async {
    await PlushieStorageService.delete(file.path);
    setState(() => _files.remove(file));
  }

  void _view(File file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder:
          (_) => PlushieResultCard(
            resultBytes: bytes,
            originalBytes: null,
            autoSave: false,
            onCreateAnother: () => Navigator.of(context).pop(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmBeige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.subtleGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                const Text(
                  'Your Plushies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warmBrown,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warmAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_files.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmAmber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _loading ? _buildLoading() : _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.warmAmber),
    );
  }

  Widget _buildGrid() {
    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧸', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'No plushies yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.warmBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first plushie!',
              style: TextStyle(fontSize: 14, color: AppColors.warmBrownLight),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return _PlushieThumbnail(
          file: file,
          onTap: () => _view(file),
          onDelete: () => _delete(file),
        );
      },
    );
  }
}

class _PlushieThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlushieThumbnail({
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showDeleteMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.warmAmber.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmBrown.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.5),
          child: Image.file(file, fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _showDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB85C4A),
                  ),
                  title: const Text(
                    'Delete plushie',
                    style: TextStyle(
                      color: Color(0xFFB85C4A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.close_rounded,
                    color: AppColors.warmBrownLight,
                  ),
                  title: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.warmBrownLight),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
