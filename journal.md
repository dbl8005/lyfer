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

## Planned Improvements

1. **UI/UX Refinements**
   - Add animations for habit completion actions
   - Implement calendar/history view for habits
   - Enhance statistics display with charts and insights

2. **Feature Gaps to Fill**
   - Implement notification scheduling for reminders
   - Add habit archiving UI and functionality
   - Implement target days tracking with visual countdown

3. **Technical Improvements**
   - Add proper error handling with fallback UI
   - Implement offline support with local caching
   - Optimize Firebase queries with indexing
   - Add unit and widget tests

4. **Advanced Features**
   - Expand category management with custom categories
   - Add habit suggestions based on user patterns
   - Implement habit sharing or social challenges
   - Add data export/import functionality

The habit feature has evolved significantly with better scheduling options, categorization, priority handling, and UI improvements. The next phase will focus on implementing the actual notifications system, enhancing visualization, and adding more robust error handling.