import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/business_logo.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.width < 760;

    return LayoutView(
      headerTitle: 'Business Profile',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLight.withValues(alpha: 0.7),
                const Color(0xFFF6FAFE),
                const Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: GetBuilder<SettingsController>(
            builder: (controller) => ListView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 16 : 24,
                isCompact ? 16 : 22,
                isCompact ? 16 : 24,
                isCompact ? 24 : 28,
              ),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      children: [
                        // _ProfileHero(
                        //   controller: controller,
                        //   isCompact: isCompact,
                        // ),
                        // const SizedBox(height: 22),
                        _BusinessProfilePanel(
                          controller: controller,
                          isCompact: isCompact,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final content = isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeading(controller: controller, isCompact: true),
              const SizedBox(height: 18),
              _HeroMetaRow(controller: controller, isCompact: true),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _HeroHeading(controller: controller, isCompact: false),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: _HeroMetaRow(controller: controller, isCompact: false),
              ),
            ],
          );

    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            AppColors.primaryLight.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: const Color(0xFFE3ECF5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -26,
            right: -10,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -34,
            left: -12,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _HeroHeading extends StatelessWidget {
  const _HeroHeading({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isCompact ? 58 : 64,
          height: isCompact ? 58 : 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDE8F3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.apartment_rounded,
            color: AppColors.primary,
            size: isCompact ? 26 : 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Profile',
                style: TextStyle(
                  fontSize: isCompact ? 24 : 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your business information, brand identity and contact details in one clear place.',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroChip(
                    icon: Icons.store_mall_directory_outlined,
                    label: controller.businessName,
                  ),
                  _HeroChip(
                    icon: Icons.palette_outlined,
                    label: controller.primaryColorCode,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroMetaRow extends StatelessWidget {
  const _HeroMetaRow({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaStatCard(
            title: 'FSSAI',
            value: controller.maskedFssaiNumber,
            icon: Icons.verified_user_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetaStatCard(
            title: 'Phone',
            value: controller.phoneNumber,
            icon: Icons.phone_outlined,
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _MetaStatCard(
              title: 'WhatsApp',
              value: controller.whatsappNumber,
              icon: Icons.chat_bubble_outline_rounded,
            ),
          ),
        ],
      ],
    );
  }
}

class _BusinessProfilePanel extends StatelessWidget {
  const _BusinessProfilePanel({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE4ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitleRow(
            title: 'Business Profile Snapshot',
            // subtitle: 'A polished app view of your core website business profile details.',
          ),
          const SizedBox(height: 22),
          _ProfileBanner(controller: controller, isCompact: isCompact),
          const SizedBox(height: 22),
          _ProfileSectionCard(
            title: 'Business Details',
            icon: Icons.badge_outlined,
            child: _ResponsiveFieldGrid(
              isCompact: isCompact,
              children: [
                _InfoCard(
                  icon: Icons.storefront_outlined,
                  label: 'Business Name',
                  value: controller.businessName,
                ),
                _InfoCard(
                  icon: Icons.verified_user_outlined,
                  label: 'FSSAI Number',
                  value: controller.maskedFssaiNumber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ProfileSectionCard(
            title: 'Brand Identity',
            icon: Icons.palette_outlined,
            child:
                _BrandColorPanel(controller: controller, isCompact: isCompact),
          ),
          const SizedBox(height: 18),
          _ProfileSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_phone_outlined,
            child: _ResponsiveFieldGrid(
              isCompact: isCompact,
              children: [
                _InfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: controller.phoneNumber,
                ),
                _InfoCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'WhatsApp Number',
                  value: controller.whatsappNumber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ProfileSectionCard(
            title: 'Address',
            icon: Icons.location_on_outlined,
            child: _InfoCard(
              icon: Icons.pin_drop_outlined,
              label: 'Godown / Office Address',
              value: controller.address,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitleRow extends StatelessWidget {
  const _PanelTitleRow({
    required this.title,
    // required this.subtitle,
  });

  final String title;
  // final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        // const SizedBox(height: 6),
        // Text(
        //   subtitle,
        //   style: const TextStyle(
        //     fontSize: 14,
        //     height: 1.5,
        //     color: AppColors.textSecondary,
        //   ),
        // ),
      ],
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final logoCard = Container(
      width: isCompact ? 92 : 108,
      height: isCompact ? 92 : 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EBF3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BusinessLogo(
        logoUrl: controller.logoUrl,
        height: isCompact ? 58 : 70,
        width: isCompact ? 58 : 70,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.businessName,
          style: TextStyle(
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        // const SizedBox(height: 8),
        // const Text(
        //   'This profile card mirrors your website business profile in a cleaner app-first layout with better readability on both mobile and larger screens.',
        //   style: TextStyle(
        //     fontSize: 13,
        //     height: 1.6,
        //     color: AppColors.textSecondary,
        //   ),
        // ),
        // const SizedBox(height: 14),
        // Wrap(
        //   spacing: 10,
        //   runSpacing: 10,
        //   children: [
        //     const _SoftBadge(
        //       icon: Icons.verified_outlined,
        //       label: 'Verified branding',
        //     ),
        //     _SoftBadge(
        //       icon: Icons.color_lens_outlined,
        //       label: controller.primaryColorCode,
        //     ),
        //   ],
        // ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9FBFE),
            AppColors.primaryLight.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logoCard,
                const SizedBox(height: 16),
                content,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logoCard,
                const SizedBox(width: 18),
                Expanded(child: content),
              ],
            ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BrandColorPanel extends StatelessWidget {
  const _BrandColorPanel({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          icon: Icons.water_drop_outlined,
          label: 'Brand Color Code',
          value: controller.primaryColorCode,
          isFullWidth: true,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 18 : 12,
            vertical: isCompact ? 12 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                controller.primaryColor.withValues(alpha: 0.92),
                controller.primaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: controller.primaryColor.withValues(alpha: 0.26),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.primaryColorCode,
                style: TextStyle(
                  fontSize: isCompact ? 26 : 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({
    required this.isCompact,
    required this.children,
  });

  final bool isCompact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isCompact ? 12.0 : 14.0;
        final childWidth = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: childWidth, child: child),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDF4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (label.toUpperCase() != 'GODOWN / OFFICE ADDRESS')
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7685),
                      letterSpacing: 1.1,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isFullWidth ? 16 : 17,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDE8F2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaStatCard extends StatelessWidget {
  const _MetaStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E7A89),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
