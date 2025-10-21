import 'package:flutter/material.dart';
import 'package:widmate/app/src/responsive/responsive_utils.dart';

/// A wrapper widget that provides different layouts based on screen size
class ResponsiveWrapper extends StatelessWidget {
  /// Widget to display on mobile devices
  final Widget mobile;
  
  /// Widget to display on tablet devices (optional)
  final Widget? tablet;
  
  /// Widget to display on desktop devices (optional)
  final Widget? desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveUtils.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A responsive scaffold that adapts to different screen sizes
class ResponsiveScaffold extends StatelessWidget {
  /// The app bar to display at the top of the scaffold
  final PreferredSizeWidget? appBar;
  
  /// The primary content of the scaffold
  final Widget body;
  
  /// A bottom navigation bar to display at the bottom of the scaffold
  final Widget? bottomNavigationBar;
  
  /// A drawer to display on the side of the scaffold
  final Widget? drawer;
  
  /// A floating action button to display on the scaffold
  final Widget? floatingActionButton;
  
  /// The position of the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  
  /// The background color of the scaffold
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // For desktop, we use a different layout with a side drawer always visible
    if (ResponsiveUtils.isDesktop(context)) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            if (drawer != null)
              SizedBox(
                width: 250,
                child: drawer!,
              ),
            Expanded(
              child: Scaffold(
                appBar: null, // No app bar in the inner scaffold
                body: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  child: body,
                ),
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
      );
    }
    
    // For mobile and tablet, we use the standard scaffold
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: body,
      ),
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
    );
  }
}

/// A responsive grid that adapts to different screen sizes
class ResponsiveGrid extends StatelessWidget {
  /// The list of items to display in the grid
  final List<Widget> children;
  
  /// The spacing between items
  final double spacing;
  
  /// The number of columns on mobile devices
  final int mobileColumns;
  
  /// The number of columns on tablet devices
  final int tabletColumns;
  
  /// The number of columns on desktop devices
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        
        if (constraints.maxWidth >= ResponsiveUtils.desktopBreakpoint) {
          crossAxisCount = desktopColumns;
        } else if (constraints.maxWidth >= ResponsiveUtils.tabletBreakpoint) {
          crossAxisCount = tabletColumns;
        } else {
          crossAxisCount = mobileColumns;
        }
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}