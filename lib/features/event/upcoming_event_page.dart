import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';

class UpcomingEventPage extends StatefulWidget {
  const UpcomingEventPage({super.key});

  @override
  State<UpcomingEventPage> createState() => _UpcomingEventPageState();
}

class _UpcomingEventPageState extends State<UpcomingEventPage> {
  // Sample event data - in a real app, this would come from a repository or API
  final List<MasjidEvent> _events = [
    MasjidEvent(
      title: 'Kajian Mingguan',
      description: 'Kajian rutin tentang fiqih ibadah sehari-hari',
      date: DateTime.now().add(const Duration(days: 2)),
      location: 'Ruang Utama Masjid',
      speaker: 'Ustadz Ahmad',
      imageUrl: 'assets/images/kajian.jpg',
    ),
    MasjidEvent(
      title: 'Buka Puasa Bersama',
      description:
          'Acara buka puasa bersama untuk jamaah dan masyarakat sekitar',
      date: DateTime.now().add(const Duration(days: 5)),
      location: 'Halaman Masjid',
      imageUrl: 'assets/images/bukber.jpg',
    ),
    MasjidEvent(
      title: 'Tahsin Al-Quran',
      description: 'Belajar membaca Al-Quran dengan tajwid yang benar',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Ruang Belajar Masjid',
      speaker: 'Ustadz Mahmud',
      imageUrl: 'assets/images/tahsin.jpg',
    ),
    MasjidEvent(
      title: 'Santunan Anak Yatim',
      description:
          'Kegiatan santunan untuk anak yatim dan dhuafa di sekitar masjid',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'Aula Masjid',
      imageUrl: 'assets/images/santunan.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;
        final screenSize = MediaQuery.of(context).size;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upcoming Events'),
            centerTitle: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
          ),
          body:
              _events.isEmpty
                  ? _buildEmptyState(colorScheme, textTheme)
                  : _buildEventsList(colorScheme, textTheme, screenSize),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to add event page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add event feature coming soon')),
              );
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('No upcoming events', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Size screenSize,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image with date overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      event.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 180,
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(event.date),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Event details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(event.description, style: textTheme.bodyMedium),
                    const SizedBox(height: 16),

                    // Event metadata
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(event.date),
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (event.speaker != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(event.speaker!, style: textTheme.bodyMedium),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Show event details
                            _showEventDetails(context, event);
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Register for event
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registered for ${event.title}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, MasjidEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date & Time',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEEE, dd MMMM yyyy • HH:mm',
                              ).format(event.date),
                              style: textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            Text(event.location, style: textTheme.titleMedium),
                          ],
                        ),
                      ],
                    ),
                    if (event.speaker != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Speaker',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              Text(
                                event.speaker!,
                                style: textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('About Event', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(event.description, style: textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Registered for ${event.title}', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Register Now'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Share event functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share feature coming soon'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Share Event'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MasjidEvent {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? speaker;
  final String imageUrl;

  MasjidEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.speaker,
    required this.imageUrl,
  });
}
