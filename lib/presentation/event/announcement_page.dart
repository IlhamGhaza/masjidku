import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';
import 'annoucement_detail_page.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final List<Announcement> announcements = [
    Announcement(
      title: 'Jadwal Sholat Jumat',
      date: '12 Mei 2023',
      content:
          'Sholat Jumat akan dilaksanakan pada pukul 12:00 WIB dengan khatib Ustadz Ahmad Fauzi.',
      imageUrl: 'assets/images/announcement1.jpg',
    ),
    Announcement(
      title: 'Pengajian Rutin',
      date: '15 Mei 2023',
      content:
          'Pengajian rutin mingguan akan diadakan setelah sholat Maghrib dengan tema "Menjaga Keimanan di Era Digital".',
      imageUrl: 'assets/images/announcement2.jpg',
    ),
    Announcement(
      title: 'Kegiatan Ramadhan',
      date: '20 Mei 2023',
      content:
          'Jadwal kegiatan Ramadhan telah diperbarui. Silakan lihat papan pengumuman untuk informasi lebih lanjut.',
      imageUrl: 'assets/images/announcement3.jpg',
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
            title: const Text(
              'Pengumuman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colorScheme.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari pengumuman...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    return AnnouncementCard(announcement: announcements[index]);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add new announcement functionality
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class Announcement {
  final String title;
  final String date;
  final String content;
  final String imageUrl;

  Announcement({
    required this.title,
    required this.date,
    required this.content,
    required this.imageUrl,
  });
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              announcement.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      announcement.date,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to announcement detail
                    _showAnnouncementDetail(context, announcement);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'Baca selengkapnya',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
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

  void _showAnnouncementDetail(
    BuildContext context,
    Announcement announcement,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AnnouncementDetailPage(announcement: announcement),
      ),
    );
  }
}
