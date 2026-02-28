import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plushie_yourself/core/services/media_service.dart';
import 'package:plushie_yourself/features/plushie/bloc/plushie_bloc.dart';
import 'package:plushie_yourself/modules/theme/app_colors.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final Uint8List? resultBytes;
  final String? resultUrl;

  const ResultScreen({
    super.key,
    this.imageBytes,
    this.resultBytes,
    this.resultUrl,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _sharing = false;
  bool _saving = false;
  bool _showingOriginal = false;

  Future<void> _saveImage() async {
    final bytes = widget.resultBytes;
    if (bytes == null) return;
    setState(() => _saving = true);
    final error = await MediaService.saveToGallery(bytes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Saved to gallery!')),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _shareImage() async {
    final bytes = widget.resultBytes;
    if (bytes == null) return;
    setState(() => _sharing = true);
    final error = await MediaService.shareImage(
      bytes,
      text: '🧸 Check out my plushie! Made with Plushie Yourself',
    );
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      appBar: AppBar(
        backgroundColor: AppColors.warmBeige,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.read<PlushieBloc>().add(const ResetPlushieEvent());
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warmCream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.subtleGray),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.warmBrown, size: 20),
          ),
        ),
        title: Text(
          _showingOriginal ? 'Original Photo' : 'Your Plushie',
          style: const TextStyle(
            color: AppColors.warmBrown,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(child: _buildMainImage()),
              const SizedBox(height: 12),
              _buildHint(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildShareButton()),
                  const SizedBox(width: 12),
                  _buildSaveButton(),
                  const SizedBox(width: 12),
                  _buildWhatsAppButton(),
                ],
              ),
              const SizedBox(height: 16),
              _buildTryAgainButton(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    final Widget imageWidget;

    if (_showingOriginal) {
      imageWidget = widget.imageBytes != null
          ? Image.memory(widget.imageBytes!, fit: BoxFit.cover)
          : _buildPlaceholder('No original image');
    } else {
      if (widget.resultBytes != null) {
        imageWidget = Image.memory(widget.resultBytes!, fit: BoxFit.cover);
      } else if (widget.resultUrl != null) {
        imageWidget = Image.network(
          widget.resultUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.warmAmber,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, __, ___) =>
              _buildPlaceholder('Could not load image'),
        );
      } else {
        imageWidget = _buildPlaceholder('Plushie generation failed');
      }
    }

    return GestureDetector(
      onLongPressStart: (_) => setState(() => _showingOriginal = true),
      onLongPressEnd: (_) => setState(() => _showingOriginal = false),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(_showingOriginal),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.subtleGray, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmBrown.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_rounded, size: 14, color: AppColors.warmBrownLight),
        const SizedBox(width: 6),
        Text(
          'Hold to see original',
          style: TextStyle(fontSize: 12, color: AppColors.warmBrownLight),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded,
                size: 40, color: AppColors.warmBrownLight),
            const SizedBox(height: 8),
            Text(message,
                style:
                    TextStyle(color: AppColors.warmBrownLight, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: _sharing ? null : _shareImage,
      icon: _sharing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.share_rounded, size: 18),
      label: const Text('Share'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warmBrown,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saving ? null : _saveImage,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.warmAmber,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.warmAmber.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _saving
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              )
            : const Icon(Icons.download_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return GestureDetector(
      onTap: _sharing ? null : _shareImage,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('WA',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildTryAgainButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<PlushieBloc>().add(const ResetPlushieEvent());
          Navigator.pop(context);
        },
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text('Create another'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warmBrown,
          side: const BorderSide(color: AppColors.subtleGray, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
