import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../l10n/app_localizations.dart';

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
    ),
    MasjidEvent(
      title: 'Buka Puasa Bersama',
      description:
          'Acara buka puasa bersama untuk jamaah dan masyarakat sekitar',
      date: DateTime.now().add(const Duration(days: 5)),
      location: 'Halaman Masjid',
    ),
    MasjidEvent(
      title: 'Tahsin Al-Quran',
      description: 'Belajar membaca Al-Quran dengan tajwid yang benar',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Ruang Belajar Masjid',
      speaker: 'Ustadz Mahmud',
    ),
    MasjidEvent(
      title: 'Santunan Anak Yatim',
      description:
          'Kegiatan santunan untuk anak yatim dan dhuafa di sekitar masjid',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'Aula Masjid',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            title: Text(
              AppLocalizations.of(context)!.upcoming_events,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            elevation: 0,
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body:
              _events.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : _buildEventsList(colorScheme),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.no_upcoming_events,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventsList(ColorScheme colorScheme) {
    return ListView.builder(
      itemCount: _events.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(event, colorScheme);
      },
    );
  }

  Widget _buildEventCard(MasjidEvent event, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            _buildEventDetail(
              Icons.calendar_today,
              _formatDate(event.date),
              colorScheme,
            ),
            const SizedBox(height: 4),
            _buildEventDetail(Icons.location_on, event.location, colorScheme),
            if (event.speaker != null) ...[
              const SizedBox(height: 4),
              _buildEventDetail(Icons.person, event.speaker!, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}

class MasjidEvent {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? speaker;

  MasjidEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.speaker,
  });
}
