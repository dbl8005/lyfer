# Contribution Guidelines for Lyfer Project

Thank you for contributing to the Lyfer project! To ensure consistency and maintainability, please follow these guidelines when working on the project.

## 1. **Coding Principles**

### **KISS (Keep It Simple, Stupid)**
- Write clean, simple, and readable code.
- Avoid over-engineering or adding unnecessary complexity.
- Use meaningful variable and function names.

### **DRY (Don't Repeat Yourself)**
- Reuse existing components, widgets, and helper functions.
- Extract reusable logic into utility functions or shared components.

### **SOLID Principles**
- Follow object-oriented design principles (e.g., Single Responsibility Principle).
- Keep widgets and classes focused on a single purpose.

### **Documentation**
- Document all public classes, methods, and functions.
- Use Dart's documentation comments (`///`) for public APIs.
- Include examples where applicable.

## 2. **Code Style**

### **Flutter/Dart Standards**
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- Use `dart format` to format your code before committing.

### **Widget Structure**
- Break down large widgets into smaller, reusable components.
- Use `StatelessWidget` unless state management is required.

### **State Management**
- Use `Riverpod` for state management across the project.
- Avoid mixing stateful logic with UI components.

## 3. **Project-Specific Guidelines**

### **Snackbar Usage**
- Use `AppSnackbar` for all snackbars.
- Ensure snackbars do not overlap floating action buttons (FABs).
- Use `showSuccess`, `showError`, or `showWarning` methods for consistency.

### **Calendar Behavior**
- The calendar should:
    - Show only the current month.
    - Disable format changes (e.g., 2-week view).
    - Use long-press to toggle habit completion.

### **Statistics**
- Use `_StatCard` for displaying statistics.
- Ensure progress bars and icons are styled consistently with the app theme.

## 4. **Folder Structure**

### **Organize Code by Feature**
- Follow the `features` folder structure:
    ```
    lib/
        features/
            habits/
                models/
                services/
                presentation/
                    widgets/
                        detail_widgets/
            notes/
                models/
                services/
                presentation/
    ```

### **Shared Components**
- Place reusable components in `core/utils` or `core/widgets`.

## 5. **Testing**

### **Unit Tests**
- Write unit tests for all services and utility functions.
- Place tests in the test folder, mirroring the structure of lib.

### **Widget Tests**
- Write widget tests for complex UI components.
- Ensure tests cover edge cases and user interactions.

### **Integration Tests**
- Write integration tests for critical user flows.
- Test app behavior across different screen sizes and orientations.

## 6. **Git Commit Guidelines**

### **Commit Messages**
- Use clear and descriptive commit messages.
- Follow this format:
    ```
    [Feature] Add habit calendar with long-press toggle
    [Fix] Resolve snackbar overlap with FAB
    [Refactor] Extract reusable StatCard widget
    ```

### **Branch Naming**
- Use feature-specific branch names:
    ```
    feature/habit-calendar
    fix/snackbar-overlap
    refactor/stat-card
    ```

## 7. **Pull Requests**

### **Checklist Before Submitting**
- Ensure your code is formatted (`dart format`).
- Run all tests and ensure they pass (`flutter test`).
- Add comments and documentation for all public methods and classes.
- Verify your changes work on both Android and iOS.

### **Pull Request Description**
- Include a summary of changes and the purpose of the PR.
- Mention any related issues or tasks.
- Add screenshots for UI changes.

## 8. **Performance Considerations**

### **Resource Optimization**
- Optimize images and assets before adding them to the project.
- Avoid expensive computations in the build method.
- Use const constructors when possible.

### **Memory Management**
- Dispose controllers and streams appropriately.
- Be cautious of memory leaks, especially with animation controllers.

By following these guidelines, we can ensure a consistent and maintainable codebase. Thank you for contributing!
