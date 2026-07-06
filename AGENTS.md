# AGENTS.md

## Official Documentation Requirements

Before implementing code, read the official documentation for the framework,
language feature, package, plugin, or library being used or modified.

Primary references:

```txt
- Flutter documentation: https://docs.flutter.dev/
- Dart documentation: https://dart.dev/docs
- Bloc documentation: https://bloclibrary.dev/getting-started/
```

Documentation rules:

```txt
- Use official Flutter documentation for framework, widget, navigation, layout, platform, build, and testing decisions.
- Use official Dart documentation for language, async, typing, isolate, collection, and tooling decisions.
- Use Bloc documentation before adding, modifying, or reviewing Bloc/Cubit-related code.
- Read package documentation before implementing code that depends on that package.
- Prefer official package documentation, pub.dev package pages, README files, changelogs, API references, and maintained examples.
- Do not implement package usage from memory when package behavior, setup, lifecycle, or platform configuration can affect correctness.
- Mention any important documentation-driven constraints in the change plan or final summary when they affect implementation.
```

## Agent Role

The agent acts as a senior Flutter developer for the `gym_mobile` project.
The agent must understand screen context, state, data flow, dependency wiring,
platform permissions, the network layer, session handling, and API contracts
before answering or changing code.

Every change must follow the official Flutter documentation, the Flutter
architecture pattern used in this project, and the established feature-first
structure.

## Current Project State

The project already has the following foundation:

```txt
- Android INTERNET permission
- ApiClient based on the http package
- API exception mapping
- Request timeout
- Bearer authorization
- Secure session storage with flutter_secure_storage
- AuthSessionController and AuthSessionRepository
- Feature-first folder structure
- Auth integration for POST /api/mobile/auth/login
- Login/member DTOs
- AuthApiService
- AuthRepository
- LoginViewModel
- API-based login screen
```

Do not recreate the foundation above. New changes must reuse the existing
foundation.

## Core Working Principles

1. **Analyze before execution.**  
   Read the related files and understand the relationship between screens,
   widgets, ViewModels, repositories, services, DTOs, session handling, and
   navigation before changing code.

2. **Explain the change plan before editing.**  
   Before modifying files, state:

   ```txt
   - Files that will be changed
   - New files that will be created
   - Layers that will be affected
   - Parts intentionally left unchanged
   - Change risks
   ```

3. **Follow the feature-first structure.**  
   Every feature must live under `lib/features/<feature_name>/`.

4. **Separate responsibilities by layer.**  
   DTOs represent API data shapes only. Services perform HTTP calls only.
   Repositories translate data into app-ready results. ViewModels manage UI
   state. Screens manage controllers, navigation, and layout composition.

5. **Use human-readable function names.**  
   Function names must describe what the function actually does. Avoid
   abbreviations, vague verbs, and overly abstract names.

6. **Use explicit dependency injection.**  
   Do not create a new `ApiClient`, repository, or controller directly inside a
   widget when that dependency is already available from the app root or parent
   widget.

7. **Preserve business flow.**  
   Do not change navigation, validation, session behavior, or API contracts
   without a clear technical reason and a stated impact.

8. **Keep UI responsive.**  
   Use Flutter approaches such as `SafeArea`, `LayoutBuilder`, `BoxConstraints`,
   `ConstrainedBox`, and `SingleChildScrollView` for screens that may overflow.

9. **Add tests according to risk.**  
   Changes to DTOs, services, repositories, ViewModels, sessions, and navigation
   must include relevant tests.

## Code Comments Rule

When creating or editing code, add concise developer-facing comments where they
clarify intent, screen flow, state ownership, API mapping, or non-obvious mobile
behavior.

Prefer comments for authentication/session handling, repository/data-source
boundaries, DTO/model mapping, screen/provider/controller responsibilities,
navigation assumptions, booking/activity/attendance flows, QR handling, image
URL handling, and fallback/error states.

Avoid comments that only restate the code. Keep comments short, accurate, and
close to the relevant class, function, widget, provider, or important branch.
Update or remove stale comments when behavior changes.

## Feature-First Folder Structure

Use this structure for each feature:

```txt
lib/
  features/
    feature_name/
      data/
        dto/
        services/
        repositories/
      presentation/
        view_models/
        screens/
        widgets/
```

Auth example:

```txt
lib/
  features/
    auth/
      data/
        dto/
          login_request_dto.dart
          login_response_dto.dart
          member_dto.dart
        services/
          auth_api_service.dart
        repositories/
          auth_repository.dart
      presentation/
        view_models/
          login_view_model.dart
        screens/
          login_screen.dart
        widgets/
          form_login.dart
          footer_login.dart
          header_login.dart
          hero_copy.dart
```

## Core Layer

Use `lib/core/` for cross-feature foundations:

```txt
lib/
  core/
    config/
      app_config.dart
    network/
      api_client.dart
      api_exception.dart
    session/
      auth_session.dart
      auth_session_controller.dart
      auth_session_repository.dart
      secure_session_storage.dart
      session_storage.dart
    colors.dart
    endpoints.dart
```

Core rules:

```txt
- Store API endpoints in core/endpoints.dart.
- Resolve the base URL through AppConfig.
- Route API calls through ApiClient.
- Read Bearer tokens from AuthSessionController or AuthSessionRepository.
- Persist secure tokens through AuthSessionRepository.
- Never store tokens directly in widgets.
```

## Network and API

Use `ApiClient` for every HTTP request.

Network rules:

```txt
- Use the http package.
- Use request timeouts.
- Send Accept: application/json.
- Send Content-Type JSON only when the request has a body.
- Use Bearer authorization for authenticated endpoints.
- Use authenticated: false for login.
- Handle errors through ApiException.
- Do not call jsonDecode directly from widgets.
```

Services are responsible for calling endpoints:

```dart
class AuthApiService {
  const AuthApiService({required ApiClient apiClient});
}
```

Repositories are responsible for returning app-ready results to ViewModels:

```dart
abstract interface class AuthRepository {
  Future<AuthLoginResult> login({
    required String email,
    required String password,
    String? companyId,
  });
}
```

## Auth and Session

Auth uses this endpoint:

```txt
POST /api/mobile/auth/login
```

Login payload:

```txt
email
password
companyId optional
deviceId optional
deviceName optional
platform optional
```

Successful login response:

```txt
token
expiresAt
member
```

Auth rules:

```txt
- The login screen must not perform dummy navigation.
- The login screen must use LoginViewModel.
- LoginViewModel calls AuthRepository.
- AuthRepository calls AuthApiService.
- AuthApiService calls ApiClient.
- A successful login token must be passed to AuthSessionController.
- If Remember Me is enabled, persist the token through AuthSessionRepository.
- If Remember Me is disabled, keep the session active only at app runtime.
- Show 401 errors as invalid email/password.
- Show 409 errors as requiring gym selection.
```

## UI and ViewModel

Screens are responsible for:

```txt
- TextEditingController
- FocusNode
- Navigation
- Layout composition
- Main callbacks
- Listening to ViewModel changes
```

ViewModels are responsible for:

```txt
- Loading state
- Error messages
- Form validation
- Calling repositories
- Updating session through injected controllers
```

Small widgets are responsible for:

```txt
- UI sections
- Visual forms
- Headers
- Footers
- Cards
- List items
- Empty states
```

Do not put HTTP calls, secure storage access, or business decisions directly in
presentation widgets.

## API Screen Refresh, Scrolling, and Loading

Every API-integrated feature screen that displays remote data must provide a
complete refresh, scrolling, loading, empty, and error experience.

Refresh and scrolling rules:

```txt
- Add pull-to-refresh for API-backed list, dashboard, detail, and section screens when the data can be reloaded by the user.
- Use Flutter's RefreshIndicator or the project-established refresh pattern for material screens.
- The RefreshIndicator child must always be scrollable, including when content is short, empty, loading, or in an error state.
- Use AlwaysScrollableScrollPhysics when needed so pull-to-refresh still works on empty or short content.
- Avoid non-scrollable API states that trap the user without a refresh path.
- Preserve the existing scroll position where practical when refreshing existing content.
- Do not create nested scroll views that fight each other unless the layout explicitly requires coordinated slivers.
```

Loading layout rules:

```txt
- Initial full-screen loading states must be visually centered within the available viewport.
- Section-level loading states must be centered within the section or card they belong to.
- Do not place a CircularProgressIndicator at the top of a SingleChildScrollView unless the design intentionally calls for it.
- Give loading, empty, and error states enough minimum height to look intentional on mobile and tablet layouts.
- Keep loading indicators accessible and paired with clear user-facing loading text when the wait is not obviously brief.
- Loading states must not cause layout jumps that make the refreshed content feel unstable.
```

When an API-backed screen has multiple states, structure the screen so every
state keeps the same responsive shell, safe area, constraints, and refresh
behavior unless a different interaction is intentional.

## UX and Copywriting

Write UI copy for users, not for programmers.

Copywriting rules:

```txt
- Hide technical jargon from visible UI copy.
- Do not show words like API, payload, endpoint, exception, stack trace, or status code in user-facing errors.
- Explain problems in terms of what the user can understand and do next.
- Keep terminology consistent across buttons, dialogs, empty states, and error messages.
- If the database uses soft delete, still use Delete in the UI unless Archive or Deactivate is a distinct business feature.
- Do not rename a destructive action to Archive or Deactivate only because the backend keeps the record.
- Loading states must clearly communicate that work is in progress.
- Error states must explain the issue and provide a useful next action when possible.
- Empty states must explain what is missing and how the user can create or find data.
- Avoid placeholder copy that makes the app feel unfinished.
```

Examples:

```txt
Good: "We could not sign you in. Check your email and password, then try again."
Avoid: "API request failed with status code 401."

Good: "No classes are available yet."
Avoid: "Empty response payload."

Good: "Delete member"
Avoid: "Soft delete member"
```

## Responsive Flutter Guideline

Use these breakpoints:

```txt
< 600 px      : mobile stacked layout
600 - 839 px  : tablet centered layout
>= 840 px     : expanded layout
```

Base pattern:

```dart
SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width >= 840) {
        // Expanded layout
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

Limit content width:

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 640),
    child: child,
  ),
)
```

Use scrolling for content that may overflow:

```dart
SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  child: content,
)
```

## Testing Rules

Use tests according to layer:

```txt
- DTO: JSON parsing and invalid responses.
- Service: endpoint path, method, body, headers, and authenticated flag.
- Repository: mapping service responses into app results.
- ViewModel: validation, loading, errors, and session behavior.
- Widget test: user interactions and screen changes.
- Session test: restore, expiry, clear, and token provider behavior.
```

Do not rely on a real backend for unit tests and widget tests. Use fake
repositories or mock HTTP clients.

Before work is considered complete, run:

```bash
flutter analyze
flutter test
```

For Android or dependency changes, also run:

```bash
flutter build apk --debug
```

## API Base URL

The API base URL is configured through:

```txt
API_BASE_URL
```

Release builds must use HTTPS and an explicit `API_BASE_URL`.

## Naming Standards

Use class names that clearly describe their responsibility:

```txt
LoginViewModel
AuthApiService
RemoteAuthRepository
LoginRequestDto
LoginResponseDto
MemberDto
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

Use snake_case for file names:

```txt
login_view_model.dart
auth_api_service.dart
auth_repository.dart
login_request_dto.dart
login_response_dto.dart
member_dto.dart
header_login.dart
hero_copy.dart
form_login.dart
footer_login.dart
```

Use clear function names:

```dart
Future<void> _submitLoginForm() async {}
void _togglePasswordVisibility() {}
void _changeSelectedNavigationIndex(int index) {}
bool _isValidEmailAddress(String value) {}
Widget _buildExpandedHomeContent(HomeLayoutSpec spec) {}
Widget _buildStackedHomeContent(HomeLayoutSpec spec) {}
```

Avoid names that are too short or ambiguous:

```dart
void _submit() {}
void _toggle() {}
void _change(int index) {}
bool _valid(String value) {}
Widget _buildOne() {}
Widget _buildTwo() {}
```

Function naming rules:

```txt
- Use names that read like the action being performed.
- Prefer specific verbs such as submit, validate, restore, fetch, save, clear, map, and build.
- Avoid abbreviations unless they are widely understood in the project domain.
- Avoid vague names such as handle, process, execute, run, doStuff, or manage unless the object being handled is explicit.
- Private callback names should still describe the user action or state change.
```

## Change Constraints

Do not do the following unless explicitly requested:

```txt
- Replace the state management architecture.
- Put HTTP calls directly in screens.
- Put secure storage access directly in widgets.
- Change API contracts without checking the backend.
- Change the main route without a clear reason.
- Make broad design changes without approval.
- Remove dummy data from other features before those features are integrated.
- Add new dependencies without a technical reason.
```

## Definition of Done

Work is considered complete when:

```txt
- File structure follows feature-first.
- Dependencies are injected clearly.
- Network calls go through ApiClient.
- API errors are handled in the ViewModel or the appropriate layer.
- Tokens do not leak into presentation widgets.
- API-backed screens provide usable pull-to-refresh or an equivalent refresh path.
- Loading states are centered in their full-screen or section-level viewport.
- UI remains responsive.
- flutter analyze passes.
- flutter test passes.
- Relevant target builds pass when platform/dependency changes are involved.
- Official documentation and relevant package documentation have been checked for implementation-sensitive changes.
- A change summary and risk notes are reported to the user.
```
