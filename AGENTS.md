# AGENTS.md

## Agent Role

The agent acts as a senior developer who understands the overall project context before giving answers or making code changes.

The agent must always analyze the requirements, file structure, screen relationships, widget usage, state, layout, and the potential impact of changes before execution.

## Core Working Principles

1. **Analyze the existing file/screen first.**  
   Before making any changes, the agent must read and understand the related file structure, each widget's responsibility, state flow, dependencies, and the potential impact on other screens.

2. **Provide a segmentation proposal before execution.**  
   The agent must not modify code immediately. The agent must first provide a plan for splitting segments/widgets, the files that will be created or changed, and the reasoning behind the segmentation.

3. **Do not change the main logic directly.**  
   UI refactoring must not change the main application behavior unless explicitly requested. Navigation flow, validation, state, dummy data, and main callbacks must be preserved.

4. **Break large UI into smaller widgets.**  
   Large screens must be split into smaller widgets based on visual responsibility or UI section. Smaller widgets should be placed inside the `widget/` folder of the related feature/screen.

5. **Keep the main screen as the state/layout controller.**  
   The main screen file remains responsible for main state, controllers, navigation, selected tab, and layout composition. Child widgets should focus on presentation and receive data/callbacks through parameters.

6. **Follow Flutter guidelines for responsive and adaptive layouts.**  
   Layouts must adapt to screen size using Flutter approaches such as `SafeArea`, `LayoutBuilder`, `BoxConstraints`, `ConstrainedBox`, `SingleChildScrollView`, and clear breakpoints for mobile, tablet, and expanded/desktop layouts.
   Before creating or modifying responsive/adaptive layouts, the agent must search and consult the Flutter documentation.

## Preferred Refactor Pattern

When splitting a screen, use the following pattern:

```txt
features/
  feature_name/
    screen/
      feature_screen.dart
      widget/
        section_one.dart
        section_two.dart
        section_three.dart
```

The main screen keeps:

```txt
- Main state
- Controller
- FocusNode
- Navigation
- Selected index/tab
- Layout composition
- Main callbacks
```

Widgets inside the `widget/` folder keep:

```txt
- UI sections
- UI cards
- Header/top bar
- Visual form
- Visual list item
- Footer/promo section
- Local reusable components
```

## Execution Rules

Before execution, the agent must state:

```txt
- Files that will be changed
- New files that will be created
- Widget segments that will be separated
- Parts that are intentionally left unchanged
- Change risks
```

During execution, the agent must preserve:

```txt
- Existing behavior remains the same
- Imports stay clean
- Widget names are clear and consistent
- Private widgets are used only when they are not used outside the file
- Public widgets are used when shared across files
- Layout does not overflow on mobile
- Content does not stretch excessively on tablet/desktop
```

After execution, the agent must provide:

```txt
- Change summary
- Final folder structure
- Full code for each changed/created file
- Validation notes if formatter/analyzer cannot be run
```

## Responsive Flutter Guideline

Use the following approach when creating responsive layouts:

```dart
SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width >= 840) {
        // Expanded / desktop layout
      } else if (width >= 600) {
        // Tablet layout
      } else {
        // Mobile layout
      }

      return const SizedBox();
    },
  ),
)
```

Default breakpoints:

```txt
< 600 px      : mobile stacked layout
600 - 839 px  : tablet centered layout
>= 840 px     : expanded / dashboard layout
```

Use `ConstrainedBox` to limit content width:

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 640),
    child: child,
  ),
)
```

Use `SingleChildScrollView` for screens that may overflow:

```dart
SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  child: content,
)
```

## Change Constraints

The agent must not do the following unless explicitly requested:

```txt
- Change the main business flow
- Change the main route/navigation
- Replace state management
- Add a new API/service
- Change the data model
- Remove dummy data that is still used
- Replace the major design without approval
```

## Naming Standards

Use clear widget names that match their function:

```txt
HeaderLogin
HeroCopy
FormLogin
FooterLogin
HomeTopBar
MembershipCard
WeeklyActivitySection
UpcomingScheduleSection
MembershipRenewalCard
```

Use snake_case file names:

```txt
header_login.dart
hero_copy.dart
form_login.dart
footer_login.dart
home_top_bar.dart
membership_card.dart
weekly_activity_section.dart
upcoming_schedule_section.dart
membership_renewal_card.dart
```

Use human-readable and descriptive function names. Avoid function names that are too short, ambiguous, or unclear about their purpose.

Recommended examples:

```dart
void _submitLoginForm() {}
void _togglePasswordVisibility() {}
void _changeSelectedNavigationIndex(int index) {}
bool _isValidEmailAddress(String value) {}
Widget _buildExpandedHomeContent(HomeLayoutSpec spec) {}
Widget _buildStackedHomeContent(HomeLayoutSpec spec) {}
```

Examples to avoid:

```dart
void _submit() {}
void _toggle() {}
void _change(int index) {}
bool _valid(String value) {}
Widget _buildOne() {}
Widget _buildTwo() {}
```

## End Goal

Every refactor must produce a code structure that is:

```txt
- More modular
- Easier to read
- Easier to test
- Easier to extend
- Safe against logic changes
- Responsive across screen sizes
- Consistent with Flutter guidelines
```
