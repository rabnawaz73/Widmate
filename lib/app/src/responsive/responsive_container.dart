import 'package:flutter/material.dart';
import 'package:widmate/app/src/responsive/responsive_utils.dart';

/// A responsive container that adapts its width, padding, and styling based on screen size
class ResponsiveContainer extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// Optional maximum width constraint
  final double? maxWidth;
  
  /// Optional minimum height constraint
  final double? minHeight;
  
  /// Optional padding inside the container
  final EdgeInsetsGeometry? padding;
  
  /// Optional margin around the container
  final EdgeInsetsGeometry? margin;
  
  /// Optional background color
  final Color? backgroundColor;
  
  /// Optional border radius
  final BorderRadius? borderRadius;
  
  /// Optional elevation for shadow
  final double? elevation;
  
  /// Whether to use a card-like appearance
  final bool useCard;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.minHeight,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.useCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final effectiveMaxWidth = maxWidth ?? 
        (ResponsiveUtils.isDesktop(context) ? 1200.0 : 
         ResponsiveUtils.isTablet(context) ? 700.0 : double.infinity);
    
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(ResponsiveUtils.isMobile(context) ? 8.0 : 12.0);
    
    final effectiveElevation = elevation ?? (useCard ? 1.0 : 0.0);
    
    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );
    
    if (useCard) {
      content = Card(
        elevation: effectiveElevation,
        shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        color: backgroundColor ?? theme.colorScheme.surface,
        margin: margin ?? EdgeInsets.zero,
        child: content,
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: effectiveBorderRadius,
          boxShadow: effectiveElevation > 0 ? [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: effectiveElevation * 3,
              offset: Offset(0, effectiveElevation),
            ),
          ] : null,
        ),
        margin: margin,
        child: content,
      );
    }
    
    if (effectiveMaxWidth < double.infinity || minHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: effectiveMaxWidth,
          minHeight: minHeight ?? 0.0,
        ),
        child: content,
      );
    }
    
    // Center on larger screens if max width is constrained
    if (effectiveMaxWidth < double.infinity && 
        (ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context))) {
      content = Center(child: content);
    }
    
    return content;
  }
}

/// A responsive section container with a title and optional icon
class ResponsiveSection extends StatelessWidget {
  /// The section title
  final String title;
  
  /// Optional section icon
  final IconData? icon;
  
  /// The section content
  final Widget child;
  
  /// Optional padding inside the section
  final EdgeInsetsGeometry? padding;
  
  /// Optional margin around the section
  final EdgeInsetsGeometry? margin;
  
  /// Whether to use a card-like appearance
  final bool useCard;

  const ResponsiveSection({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.padding,
    this.margin,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isMobile(context) ? 16.0 : 24.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              if (icon != null) ...[  
                Icon(icon, 
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.getResponsiveIconSize(context),
                ),
                SizedBox(width: ResponsiveUtils.isMobile(context) ? 8.0 : 12.0),
              ],
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Section content
        ResponsiveContainer(
          useCard: useCard,
          padding: padding,
          margin: margin ?? EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isMobile(context) ? 16.0 : 24.0,
            vertical: 8.0,
          ),
          child: child,
        ),
      ],
    );
  }
}