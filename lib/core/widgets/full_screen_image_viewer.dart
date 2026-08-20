import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final String? title;
  final String? subtitle;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.title,
    this.subtitle,
  });

  static void open(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
    String? title,
    String? subtitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;

  double _currentScale = 1.0;
  bool _showControls = true;

  static const double _minScale = 0.8;
  static const double _maxScale = 6.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward(from: 0);
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_currentScale > 1.1) {
      // Reset back to 1.0
      _animateToMatrix(Matrix4.identity());
    } else {
      // Zoom in to 2.5x centered around tap point
      final position = details.localPosition;
      const targetScale = 2.5;

      final dx = -position.dx * (targetScale - 1);
      final dy = -position.dy * (targetScale - 1);
      final zoomed = Matrix4.identity()
        ..setEntry(0, 0, targetScale)
        ..setEntry(1, 1, targetScale)
        ..setEntry(0, 3, dx)
        ..setEntry(1, 3, dy);

      _animateToMatrix(zoomed);
    }
  }

  void _zoomIn() {
    final newScale = (_currentScale + 0.5).clamp(_minScale, _maxScale);
    _setZoomScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale - 0.5).clamp(_minScale, _maxScale);
    _setZoomScale(newScale);
  }

  void _resetZoom() {
    _animateToMatrix(Matrix4.identity());
  }

  void _setZoomScale(double targetScale) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final dx = -centerX * (targetScale - 1);
    final dy = -centerY * (targetScale - 1);
    final target = Matrix4.identity()
      ..setEntry(0, 0, targetScale)
      ..setEntry(1, 1, targetScale)
      ..setEntry(0, 3, dx)
      ..setEntry(1, 3, dy);

    _animateToMatrix(target);
  }

  Widget _buildImageWidget() {
    final isBase64 = widget.imageUrl.startsWith('data:image');

    Widget imageContent;

    if (isBase64) {
      try {
        final commaIndex = widget.imageUrl.indexOf(',');
        final base64Data = commaIndex != -1
            ? widget.imageUrl.substring(commaIndex + 1)
            : widget.imageUrl;
        final bytes = base64Decode(base64Data);
        imageContent = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } catch (e) {
        imageContent = _buildErrorWidget();
      }
    } else {
      imageContent = Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final totalBytes = loadingProgress.expectedTotalBytes;
          final loadedBytes = loadingProgress.cumulativeBytesLoaded;
          final progress = totalBytes != null ? loadedBytes / totalBytes : null;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading high-res image...',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: imageContent,
      );
    }
    return imageContent;
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_rounded,
              color: AppColors.rejected,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load image',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The image link might be invalid or unreachable',
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zoomPercentage = (_currentScale * 100).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Interactive Pan & Zoom Area
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            onDoubleTapDown: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minScale,
              maxScale: _maxScale,
              panEnabled: true,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              child: Center(
                child: _buildImageWidget(),
              ),
            ),
          ),

          // Top Header Overlay (Dismiss & Details)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Close Button
                  Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Reset View Button in Appbar
                  if (_currentScale > 1.05)
                    Material(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: _resetZoom,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.fit_screen_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reset',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Floating Zoom Controls Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showControls ? MediaQuery.of(context).padding.bottom + 20 : -100,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom Out Button
                    _buildZoomButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Zoom Out',
                      onTap: _zoomOut,
                      enabled: _currentScale > _minScale,
                    ),
                    const SizedBox(width: 8),

                    // Zoom Percentage Pill
                    Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$zoomPercentage%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Zoom In Button
                    _buildZoomButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Zoom In',
                      onTap: _zoomIn,
                      enabled: _currentScale < _maxScale,
                    ),
                    const SizedBox(width: 8),

                    // Divider
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 8),

                    // Fit to screen / 100% Reset Button
                    _buildZoomButton(
                      icon: Icons.center_focus_strong_rounded,
                      tooltip: 'Fit to Screen',
                      onTap: _resetZoom,
                      enabled: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Double tap hint overlay when at default scale
          if (_showControls && _currentScale <= 1.05)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 76,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pinch_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch or double tap to zoom',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 20,
        ),
        onPressed: enabled ? onTap : null,
        tooltip: tooltip,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}
