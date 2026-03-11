import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plushie_yourself/core/config/routes.dart';
import 'package:plushie_yourself/core/services/toast_service.dart';
import 'package:plushie_yourself/features/authentication/authentication.dart';
import 'package:plushie_yourself/features/plushie/bloc/plushie_bloc.dart';
import 'package:plushie_yourself/features/plushie/widgets/plushie_gallery.dart';
import 'package:plushie_yourself/features/plushie/widgets/plushie_result_card.dart';
import 'package:plushie_yourself/features/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  void _openGallery() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => const PlushieGallery(),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (xFile == null) return;
      File imageFile = File(xFile.path);
      if (source == ImageSource.camera) {
        imageFile = await _flipHorizontally(imageFile);
      }
      setState(() => _selectedImage = imageFile);
    } catch (e) {
      ToastService.showError('Could not pick image. Please try again.');
    }
  }

  Future<File> _flipHorizontally(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.translate(src.width.toDouble(), 0);
    canvas.scale(-1, 1);
    canvas.drawImage(src, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final flipped = await picture.toImage(src.width, src.height);
    final flippedBytes = await flipped.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final outPath = '${file.parent.path}/flipped_${file.uri.pathSegments.last}';
    final outFile = File(outPath);
    await outFile.writeAsBytes(Uint8List.view(flippedBytes!.buffer));
    return outFile;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose your photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warmBrown,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take a photo',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose from gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }

  bool get _isLoggedIn {
    final authState = context.read<AuthenticationBloc>().state;
    return authState.status == AuthenticationStatus.authenticated;
  }

  Future<void> _transform() async {
    if (_selectedImage == null) {
      _showImageSourceSheet();
      return;
    }
    if (!kDebugMode && !_isLoggedIn) {
      await Navigator.pushNamed(context, AppRoutes.login);
      if (!mounted || !_isLoggedIn) return;
    }
    if (mounted) {
      context.read<PlushieBloc>().add(TransformImageEvent(_selectedImage!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlushieBloc, PlushieState>(
      listener: (context, state) {
        if (state is PlushieSuccess) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.6),
            builder:
                (_) => PlushieResultCard(
                  resultBytes: state.resultBytes,
                  originalBytes: state.originalImageBytes,
                  onCreateAnother: () {
                    context.read<PlushieBloc>().add(const ResetPlushieEvent());
                    setState(() => _selectedImage = null);
                  },
                ),
          );
        } else if (state is PlushieError) {
          ToastService.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.warmBeige,
        body: SafeArea(
          child: BlocBuilder<PlushieBloc, PlushieState>(
            builder: (context, state) {
              return Stack(
                children: [
                  _buildBackground(),
                  _buildContent(state),
                  if (state is PlushieLoading) _buildLoadingOverlay(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(child: CustomPaint(painter: _PawPatternPainter()));
  }

  Widget _buildContent(PlushieState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          _buildHeader(),
          const Spacer(),
          _buildCenterContent(state),
          const Spacer(),
          _buildBottomBar(state),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plushie',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warmBrown,
                  height: 1.1,
                ),
              ),
              const Text(
                'Yourself',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warmAmber,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Turn yourself into an adorable handcrafted plush toy.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.warmBrownLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _openGallery,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warmCream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.subtleGray, width: 1.5),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: AppColors.warmBrown,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent(PlushieState state) {
    if (_selectedImage != null) {
      return _buildSelectedImagePreview();
    }
    return _buildStartCreatingButton(state);
  }

  Widget _buildSelectedImagePreview() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.warmAmber, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmAmber.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warmBrown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartCreatingButton(PlushieState state) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.subtleGray,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warmAmber.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 52,
                    color: AppColors.warmAmber,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upload photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmBrownLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'or take a selfie',
            style: TextStyle(fontSize: 13, color: AppColors.warmBrownLight),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.subtleGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: AppColors.warmBrown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(PlushieState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.subtleGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_selectedImage != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.subtleGray, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            )
          else
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleGray, width: 1.5),
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: AppColors.warmBrownLight,
                  size: 24,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _selectedImage == null ? _showImageSourceSheet : null,
              child: Text(
                _selectedImage != null
                    ? 'Create a plushie of me from my photo'
                    : 'Upload a photo to get started...',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      _selectedImage != null
                          ? AppColors.warmBrown
                          : AppColors.warmBrownLight,
                  fontWeight:
                      _selectedImage != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                ),
                maxLines: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _selectedImage != null ? _transform : _showImageSourceSheet,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    _selectedImage != null
                        ? AppColors.warmBrown
                        : AppColors.subtleGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color:
                    _selectedImage != null
                        ? Colors.white
                        : AppColors.warmBrownLight,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return const Positioned.fill(child: _PlushieLoadingOverlay());
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.warmCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleGray, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warmAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.warmAmber, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.warmBrown,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.warmBrownLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlushieLoadingOverlay extends StatefulWidget {
  const _PlushieLoadingOverlay();

  @override
  State<_PlushieLoadingOverlay> createState() => _PlushieLoadingOverlayState();
}

class _PlushieLoadingOverlayState extends State<_PlushieLoadingOverlay>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    ('🧵', 'Stitching the seams...'),
    ('🪡', 'Weaving the fabric...'),
    ('✨', 'Adding some magic...'),
    ('🎀', 'Tying the bow...'),
    ('🧸', 'Almost ready!'),
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  int _messageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, text) = _messages[_messageIndex];
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmAmber.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.warmAmber.withValues(alpha: 0.25),
                        AppColors.warmAmber.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.warmAmber.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppColors.warmAmber,
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder:
                    (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                child: Column(
                  key: ValueKey(_messageIndex),
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Crafting your plushie with care',
                style: TextStyle(fontSize: 13, color: AppColors.warmBrownLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PawPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFD4A047).withValues(alpha: 0.06)
          ..style = PaintingStyle.fill;

    void drawPaw(double x, double y, double scale) {
      // Main pad
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 24 * scale,
          height: 20 * scale,
        ),
        paint,
      );
      // Toe pads
      canvas.drawCircle(
        Offset(x - 9 * scale, y - 14 * scale),
        5 * scale,
        paint,
      );
      canvas.drawCircle(
        Offset(x - 3 * scale, y - 17 * scale),
        5 * scale,
        paint,
      );
      canvas.drawCircle(
        Offset(x + 4 * scale, y - 17 * scale),
        5 * scale,
        paint,
      );
      canvas.drawCircle(
        Offset(x + 10 * scale, y - 14 * scale),
        5 * scale,
        paint,
      );
    }

    drawPaw(30, 80, 1.0);
    drawPaw(size.width - 40, 160, 0.8);
    drawPaw(60, size.height * 0.4, 1.2);
    drawPaw(size.width - 20, size.height * 0.5, 0.9);
    drawPaw(20, size.height - 120, 0.7);
    drawPaw(size.width - 60, size.height - 80, 1.1);
    drawPaw(size.width * 0.5, 40, 0.75);
  }

  @override
  bool shouldRepaint(_PawPatternPainter oldDelegate) => false;
}
