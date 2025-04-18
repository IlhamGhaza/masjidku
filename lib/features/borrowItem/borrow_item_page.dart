import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';

class BorrowItemsPage extends StatefulWidget {
  const BorrowItemsPage({Key? key}) : super(key: key);

  @override
  _BorrowItemsPageState createState() => _BorrowItemsPageState();
}

class _BorrowItemsPageState extends State<BorrowItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            title: Text(
              'borrow_items'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            elevation: 0,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.onPrimary,
              labelColor: colorScheme.onPrimary, // Warna teks tab aktif
              unselectedLabelColor: colorScheme.onPrimary.withValues(
                alpha: 0.7,
              ), // Warna teks tab tidak aktif
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ), // Gaya teks tab aktif
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
              ), // Gaya teks tab tidak aktif
              tabs: [
                Tab(text: 'available_items'.tr()),
                Tab(text: 'borrowed_items'.tr()),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAvailableItemsList(colorScheme),
              _buildBorrowedItemsList(colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailableItemsList(ColorScheme colorScheme) {
    // Placeholder for available items list
    return ListView.builder(
      itemCount: 10, // Replace with actual item count
      itemBuilder: (context, index) {
        return _buildItemCard(
          colorScheme,
          'Item ${index + 1}',
          'Description for Item ${index + 1}',
          Icons.inventory_2,
          () {
            // Handle borrow action
          },
        );
      },
    );
  }

  Widget _buildBorrowedItemsList(ColorScheme colorScheme) {
    // Placeholder for borrowed items list
    return ListView.builder(
      itemCount: 5, // Replace with actual borrowed item count
      itemBuilder: (context, index) {
        return _buildItemCard(
          colorScheme,
          'Borrowed Item ${index + 1}',
          'Due date: ${DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: index + 1)))}',
          Icons.assignment_return,
          () {
            // Handle return action
          },
        );
      },
    );
  }

  Widget _buildItemCard(
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(icon, color: colorScheme.primary, size: 40),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: Text(
            _tabController.index == 0 ? 'borrow'.tr() : 'return'.tr(),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: colorScheme.onPrimary,
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
