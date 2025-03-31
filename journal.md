Auth                                                  
Currently have:
1. working login
2. working register
3. manual redirect to home
4. improve redirect logic to redirect base on auth status, and check if user can register
5. impl email verification
6. implement google signin.
7. working toggle obscure text for passwords


To do list:
* impl forgot password
* improve ui

                                            - Habits -
I have:
* habits page with chronological sections and auto-scroll to current section
* create habit with comprehensive options
* edit habit functionality
* category-based habit organization
* specific day selection for better habit scheduling
* priority settings for habits
* reminder configuration
* note taking for habits
* organized widget structure with better component separation
* improved accessibility with semantic labels
* better error handling with retry functionality

I need to make:
* home page, with tabs for habits, tasks, settings.
* habit dashboard improvements
* implement notification system for reminders
* better error handling and offline support
    
# Habits Feature Summary

## Core Functionality

The habits feature provides a comprehensive habit tracking system in your Flutter app with the following functionality:

1. **Habit Display**
   - `HabitsScreen` organizes habits by time of day (morning, afternoon, evening, night, all day)
   - The current time section is highlighted and auto-scrolled to on load
   - Each habit displays a `HabitTile` with relevant information including category icon, name, and status

2. **Habit Management**
   - Create new habits via `NewHabitScreen`
   - Edit existing habits via `EditHabitScreen`
   - Configure properties: name, category, color, description, time of day, frequency, priority
   - Support for frequency types: daily, weekly, monthly, custom
   - Set completion targets (e.g., 3 times per week)
   - Select specific days of the week for habit completion

3. **Habit Tracking**
   - Mark habits as completed for the day
   - Track completion streaks via `StreakCalculator`
   - Visual progress indicator for period goals
   - Streak tracking based on time period (daily/weekly/monthly)
   - Smart day selection ensures habits are only checked for scheduled days

4. **Data Management**
   - `HabitService` handles CRUD operations using Firebase
   - Stream-based updates for real-time data

5. **Streaks Logic**
   - Daily: Streak based on consecutive days
   - Weekly: Streak based on meeting weekly completion target (e.g., 3 times per week)
   - Monthly: Streak based on meeting monthly completion target

6. **Categorization and Priority**
   - Habits organized by categories with appropriate icons
   - Priority levels affect visual display and can be used for sorting
   - Customizable color schemes for each habit

7. **Notes System**
   - Create and manage notes for each habit
   - Notes feature titles, content, tags, and color-coding

## Recent Improvements

1. **UI Organization and Navigation**
   - Fixed routing issues for the note screen
   - Improved habit details screen
   - Implemented chronological ordering of sections with auto-scroll to current time period
   - Extracted reusable components (DayNavigator, HabitSection, SectionHeader)
   - Organized widget folder into logical categories (display, navigation, form, etc.)

2. **Enhanced Habit Configuration**
   - Added day selector for specific weekday scheduling
   - Replaced icon selection with category-based system
   - Implemented priority selection with visual indicators
   - Added comprehensive reminder system with time options

3. **Data Model Updates**
   - Expanded HabitModel to include selectedDays, priority, and reminder settings
   - Added proper serialization/deserialization for new fields
   - Improved handling of category data

4. **Better Component Reusability**
   - Created reusable widgets like DaySelector, CategorySelector, and PrioritySelector
   - Improved consistency between screens for habit creation and editing
   - Extracted common UI patterns into dedicated widget files
   - Created proper widget index files for cleaner imports

5. **Architecture Improvements**
   - Separated UI from state management with dedicated provider files
   - Added proper type safety with enum usage for habit properties
   - Extracted constants to dedicated constants file
   - Improved accessibility with semantic labels and screen reader support
   - Enhanced error handling with dedicated error display components

## Planned Improvements

1. **UI/UX Refinements**
   - Add animations for habit completion actions (completion confetti, streak celebration)
   - Implement calendar/history view for habits with month/week visualization
   - Enhance statistics display with charts and insights (completion rate, streak history)
   - Add theme support with dark/light mode transitions for all habit components
   - Implement responsive layouts for tablet support

2. **Feature Gaps to Fill**
   - Implement notification scheduling for reminders with exact alarm support
   - Add habit archiving UI and functionality with archive/restore flows
   - Implement target days tracking with visual countdown and completion forecasting
   - Add bulk actions for habits (delete multiple, change category of multiple)
   - Create habit templates for quick habit creation

3. **Technical Improvements**
   - Add proper error handling with fallback UI and error boundary widgets
   - Implement offline support with local caching and sync resolution
   - Optimize Firebase queries with indexing and pagination
   - Add comprehensive unit and widget tests for all habit components
   - Implement performance monitoring for list rendering and state updates
   - Add proper logging for debugging and analytics

4. **Advanced Features**
   - Expand category management with custom categories and category reordering
   - Add habit suggestions based on user patterns and completion history
   - Implement habit sharing or social challenges with friend invites
   - Add data export/import functionality with CSV/JSON options
   - Create habit insights system with AI-powered suggestions
   - Implement gamification elements (streaks, achievements, milestones)

The habit feature has evolved significantly with better component organization, scheduling options, categorization, priority handling, and UI improvements. The next phase will focus on implementing the actual notifications system, enhancing visualization, adding robust error handling, and improving code organization for better maintainability and testability.