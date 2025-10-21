import 'package:flutter/material.dart';
import 'package:widmate/app/src/responsive/responsive_utils.dart';

/// A responsive grid layout that adapts to different screen sizes
class ResponsiveGrid extends StatelessWidget {
  /// The list of items to display in the grid
  final List<Widget> children;
  
  /// The spacing between items
  final double spacing;
  
  /// Optional minimum item width to control grid density
  final double? minItemWidth;
  
  /// Optional maximum number of columns
  final int? maxColumns;
  
  /// Optional aspect ratio for items
  final double? childAspectRatio;
  
  /// Optional padding around the grid
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.minItemWidth,
    this.maxColumns,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on available width
        int columns;
        
        if (maxColumns != null) {
          // If maxColumns is specified, use responsive columns up to that maximum
          columns = ResponsiveUtils.getResponsiveGridColumns(context);
          columns = columns > (maxColumns ?? 3) ? maxColumns! : columns;
        } else if (minItemWidth != null && minItemWidth! > 0) {
          // Calculate columns based on minimum item width
          columns = (constraints.maxWidth / (minItemWidth ?? 150)).floor();
          columns = columns < 1 ? 1 : columns;
        } else {
          // Default responsive columns
          columns = ResponsiveUtils.getResponsiveGridColumns(context);
        }
        
        // Use GridView with calculated columns
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio ?? 1.0,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// A responsive list that adapts its padding and spacing based on screen size
class ResponsiveList extends StatelessWidget {
  /// The list of items to display
  final List<Widget> children;
  
  /// Optional spacing between items
  final double? spacing;
  
  /// Optional padding around the list
  final EdgeInsetsGeometry? padding;
  
  /// Whether to use a ListView (true) or Column (false)
  final bool scrollable;

  const ResponsiveList({
    super.key,
    required this.children,
    this.spacing,
    this.padding,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? 
        (ResponsiveUtils.isMobile(context) ? 8.0 : 
         ResponsiveUtils.isTablet(context) ? 12.0 : 16.0);
    
    final effectivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    final childrenWithSpacing = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      childrenWithSpacing.add(children[i]);
      if (i < children.length - 1) {
        childrenWithSpacing.add(SizedBox(height: effectiveSpacing));
      }
    }
    
    if (scrollable) {
      return ListView(
        padding: effectivePadding,
        children: childrenWithSpacing,
      );
    } else {
      return Padding(
        padding: effectivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: childrenWithSpacing,
        ),
      );
    }
  }
}