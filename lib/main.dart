import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MaterialApp(
  home: AdvancedQrApp(),
  debugShowCheckedModeBanner: false,
));

class AdvancedQrApp extends StatefulWidget {
  const AdvancedQrApp({super.key});

  @override
  State<AdvancedQrApp> createState() => _AdvancedQrAppState();
}

class _AdvancedQrAppState extends State<AdvancedQrApp> with TickerProviderStateMixin {
  String qrData = 'https://flutter.dev';
  Color gradientStart = const Color(0xFF667eea);
  Color gradientEnd = const Color(0xFF764ba2);
  Color backgroundColor = Colors.white;
  Color frameColor = Colors.transparent;

  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // Customization options
  QrShape selectedShape = QrShape.smooth;
  GradientType gradientType = GradientType.linear;
  double cornerRadius = 0.3;
  double frameWidth = 0.0;
  bool enableAnimation = false;
  bool enableGlow = false;
  bool enableShadow = true;
  bool enableShimmer = false;
  double qrSize = 280.0;

  // Logo options
  File? customLogo;
  bool enableLogo = true;
  bool useCustomLogo = false;
  double logoSize = 0.2; // Percentage of QR code size
  LogoStyle logoStyle = LogoStyle.circle;
  Color logoBackgroundColor = Colors.white;
  bool logoHasBorder = true;
  Color logoBorderColor = Colors.grey;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Preset themes
  final List<QrTheme> themes = [
    QrTheme('Ocean', Color(0xFF667eea), Color(0xFF764ba2), Colors.white),
    QrTheme('Sunset', Color(0xFFf093fb), Color(0xFFf5576c), Colors.white),
    QrTheme('Forest', Color(0xFF11998e), Color(0xFF38ef7d), Colors.white),
    QrTheme('Night', Color(0xFF2c3e50), Color(0xFF4ca1af), Colors.black),
    QrTheme('Gold', Color(0xFFf7971e), Color(0xFFffd200), Colors.black),
    QrTheme('Purple', Color(0xFF8360c3), Color(0xFF2ebf91), Colors.white),
    QrTheme('Fire', Color(0xFFfa709a), Color(0xFFfee140), Colors.white),
    QrTheme('Ice', Color(0xFF74b9ff), Color(0xFF0984e3), Colors.white),
  ];

  final GlobalKey repaintKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = qrData;

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive breakpoints
              bool isMobile = constraints.maxWidth < 600;
              bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
              bool isDesktop = constraints.maxWidth >= 1200;

              return Column(
                children: [
                  _buildHeader(isMobile),
                  Expanded(
                    child: isMobile
                        ? _buildMobileLayout()
                        : isTablet
                        ? _buildTabletLayout()
                        : _buildDesktopLayout(),
                  ),
                  _buildBottomActions(isMobile),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQrPreview(),
          const SizedBox(height: 24),
          _buildInputSection(),
          const SizedBox(height: 24),
          _buildCustomizationTabs(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildQrPreview(),
                const SizedBox(height: 16),
                _buildInputSection(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildCustomizationTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildQrPreview(),
                const SizedBox(height: 24),
                _buildInputSection(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: _buildCustomizationTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.qr_code,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR Generator Pro',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Create beautiful QR codes with custom logos',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive QR size
        double responsiveQrSize = math.min(
          constraints.maxWidth * 0.8,
          qrSize,
        );

        Widget qrWidget = Container(
          padding: EdgeInsets.all(frameWidth > 0 ? 16 : 0),
          decoration: frameWidth > 0 ? BoxDecoration(
            color: frameColor == Colors.transparent ? null : frameColor,
            borderRadius: BorderRadius.circular(20),
            border: frameColor == Colors.transparent ? Border.all(
              color: Colors.grey[300]!,
              width: frameWidth,
            ) : null,
          ) : null,
          child: RepaintBoundary(
            key: repaintKey,
            child: Container(
              width: responsiveQrSize,
              height: responsiveQrSize,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: enableShadow ? [
                  BoxShadow(
                    color: gradientStart.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: _buildQrCode(),
            ),
          ),
        );

        if (enableAnimation) {
          qrWidget = AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi * 0.1,
                child: child,
              );
            },
            child: qrWidget,
          );
        }

        if (enableGlow) {
          qrWidget = AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradientStart.withOpacity(0.6 * _pulseController.value),
                      blurRadius: 30 + (20 * _pulseController.value),
                      spreadRadius: 5 + (10 * _pulseController.value),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: qrWidget,
          );
        }

        return Center(child: qrWidget);
      },
    );
  }

  Widget _buildQrCode() {
    Widget qrChild = PrettyQrView.data(
      data: qrData.isEmpty ? 'https://flutter.dev' : qrData,
      decoration: PrettyQrDecoration(
        shape: _getQrShape(),
        image: enableLogo ? _buildLogoDecoration() : null,
      ),
    );

    if (enableShimmer) {
      qrChild = AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStart,
                  Colors.white.withOpacity(0.8),
                  gradientEnd,
                ],
                stops: [
                  math.max(0.0, _shimmerController.value - 0.3),
                  _shimmerController.value,
                  math.min(1.0, _shimmerController.value + 0.3),
                ],
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: qrChild,
      );
    }

    return qrChild;
  }

  PrettyQrDecorationImage? _buildLogoDecoration() {
    if (!enableLogo) return null;

    if (useCustomLogo && customLogo != null) {
      return PrettyQrDecorationImage(
        image: FileImage(customLogo!),
        scale: logoSize, // Use scale instead of size
        padding: const EdgeInsets.all(8),
        colorFilter: ColorFilter.mode(
          logoBackgroundColor,
          BlendMode.dstIn,
        ),
      );
    }

    // Default Flutter logo with dynamic styling
    return PrettyQrDecorationImage(
      image: const AssetImage('assets/flutterlogo.png'), // Make sure to add this asset
      scale: logoSize, // Use scale instead of size
      padding: const EdgeInsets.all(8),
    );
  }

  PrettyQrShape _getQrShape() {
    Gradient gradient = _createGradient();

    switch (selectedShape) {
      case QrShape.smooth:
        return PrettyQrSmoothSymbol(
          color: PrettyQrBrush.gradient(gradient: gradient),
        );
      case QrShape.rounded:
        return PrettyQrRoundedSymbol(
          color: PrettyQrBrush.gradient(gradient: gradient),
        );
      case QrShape.square:
      default:
        return PrettyQrSmoothSymbol(
          color: PrettyQrBrush.gradient(gradient: gradient),
        );
    }
  }

  Gradient _createGradient() {
    switch (gradientType) {
      case GradientType.linear:
        return LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GradientType.radial:
        return RadialGradient(
          colors: [gradientStart, gradientEnd],
          stops: const [0.3, 1.0],
        );
      case GradientType.sweep:
        return SweepGradient(
          colors: [gradientStart, gradientEnd, gradientStart],
          stops: const [0.0, 0.5, 1.0],
        );
    }
  }

  Widget _buildInputSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QR Code Content',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: constraints.maxWidth < 600 ? 2 : 3,
                  decoration: InputDecoration(
                    hintText: 'Enter text, URL, or any data...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (val) => setState(() => qrData = val),
                ),
                const SizedBox(height: 16),
                _buildQuickPresets(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Templates',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('Website', 'https://your-website.com'),
                _buildPresetChip('WiFi', 'WIFI:T:WPA;S:NetworkName;P:Password;;'),
                _buildPresetChip('Email', 'mailto:contact@example.com'),
                _buildPresetChip('Phone', 'tel:+1234567890'),
                _buildPresetChip('Location', 'geo:37.7749,-122.4194'),
                _buildPresetChip('SMS', 'sms:+1234567890?body=Hello'),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, String data) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        setState(() {
          qrData = data;
          _textController.text = data;
        });
      },
      backgroundColor: gradientStart.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCustomizationTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DefaultTabController(
          length: 5, // Added Logo tab
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: TabBar(
                    isScrollable: constraints.maxWidth < 600,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Style'),
                      Tab(text: 'Colors'),
                      Tab(text: 'Logo'),
                      Tab(text: 'Effects'),
                      Tab(text: 'Themes'),
                    ],
                  ),
                ),
                SizedBox(
                  height: constraints.maxWidth < 600 ? 400 : 350,
                  child: TabBarView(
                    children: [
                      _buildStyleTab(),
                      _buildColorsTab(),
                      _buildLogoTab(),
                      _buildEffectsTab(),
                      _buildThemesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Shape Style'),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 400
                  ? Column(
                children: QrShape.values.map((shape) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildShapeOption(shape, true),
                  );
                }).toList(),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: QrShape.values.map((shape) {
                  return _buildShapeOption(shape, false);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Size'),
          Slider(
            value: qrSize,
            min: 200,
            max: 400,
            divisions: 20,
            label: '${qrSize.round()}px',
            onChanged: (val) => setState(() => qrSize = val),
          ),
          _buildSectionTitle('Corner Radius'),
          Slider(
            value: cornerRadius,
            min: 0,
            max: 1,
            divisions: 20,
            label: '${(cornerRadius * 100).round()}%',
            onChanged: (val) => setState(() => cornerRadius = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Logo Settings'),
          SwitchListTile(
            title: const Text('Enable Logo'),
            value: enableLogo,
            onChanged: (val) => setState(() => enableLogo = val),
            activeColor: gradientStart,
            contentPadding: EdgeInsets.zero,
          ),
          if (enableLogo) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Logo Source'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Default', style: TextStyle(fontSize: 14)),
                    value: false,
                    groupValue: useCustomLogo,
                    onChanged: (val) => setState(() => useCustomLogo = val!),
                    activeColor: gradientStart,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Custom', style: TextStyle(fontSize: 14)),
                    value: true,
                    groupValue: useCustomLogo,
                    onChanged: (val) => setState(() => useCustomLogo = val!),
                    activeColor: gradientStart,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (useCustomLogo) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.upload_file),
                  label: Text(customLogo == null ? 'Choose Logo' : 'Change Logo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (customLogo != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    image: DecorationImage(
                      image: FileImage(customLogo!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            _buildSectionTitle('Logo Size'),
            Slider(
              value: logoSize,
              min: 0.1,
              max: 0.4,
              divisions: 15,
              label: '${(logoSize * 100).round()}%',
              onChanged: (val) => setState(() => logoSize = val),
            ),
            _buildSectionTitle('Logo Style'),
            DropdownButtonFormField<LogoStyle>(
              value: logoStyle,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: LogoStyle.values.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => logoStyle = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildColorButton(
                    'Logo BG',
                    logoBackgroundColor,
                        () => _pickLogoBackgroundColor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildColorButton(
                    'Border',
                    logoBorderColor,
                        () => _pickLogoBorderColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Logo Border'),
              value: logoHasBorder,
              onChanged: (val) => setState(() => logoHasBorder = val),
              activeColor: gradientStart,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildColorButton(
                  'Start Color',
                  gradientStart,
                      () => _pickColor(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColorButton(
                  'End Color',
                  gradientEnd,
                      () => _pickColor(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildColorButton(
                  'Background',
                  backgroundColor,
                      () => _pickBackgroundColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColorButton(
                  'Frame',
                  frameColor,
                      () => _pickFrameColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Gradient Type'),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    _buildGradientOption(GradientType.linear),
                    _buildGradientOption(GradientType.radial),
                    _buildGradientOption(GradientType.sweep),
                  ],
                );
              }
              return SegmentedButton<GradientType>(
                segments: const [
                  ButtonSegment(value: GradientType.linear, label: Text('Linear')),
                  ButtonSegment(value: GradientType.radial, label: Text('Radial')),
                  ButtonSegment(value: GradientType.sweep, label: Text('Sweep')),
                ],
                selected: {gradientType},
                onSelectionChanged: (Set<GradientType> selection) {
                  setState(() => gradientType = selection.first);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOption(GradientType type) {
    return RadioListTile<GradientType>(
      title: Text(type.name.toUpperCase()),
      value: type,
      groupValue: gradientType,
      onChanged: (val) => setState(() => gradientType = val!),
      activeColor: gradientStart,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildEffectTile('Animation', enableAnimation, (val) {
            setState(() => enableAnimation = val);
          }),
          _buildEffectTile('Glow Effect', enableGlow, (val) {
            setState(() => enableGlow = val);
          }),
          _buildEffectTile('Drop Shadow', enableShadow, (val) {
            setState(() => enableShadow = val);
          }),
          _buildEffectTile('Shimmer', enableShimmer, (val) {
            setState(() => enableShimmer = val);
          }),
          const SizedBox(height: 16),
          _buildSectionTitle('Frame Width'),
          Slider(
            value: frameWidth,
            min: 0,
            max: 8,
            divisions: 16,
            label: frameWidth.toStringAsFixed(1),
            onChanged: (val) => setState(() => frameWidth = val),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: crossAxisCount == 1 ? 3 : 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              return _buildThemeCard(theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(QrTheme theme) {
    return GestureDetector(
      onTap: () => _applyTheme(theme),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.startColor, theme.endColor],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.startColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            theme.name,
            style: TextStyle(
              color: theme.backgroundColor == Colors.white ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShapeOption(QrShape shape, bool isFullWidth) {
    final isSelected = selectedShape == shape;
    return GestureDetector(
      onTap: () => setState(() => selectedShape = shape),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? gradientStart.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: gradientStart, width: 2) : null,
        ),
        child: isFullWidth
            ? Row(
          children: [
            Icon(
              _getShapeIcon(shape),
              color: isSelected ? gradientStart : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              shape.name.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? gradientStart : Colors.grey[600],
              ),
            ),
          ],
        )
            : Column(
          children: [
            Icon(
              _getShapeIcon(shape),
              color: isSelected ? gradientStart : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              shape.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? gradientStart : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getShapeIcon(QrShape shape) {
    switch (shape) {
      case QrShape.smooth:
        return Icons.circle;
      case QrShape.rounded:
        return Icons.rounded_corner;
      case QrShape.square:
        return Icons.square;
    }
  }

  Widget _buildColorButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _getContrastColor(color),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEffectTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: gradientStart,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveQr,
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Save to Gallery', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: gradientStart,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _shareQr,
              icon: const Icon(Icons.share),
              label: const Text('Share QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareQr,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _saveQr,
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Save to Gallery', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: gradientStart,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void _applyTheme(QrTheme theme) {
    setState(() {
      gradientStart = theme.startColor;
      gradientEnd = theme.endColor;
      backgroundColor = theme.backgroundColor;
    });
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          customLogo = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking logo: $e');
    }
  }

  Future<void> _pickColor(bool isStart) async {
    Color selected = isStart ? gradientStart : gradientEnd;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isStart ? 'Pick start color' : 'Pick end color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (col) => selected = col,
            showLabel: true,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (isStart) gradientStart = selected;
                else gradientEnd = selected;
              });
              Navigator.pop(context);
            },
            child: const Text('Select'),
          )
        ],
      ),
    );
  }

  Future<void> _pickBackgroundColor() async {
    Color selected = backgroundColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick background color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (col) => selected = col,
            showLabel: true,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => backgroundColor = selected);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          )
        ],
      ),
    );
  }

  Future<void> _pickFrameColor() async {
    Color selected = frameColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick frame color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (col) => selected = col,
            showLabel: true,
            enableAlpha: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => frameColor = selected);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          )
        ],
      ),
    );
  }

  Future<void> _pickLogoBackgroundColor() async {
    Color selected = logoBackgroundColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick logo background color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (col) => selected = col,
            showLabel: true,
            enableAlpha: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => logoBackgroundColor = selected);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          )
        ],
      ),
    );
  }

  Future<void> _pickLogoBorderColor() async {
    Color selected = logoBorderColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick logo border color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (col) => selected = col,
            showLabel: true,
            enableAlpha: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => logoBorderColor = selected);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          )
        ],
      ),
    );
  }

  Future<void> _saveQr() async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List png = byteData!.buffer.asUint8List();
      final res = await ImageGallerySaver.saveImage(png, name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}');

      if (mounted) {
        _showSuccessSnackBar('QR Code saved successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving QR code: $e');
    }
  }

  Future<void> _shareQr() async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List png = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(png);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this QR code!',
      );
    } catch (e) {
      _showErrorSnackBar('Error sharing QR code: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Enums and Classes
enum QrShape { smooth, rounded, square }
enum GradientType { linear, radial, sweep }
enum LogoStyle { circle, square, rounded }

class QrTheme {
  final String name;
  final Color startColor;
  final Color endColor;
  final Color backgroundColor;

  QrTheme(this.name, this.startColor, this.endColor, this.backgroundColor);
}