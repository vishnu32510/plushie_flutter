import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/media_service.dart';
import 'package:plushie_yourself/core/services/plushie_storage_service.dart';
import 'package:plushie_yourself/features/theme/app_colors.dart';

class PlushieResultCard extends StatefulWidget {
  final Uint8List? resultBytes;
  final Uint8List? originalBytes;
  final VoidCallback onCreateAnother;
  final bool autoSave;

  const PlushieResultCard({
    super.key,
    required this.resultBytes,
    required this.originalBytes,
    required this.onCreateAnother,
    this.autoSave = true,
  });

  @override
  State<PlushieResultCard> createState() => _PlushieResultCardState();
}

class _PlushieResultCardState extends State<PlushieResultCard> {
  bool _showingOriginal = false;
  bool _sharing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoSave && widget.resultBytes != null) {
      PlushieStorageService.save(widget.resultBytes!);
    }
  }

  Future<void> _save() async {
    final bytes = widget.resultBytes;
    if (bytes == null) return;
    setState(() => _saving = true);
    final error = await MediaService.saveToGallery(bytes);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Saved to gallery!')));
      setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    final bytes = widget.resultBytes;
    if (bytes == null) return;
    setState(() => _sharing = true);
    final error = await MediaService.shareImage(
      bytes,
      text: '🧸 Check out my plushie! Made with Plushie Yourself',
    );
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4A047),
            Color(0xFFFAF0DC),
            Color(0xFFD4A047),
            Color(0xFF5C3D1E),
            Color(0xFFD4A047),
          ],
          stops: [0.0, 0.3, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmAmber.withValues(alpha: 0.5),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCardHeader(),
            _buildImageSection(),
            _buildActions(),
            _buildCreateAnother(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Text(
            'PLUSHIE YOURSELF',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.warmBrown,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final Widget image;
    if (_showingOriginal) {
      image =
          widget.originalBytes != null
              ? Image.memory(widget.originalBytes!, fit: BoxFit.cover)
              : const Center(child: Text('No original'));
    } else {
      image =
          widget.resultBytes != null
              ? Image.memory(widget.resultBytes!, fit: BoxFit.cover)
              : const Center(child: Text('No image'));
    }

    final hasOriginal = widget.originalBytes != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onLongPressStart: hasOriginal ? (_) => setState(() => _showingOriginal = true) : null,
        onLongPressEnd: hasOriginal ? (_) => setState(() => _showingOriginal = false) : null,
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_showingOriginal),
                height: 460,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.warmAmber.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.5),
                  child: image,
                ),
              ),
            ),
            // Shine overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.06),
                        ],
                        stops: const [0.0, 0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showingOriginal)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Original',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _sharing ? null : _share,
              icon:
                  _sharing
                      ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CircleAction(
            color: AppColors.warmAmber,
            onTap: _saving ? null : _save,
            child:
                _saving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
          ),
          const SizedBox(width: 10),
          _CircleAction(
            color: const Color(0xFF25D366),
            onTap: _sharing ? null : _share,
            child: const Text(
              'WA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAnother() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        widget.onCreateAnother();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh_rounded,
            size: 16,
            color: AppColors.warmBrownLight,
          ),
          const SizedBox(width: 6),
          Text(
            'Create another',
            style: TextStyle(
              color: AppColors.warmBrownLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  final Widget child;

  const _CircleAction({
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.5) : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
