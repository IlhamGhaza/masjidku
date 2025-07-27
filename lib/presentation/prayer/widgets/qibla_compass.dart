import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  Future<bool> get _deviceSupport async {
    final support = await FlutterQiblah.androidDeviceSensorSupport();
    return support ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _deviceSupport,
      builder: (_, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error.toString()}"),
          );
        }

        if (snapshot.data == true) {
          return const _QiblaCompassWidget();
        } else {
          return const Center(
            child: Text("Device is not supported or does not have the necessary sensors"),
          );
        }
      },
    );
  }
}

class _QiblaCompassWidget extends StatelessWidget {
  const _QiblaCompassWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Arah Kiblat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass background
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                
                // Compass direction indicators
                ..._buildDirectionIndicators(colorScheme),
                
                // Qibla direction indicator
                StreamBuilder<QiblahDirection>(
                  stream: FlutterQiblah.qiblahStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    
                    final qiblahDirection = snapshot.data!;
                    
                    return Transform.rotate(
                      angle: (qiblahDirection.qiblah * -1) * (3.14159 / 180),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.explore,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${qiblahDirection.direction.toStringAsFixed(1)}°',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hadapkan perangkat ke arah kiblat',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildDirectionIndicators(ColorScheme colorScheme) {
    return [
      // North indicator
      Positioned(
        top: 8,
        child: Text(
          'N',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      // East indicator
      Positioned(
        right: 8,
        child: Text(
          'E',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      // South indicator
      Positioned(
        bottom: 8,
        child: Text(
          'S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      // West indicator
      Positioned(
        left: 8,
        child: Text(
          'W',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      // Center point
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary,
        ),
      ),
    ];
  }
}
