import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isFlashOn = false;
  bool _hasScanned = false;
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    HapticFeedback.mediumImpact();
    _controller.stop();

    final scannedValue = barcode.rawValue!;

    _showResultBottomSheet(scannedValue);
  }

  void _resetScanner() {
    setState(() => _hasScanned = false);
    _controller.start();
  }

  void _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _showResultBottomSheet(String value) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        value: value,
        onScanAgain: () {
          Navigator.pop(context);
          _resetScanner();
        },
        onConfirm: () {
          Navigator.pop(context); // tutup sheet
          Navigator.pop(
            context,
            value,
          ); // kembalikan value ke halaman sebelumnya
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Kamera ──────────────────────────────────────────────
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // ── Overlay gelap + lubang scanner ──────────────────────
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ScanOverlayPainter(),
          ),

          // ── Garis scan animasi ───────────────────────────────────
          _ScanLine(animation: _scanAnimation),

          // ── Sudut-sudut frame ────────────────────────────────────
          const _ScanCorners(),

          // ── AppBar custom ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _isFlashOn ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: const Alignment(0, 0.55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Arahkan kamera ke QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  static const double _holeSize = 260;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30),
      width: _holeSize,
      height: _holeSize,
    );

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(holeRect, const Radius.circular(16));

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatelessWidget {
  final Animation<double> animation;
  static const double _holeSize = 260;

  const _ScanLine({required this.animation});

  @override
  Widget build(BuildContext context) {
    final center = MediaQuery.of(context).size.height / 2 - 30;
    final top = center - _holeSize / 2;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Positioned(
          left: (MediaQuery.of(context).size.width - _holeSize) / 2 + 8,
          top: top + animation.value * (_holeSize - 4),
          child: Container(
            width: _holeSize - 16,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blueAccent.withOpacity(0.8),
                  Colors.blue,
                  Colors.blueAccent.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScanCorners extends StatelessWidget {
  static const double _holeSize = 260;
  static const double _cornerLen = 24;
  static const double _cornerThick = 3;

  const _ScanCorners();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final left = (size.width - _holeSize) / 2;
    final top = size.height / 2 - 30 - _holeSize / 2;
    const radius = 4.0;
    const color = Colors.blueAccent;

    Widget corner({required bool isTop, required bool isLeft}) {
      return Positioned(
        left: isLeft ? left - 1 : null,
        right: isLeft ? null : left - 1,
        top: isTop ? top - 1 : null,
        bottom: isTop ? null : size.height - (top + _holeSize) - 1,
        child: SizedBox(
          width: _cornerLen + radius,
          height: _cornerLen + radius,
          child: CustomPaint(
            painter: _CornerPainter(
              isTop: isTop,
              isLeft: isLeft,
              color: color,
              length: _cornerLen,
              thickness: _cornerThick,
              radius: radius,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(isTop: true, isLeft: true),
        corner(isTop: true, isLeft: false),
        corner(isTop: false, isLeft: true),
        corner(isTop: false, isLeft: false),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop, isLeft;
  final Color color;
  final double length, thickness, radius;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.length,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x = isLeft ? 0 : size.width;
    final double y = isTop ? 0 : size.height;
    final double hDir = isLeft ? 1 : -1;
    final double vDir = isTop ? 1 : -1;

    final path = Path()
      ..moveTo(x + hDir * length, y)
      ..lineTo(x + hDir * radius, y)
      ..arcToPoint(
        Offset(x, y + vDir * radius),
        radius: Radius.circular(radius),
        clockwise: isLeft == isTop,
      )
      ..lineTo(x, y + vDir * length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResultSheet extends StatelessWidget {
  final String value;
  final VoidCallback onScanAgain;
  final VoidCallback onConfirm;

  const _ResultSheet({
    required this.value,
    required this.onScanAgain,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon sukses
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'QR Berhasil Dibaca',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Value container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),

          // Tombol
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onScanAgain,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  child: const Text('Scan Lagi'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Gunakan'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
