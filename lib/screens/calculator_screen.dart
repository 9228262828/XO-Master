import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _justCalculated = false;
  String? _currentUser;

  late AnimationController _buttonPressController;
  late AnimationController _resultController;
  late Animation<double> _resultScale;

  @override
  void initState() {
    super.initState();
    _buttonPressController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _resultScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  @override
  void dispose() {
    _buttonPressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  // ─── Calculator Logic ───────────────────────────────────────────────────────

  void _onButtonPressed(String label) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isDigit(label) || label == '.') {
        _handleDigit(label);
      } else if (_isOperator(label)) {
        _handleOperator(label);
      } else if (label == '=') {
        _handleEquals();
      } else if (label == 'C') {
        _handleClear();
      } else if (label == 'CE') {
        _handleClearEntry();
      } else if (label == '+/-') {
        _handleToggleSign();
      } else if (label == '%') {
        _handlePercent();
      } else if (label == '⌫') {
        _handleBackspace();
      }
    });
  }

  bool _isDigit(String s) => RegExp(r'[0-9]').hasMatch(s);
  bool _isOperator(String s) => ['+', '-', '×', '÷'].contains(s);

  void _handleDigit(String digit) {
    if (digit == '.' && _display.contains('.')) return;

    if (_shouldResetDisplay || _justCalculated) {
      _display = digit == '.' ? '0.' : digit;
      _shouldResetDisplay = false;
      _justCalculated = false;
    } else {
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else {
        if (_display.length < 12) {
          _display = _display + digit;
        }
      }
    }
  }

  void _handleOperator(String op) {
    _justCalculated = false;

    if (_operator.isNotEmpty && !_shouldResetDisplay) {
      // Chain operations
      _secondOperand = double.tryParse(_display) ?? 0;
      final result = _calculate(_firstOperand, _secondOperand, _operator);
      _display = _formatResult(result);
      _firstOperand = result;
    } else {
      _firstOperand = double.tryParse(_display) ?? 0;
    }

    _operator = op;
    _expression = '${_formatResult(_firstOperand)} $op';
    _shouldResetDisplay = true;
  }

  void _handleEquals() {
    if (_operator.isEmpty) return;

    _secondOperand = double.tryParse(_display) ?? 0;
    _expression =
        '${_formatResult(_firstOperand)} $_operator ${_formatResult(_secondOperand)} =';

    final result = _calculate(_firstOperand, _secondOperand, _operator);

    _display = _formatResult(result);
    _firstOperand = result;
    _operator = '';
    _shouldResetDisplay = true;
    _justCalculated = true;

    _resultController.forward(from: 0).then((_) => _resultController.reverse());
  }

  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Remove trailing zeros for whole numbers
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      if (intVal.abs() < 1e12) return intVal.toString();
    }

    // Format decimal numbers
    String result = value.toStringAsFixed(8);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  void _handleClear() {
    _display = '0';
    _expression = '';
    _firstOperand = 0;
    _secondOperand = 0;
    _operator = '';
    _shouldResetDisplay = false;
    _justCalculated = false;
  }

  void _handleClearEntry() {
    _display = '0';
    _shouldResetDisplay = false;
  }

  void _handleToggleSign() {
    final val = double.tryParse(_display) ?? 0;
    _display = _formatResult(-val);
  }

  void _handlePercent() {
    final val = double.tryParse(_display) ?? 0;
    _display = _formatResult(val / 100);
  }

  void _handleBackspace() {
    if (_justCalculated) {
      _handleClear();
      return;
    }
    if (_display.length <= 1 ||
        (_display.startsWith('-') && _display.length == 2)) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                ),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'CalcPro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  'Hi, $_currentUser',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white60,
              size: 22,
            ),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 3,
            child: _buildDisplay(),
          ),
          // Button grid
          Expanded(
            flex: 5,
            child: _buildButtonGrid(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression line
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _expression,
              key: ValueKey(_expression),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Main display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: ScaleTransition(
              scale: _resultScale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  key: ValueKey(_display),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _display == 'Error'
                        ? const Color(0xFFFF4757)
                        : Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    final buttons = [
      // Row 1
      _CalcBtn('C', type: BtnType.clear),
      _CalcBtn('CE', type: BtnType.clear),
      _CalcBtn('%', type: BtnType.function),
      _CalcBtn('÷', type: BtnType.operator),
      // Row 2
      _CalcBtn('7', type: BtnType.number),
      _CalcBtn('8', type: BtnType.number),
      _CalcBtn('9', type: BtnType.number),
      _CalcBtn('×', type: BtnType.operator),
      // Row 3
      _CalcBtn('4', type: BtnType.number),
      _CalcBtn('5', type: BtnType.number),
      _CalcBtn('6', type: BtnType.number),
      _CalcBtn('-', type: BtnType.operator),
      // Row 4
      _CalcBtn('1', type: BtnType.number),
      _CalcBtn('2', type: BtnType.number),
      _CalcBtn('3', type: BtnType.number),
      _CalcBtn('+', type: BtnType.operator),
      // Row 5
      _CalcBtn('+/-', type: BtnType.function),
      _CalcBtn('0', type: BtnType.number),
      _CalcBtn('.', type: BtnType.number),
      _CalcBtn('=', type: BtnType.equals),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: buttons.length,
        itemBuilder: (context, i) => _buildButton(buttons[i]),
      ),
    );
  }

  Widget _buildButton(_CalcBtn btn) {
    final bg = _buttonBackground(btn.type, btn.label);
    final fg = _buttonForeground(btn.type);

    return GestureDetector(
      onTapDown: (_) => _onButtonPressed(btn.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: bg,
          boxShadow: btn.type == BtnType.equals
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : btn.type == BtnType.operator
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            onTap: () => _onButtonPressed(btn.label),
            child: Center(
              child: Text(
                btn.label,
                style: TextStyle(
                  color: fg,
                  fontSize: btn.label.length > 2 ? 16 : 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buttonBackground(BtnType type, String label) {
    switch (type) {
      case BtnType.operator:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
        );
      case BtnType.equals:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
        );
      case BtnType.clear:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF4757).withValues(alpha: 0.85),
            const Color(0xFFFF6B81).withValues(alpha: 0.85),
          ],
        );
      case BtnType.function:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3D3B60),
            const Color(0xFF4A4870),
          ],
        );
      case BtnType.number:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2D44),
            const Color(0xFF343454),
          ],
        );
    }
  }

  Color _buttonForeground(BtnType type) {
    switch (type) {
      case BtnType.operator:
      case BtnType.equals:
      case BtnType.clear:
        return Colors.white;
      case BtnType.function:
        return Colors.white.withValues(alpha: 0.9);
      case BtnType.number:
        return Colors.white;
    }
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFFF4757),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum BtnType { number, operator, equals, clear, function }

class _CalcBtn {
  const _CalcBtn(this.label, {required this.type});
  final String label;
  final BtnType type;
}
