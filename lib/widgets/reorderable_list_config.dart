import 'package:flutter/material.dart';

/// Configuration class for CustomDraggableList
/// Contains all customizable settings for the reorderable list
class ReorderableListConfig {
  // Insert indicator settings
  final Color insertIndicatorColor;
  final double insertIndicatorHeight;
  
  // Feedback widget settings
  final double feedbackScale;
  final double feedbackOpacity;
  final double feedbackMaxWidth;
  final double feedbackMaxHeight;
  
  // Main widget selection settings
  final double selectedWidgetScale;
  final double selectedWidgetOpacity;
  
  // Auto-scroll settings
  final double autoScrollZone;
  final double maxScrollSpeed;
  
  // Animation settings
  final Duration animationDuration;
  final Duration autoScrollDuration;
  
  const ReorderableListConfig({
    // Insert indicator defaults
    this.insertIndicatorColor = Colors.purple,
    this.insertIndicatorHeight = 6.0,
    
    // Feedback widget defaults
    this.feedbackScale = 0.7,
    this.feedbackOpacity = 0.9,
    this.feedbackMaxWidth = 300.0,
    this.feedbackMaxHeight = 400.0,
    
    // Main widget selection defaults
    this.selectedWidgetScale = 0.95,
    this.selectedWidgetOpacity = 0.7,
    
    // Auto-scroll defaults
    this.autoScrollZone = 100.0,
    this.maxScrollSpeed = 15.0,
    
    // Animation defaults
    this.animationDuration = const Duration(milliseconds: 200),
    this.autoScrollDuration = const Duration(milliseconds: 16),
  });
  
  /// Copy with method for creating modified configurations
  ReorderableListConfig copyWith({
    Color? insertIndicatorColor,
    double? insertIndicatorHeight,
    double? feedbackScale,
    double? feedbackOpacity,
    double? feedbackMaxWidth,
    double? feedbackMaxHeight,
    double? selectedWidgetScale,
    double? selectedWidgetOpacity,
    double? autoScrollZone,
    double? maxScrollSpeed,
    Duration? animationDuration,
    Duration? autoScrollDuration,
  }) {
    return ReorderableListConfig(
      insertIndicatorColor: insertIndicatorColor ?? this.insertIndicatorColor,
      insertIndicatorHeight: insertIndicatorHeight ?? this.insertIndicatorHeight,
      feedbackScale: feedbackScale ?? this.feedbackScale,
      feedbackOpacity: feedbackOpacity ?? this.feedbackOpacity,
      feedbackMaxWidth: feedbackMaxWidth ?? this.feedbackMaxWidth,
      feedbackMaxHeight: feedbackMaxHeight ?? this.feedbackMaxHeight,
      selectedWidgetScale: selectedWidgetScale ?? this.selectedWidgetScale,
      selectedWidgetOpacity: selectedWidgetOpacity ?? this.selectedWidgetOpacity,
      autoScrollZone: autoScrollZone ?? this.autoScrollZone,
      maxScrollSpeed: maxScrollSpeed ?? this.maxScrollSpeed,
      animationDuration: animationDuration ?? this.animationDuration,
      autoScrollDuration: autoScrollDuration ?? this.autoScrollDuration,
    );
  }
}
