import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    home: CalculatorScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ===========================================================================
  // 🔊 AUDIO
  // ===========================================================================
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 🧠 CALCULATOR STATE
  // ===========================================================================
  String _displayText = '0';
  String _historyText = '';

  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  bool _isErrorState = false;

  String _getOperatorSymbol(String op) {
    switch (op) {
      case 'add': return '+';
      case 'sub': return '-';
      case 'mul': return '×';
      case 'div': return '÷';
      default: return '';
    }
  }

  String _formatNumber(double value) {
    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 10,
    );
    String result = formatter.format(value);
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r"0*$"), "");
      result = result.replaceAll(RegExp(r"\.$"), "");
    }
    return result.replaceAll(",", "");
  }

  void _onButtonPressed(String id) {
    setState(() {
      if (_isErrorState) {
        _displayText = '0';
        _historyText = '';
        _firstOperand = null;
        _operator = null;
        _isErrorState = false;
        if (id == 'ac') return;
      }

      if ('0123456789'.contains(id)) {
        if (_displayText == '0' || _shouldResetDisplay) {
          _displayText = id;
          _shouldResetDisplay = false;
        } else if (_displayText.length < 15) {
          _displayText += id;
        }
      } else if (id == 'dot') {
        if (_shouldResetDisplay) {
          _displayText = '0.';
          _shouldResetDisplay = false;
        } else if (!_displayText.contains('.')) {
          _displayText += '.';
        }
      } else if (id == 'ac') {
        _displayText = '0';
        _historyText = '';
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = false;
        _isErrorState = false;
      } else if (id == 'back') {
        if (_displayText.length > 1) {
          _displayText =
              _displayText.substring(0, _displayText.length - 1);
        } else {
          _displayText = '0';
        }
      } else if (id == 'sign') {
        if (_displayText != '0') {
          _displayText = _displayText.startsWith('-')
              ? _displayText.substring(1)
              : '-$_displayText';
        }
      } else if (id == 'perc') {
        double value = double.tryParse(_displayText) ?? 0;
        _displayText = _formatNumber(value / 100);
      } else if (['add', 'sub', 'mul', 'div'].contains(id)) {
        _firstOperand = double.tryParse(_displayText);
        _operator = id;
        _shouldResetDisplay = true;
        _historyText =
        "${_formatNumber(_firstOperand!)} ${_getOperatorSymbol(id)}";
      } else if (id == 'equal') {
        if (_firstOperand != null && _operator != null) {
          double secondOperand =
              double.tryParse(_displayText) ?? 0;

          if (_operator == 'div' && secondOperand == 0) {
            _displayText = "Error";
            _historyText = "";
            _isErrorState = true;
            _firstOperand = null;
            _operator = null;
            _shouldResetDisplay = true;
            return;
          }

          double result = 0;
          switch (_operator) {
            case 'add': result = _firstOperand! + secondOperand; break;
            case 'sub': result = _firstOperand! - secondOperand; break;
            case 'mul': result = _firstOperand! * secondOperand; break;
            case 'div': result = _firstOperand! / secondOperand; break;
          }

          _historyText =
          "${_formatNumber(_firstOperand!)} ${_getOperatorSymbol(_operator!)} ${_formatNumber(secondOperand)} =";
          _displayText = _formatNumber(result);
          _firstOperand = null;
          _operator = null;
          _shouldResetDisplay = true;
        }
      }
    });
  }

  // ===========================================================================
  // 🎨 VISUAL STATE
  // ===========================================================================
  String? _activeButton;
  bool _isLedGlowing = false;

  void _onButtonDown(String id) async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(
        AssetSource(id == 'equal'
            ? 'audio/equal.mp3'
            : 'audio/click.mp3'),
      );
    } catch (_) {}

    setState(() {
      _activeButton = id;
      _isLedGlowing = true;
    });
  }

  void _onButtonUp(String id) {
    _onButtonPressed(id);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _activeButton = null;
          _isLedGlowing = _isErrorState;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ===========================================================================
    // 🔒 SOURCE DESIGN SIZE (DO NOT CHANGE)
    // ===========================================================================
    const double sourceWidth = 1696;
    const double sourceHeight = 2528;

    final Map<String, double> ledConfig = {
      'x': 565, 'y': -162, 'width': 800,
    };

    final Map<String, double> displayConfig = {
      'top': 650, 'right': 350, 'width': 950, 'height': 300,
    };

    final Map<String, double> historyConfig = {
      'top': 580, 'right': 360, 'width': 950, 'height': 150,
    };

    final Map<String, Map<String, dynamic>> buttonConfigs = {
      'ac': {'x': 520,'y': 1223,'width': 300,'asset': 'assets/images/buttons/btn_ac_pressed.png'},
      'back': {'x': 222,'y': 1210,'width': 300,'asset': 'assets/images/buttons/btn_backspace_pressed.png'},
      'perc': {'x': 808,'y': 1220,'width': 300,'asset': 'assets/images/buttons/btn_percent_pressed.png'},
      'div': {'x': 1130,'y': 1237,'width': 308,'asset': 'assets/images/buttons/btn_divide_pressed.png'},
      '7': {'x': 224,'y': 1442,'width': 300,'asset': 'assets/images/buttons/btn_7_pressed.png'},
      '8': {'x': 505,'y': 1440,'width': 300,'asset': 'assets/images/buttons/btn_8_pressed.png'},
      '9': {'x': 808,'y': 1445,'width': 300,'asset': 'assets/images/buttons/btn_9_pressed.png'},
      'mul': {'x': 1135,'y': 1442,'width': 300,'asset': 'assets/images/buttons/btn_multiply_pressed.png'},
      '4': {'x': 224,'y': 1660,'width': 300,'asset': 'assets/images/buttons/btn_4_pressed.png'},
      '5': {'x': 515,'y': 1660,'width': 300,'asset': 'assets/images/buttons/btn_5_pressed.png'},
      '6': {'x': 803,'y': 1660,'width': 300,'asset': 'assets/images/buttons/btn_6_pressed.png'},
      'sub': {'x': 1127,'y': 1660,'width': 300,'asset': 'assets/images/buttons/btn_subtract_pressed.png'},
      '1': {'x': 227,'y': 1878,'width': 300,'asset': 'assets/images/buttons/btn_1_pressed.png'},
      '2': {'x': 518,'y': 1878,'width': 300,'asset': 'assets/images/buttons/btn_2_pressed.png'},
      '3': {'x': 806,'y': 1878,'width': 300,'asset': 'assets/images/buttons/btn_3_pressed.png'},
      'add': {'x': 1130,'y': 1875,'width': 300,'asset': 'assets/images/buttons/btn_add_pressed.png'},
      'sign': {'x': 230,'y': 2090,'width': 310,'asset': 'assets/images/buttons/btn_plus_minus_pressed.png'},
      '0': {'x': 513,'y': 2104,'width': 310,'asset': 'assets/images/buttons/btn_0_pressed.png'},
      'dot': {'x': 810,'y': 2119,'width': 300,'asset': 'assets/images/buttons/btn_dot_pressed.png'},
      'equal': {'x': 1130,'y': 2108,'width': 310,'asset': 'assets/images/buttons/btn_equal_pressed.png'},
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ✅ UPDATED: Always prioritize Height.
            // This ensures the image touches Top/Bottom edges.
            final scale = constraints.maxHeight / sourceHeight;

            final scaledWidth = sourceWidth * scale;
            final scaledHeight = sourceHeight * scale;

            return Center(
              // ✅ ADDED: OverflowBox allows the width to exceed the screen width
              // without being squashed by the parent constraints.
              child: OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                minHeight: 0,
                maxHeight: double.infinity,
                child: SizedBox(
                  width: scaledWidth,
                  height: scaledHeight,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/calculator_background.png',
                        width: scaledWidth,
                        height: scaledHeight,
                        fit: BoxFit.cover,
                      ),

                      Positioned(
                        top: historyConfig['top']! * scale,
                        right: historyConfig['right']! * scale,
                        width: historyConfig['width']! * scale,
                        height: historyConfig['height']! * scale,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _historyText,
                            style: TextStyle(
                              fontFamily: 'Digital',
                              fontSize: 100 * scale,
                              color: const Color(0xFFBF8D43).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: displayConfig['top']! * scale,
                        right: displayConfig['right']! * scale,
                        width: displayConfig['width']! * scale,
                        height: displayConfig['height']! * scale,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _displayText,
                            style: TextStyle(
                              fontFamily: 'Digital',
                              fontSize: 220 * scale,
                              color: _isErrorState
                                  ? Colors.red
                                  : const Color(0xFFBF8D43),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: ledConfig['x']! * scale,
                        top: ledConfig['y']! * scale,
                        width: ledConfig['width']! * scale,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 50),
                          opacity: (_isLedGlowing || _isErrorState) ? 1 : 0,
                          child: Image.asset(
                            _isErrorState
                                ? 'assets/images/led_glow_red.png'
                                : 'assets/images/led_glow.png',
                          ),
                        ),
                      ),

                      ...buttonConfigs.entries.map((e) {
                        final id = e.key;
                        final c = e.value;
                        return Positioned(
                          left: c['x'] * scale,
                          top: c['y'] * scale,
                          width: c['width'] * scale,
                          child: GestureDetector(
                            onTapDown: (_) => _onButtonDown(id),
                            onTapUp: (_) => _onButtonUp(id),
                            child: Opacity(
                              opacity: _activeButton == id ? 1 : 0,
                              child: Image.asset(c['asset']),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
