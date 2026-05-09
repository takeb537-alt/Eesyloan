import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeToPayWidget extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentComplete;
  const SwipeToPayWidget(
      {super.key, required this.amount, required this.onPaymentComplete});
  @override
  State<SwipeToPayWidget> createState() => _SwipeToPayWidgetState();
}

class _SwipeToPayWidgetState extends State<SwipeToPayWidget>
    with SingleTickerProviderStateMixin {
  double _pos = 0;
  bool _done = false;
  double _trackW = 0;
  late AnimationController _snap;
  late Animation<double> _snapAnim;
  static const double _thumb = 56;

  @override
  void initState() {
    super.initState();
    _snap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _snapAnim = Tween<double>(begin: 0, end: 0).animate(_snap)
      ..addListener(() => setState(() => _pos = _snapAnim.value));
  }

  @override
  void dispose() { _snap.dispose(); super.dispose(); }

  void _onUpdate(DragUpdateDetails d) {
    if (_done) return;
    setState(() => _pos = (_pos + d.delta.dx).clamp(0, _trackW - _thumb));
  }

  void _onEnd(DragEndDetails _) {
    if (_done) return;
    if (_pos >= (_trackW - _thumb) * 0.85) {
      HapticFeedback.heavyImpact();
      setState(() { _pos = _trackW - _thumb; _done = true; });
      Future.delayed(const Duration(milliseconds: 400),
          widget.onPaymentComplete);
    } else {
      _snapAnim = Tween<double>(begin: _pos, end: 0)
          .animate(CurvedAnimation(parent: _snap, curve: Curves.easeOut));
      _snap.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      _trackW = c.maxWidth;
      final prog = _trackW > 0
          ? (_pos / (_trackW - _thumb)).clamp(0.0, 1.0) : 0.0;
      return Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color(0xFFE3F2FD),
          border: Border.all(color: const Color(0xFF1565C0), width: 1.5),
        ),
        child: Stack(alignment: Alignment.centerLeft, children: [
          Container(
            width: _pos + _thumb, height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(colors: _done
                ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                : [const Color(0xFF1565C0).withOpacity(0.3),
                   const Color(0xFF1976D2).withOpacity(0.5)]),
            ),
          ),
          Center(child: Opacity(
            opacity: (1 - prog * 2).clamp(0.0, 1.0),
            child: Text(
              '▶▶  Swipe to Pay ₹${widget.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: const Color(0xFF1565C0).withOpacity(0.8),
                fontWeight: FontWeight.w600, fontSize: 14),
            ),
          )),
          GestureDetector(
            onHorizontalDragUpdate: _onUpdate,
            onHorizontalDragEnd: _onEnd,
            child: Container(
              margin: EdgeInsets.only(left: _pos),
              width: _thumb, height: _thumb,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _done ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(_done ? Icons.check : Icons.arrow_forward,
                color: Colors.white, size: 26),
            ),
          ),
        ]),
      );
    });
  }
}
