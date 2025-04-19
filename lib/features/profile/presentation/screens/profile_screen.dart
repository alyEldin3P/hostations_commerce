import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/config/env_config.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_state.dart';
import 'package:hostations_commerce/features/address/presentation/cubits/address_cubit.dart';
import 'package:hostations_commerce/features/address/presentation/screens/address_list_screen.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:hostations_commerce/features/language/presentation/screens/language_selection_screen.dart';
import 'package:hostations_commerce/features/settings/presentation/screens/settings_screen.dart';
import 'package:hostations_commerce/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:hostations_commerce/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Gradient background with blur overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0e7ff), Color(0xFFf8fafc)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Main content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Section
              _GlassSectionLabel(label: 'Account'),
              _GlassSectionCard(child: _buildProfileOptions(context)),
              // Settings Section
              _GlassSectionLabel(label: 'Settings'),
              _GlassSectionCard(child: _buildSettingsOptions(context)),
              // About Section
              _GlassSectionLabel(label: 'About'),
              _GlassSectionCard(child: _buildAboutOptions(context)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            _ProfileListTile(
              icon: Icons.login,
              title: 'Login',
              onTap: () {
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
              visible: state.isGuest,
            ),
            _ProfileListTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                context.read<AuthCubit>().signOut();
              },
              visible: !state.isGuest,
            ),
            _ProfileListTile(
              icon: Icons.favorite,
              title: 'Wishlist',
              onTap: () {
                Navigator.pushNamed(context, WishlistScreen.routeName);
              },
              visible: state.isGuest,
            ),
            _ProfileListTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                Navigator.pushNamed(context, NotificationsScreen.routeName);
              },
              visible: !state.isGuest,
            ),
            //my orders
            _ProfileListTile(
              icon: Icons.shopping_bag,
              title: 'My Orders',
              onTap: () {
                // Navigate to orders screen
                DependencyInjector().snackBarService.showInfo('Orders coming soon');
              },
              visible: !state.isGuest,
            ),
            // my addresess
            _ProfileListTile(
              icon: Icons.location_on,
              title: 'My Addresses',
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddressListScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Column(
      children: [
        _ProfileListTile(
          icon: Icons.language,
          title: 'Select Language',
          onTap: () {
            // TODO: Implement language selection screen
            Navigator.pushNamed(context, LanguageSelectionScreen.routeName);
          },
        ),
        _ProfileListTile(
          icon: Icons.brightness_4,
          title: 'Theme',
          onTap: () {
            Navigator.pushNamed(context, ThemeScreen.routeName);
          },
        ),
        _ProfileListTile(
          icon: Icons.star,
          title: 'Rate the App',
          onTap: () {
            // TODO: Implement rate app functionality
            DependencyInjector().snackBarService.showInfo('Rate the app coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildAboutOptions(BuildContext context) {
    return Column(
      children: [
        _ProfileListTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            _launchUrl(EnvConfig().privacyPolicyUrl);
          },
        ),
        _ProfileListTile(
          icon: Icons.description,
          title: 'Terms & Conditions',
          onTap: () {
            _launchUrl(EnvConfig().termsOfServiceUrl);
          },
        ),
        _ProfileListTile(
          icon: Icons.info,
          title: 'About Us',
          onTap: () {
            _launchUrl(EnvConfig().aboutUsUrl);
          },
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      DependencyInjector().snackBarService.showError('Could not open $url');
    }
  }
}

// Glassmorphic card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Gradient gradient;
  final double borderRadius;
  final double elevation;

  const GlassCard({
    required this.child,
    this.blur = 20,
    this.gradient = const LinearGradient(colors: [Colors.white24, Colors.white10]),
    this.borderRadius = 20,
    this.elevation = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              if (elevation > 0)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation * 2,
                  offset: const Offset(0, 6),
                ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.13), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Section label with accent
class _GlassSectionLabel extends StatelessWidget {
  final String label;
  const _GlassSectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 10, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.primaryColor.withOpacity(0.7),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

// Glass card for section
class _GlassSectionCard extends StatelessWidget {
  final Widget child;
  const _GlassSectionCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassCard(
        blur: 16,
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0.09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: 22,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: child,
        ),
      ),
    );
  }
}

// Animated glass tile for profile options
class _ProfileListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool visible;
  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.visible = true,
    Key? key,
  }) : super(key: key);
  @override
  State<_ProfileListTile> createState() => _ProfileListTileState();
}

class _ProfileListTileState extends State<_ProfileListTile> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [theme.primaryColor.withOpacity(0.23), theme.primaryColorLight.withOpacity(0.15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.13),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: theme.primaryColor, size: 23),
              ),
              const SizedBox(width: 19),
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.ease,
                transform: Matrix4.translationValues(_scale < 1 ? 6 : 0, 0, 0),
                child: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color?.withOpacity(0.22), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
