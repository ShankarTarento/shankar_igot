# ![](assets/img/readme_logo.png) iGOT Karmayogi

iGOT Karmayogi created in Flutter and Dart.

This platform allows the government to break slilos and harness the full potential of government officials for solutioning rather than simply depending on the knowledge and skills of an individual official.

## How to Use

**Step 1:**
Download or clone this repo by using the link below:

```
https://git.idc.tarento.com/karmayogi_bharath/karmayogi_bharath
```

**Step 2:**
Go to project root and execute the following command in console to get the required dependencies:

```
flutter pub get
```

**Step 3:**
Download the configuration files from

```
https://drive.google.com/file/d/1tA6Nw9RPggsOiDYZHGF5-gZhkw6O4OTi/view?usp=share_link
```

**Step 4:**
Place them in the root folder & run the following command in console:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5:**
Go to project root and execute the following command in console to run the app in emulator:

```
flutter run
```

### Branching

There are 2 branches for Android & iOS apps, branch `master` can be used for Android while `master_ios` can be used for iOS.

### Configuration Details

Flutter 3.27.1 • channel [user-branch] • unknown source
Framework • revision 17025dd882 (10 months ago) • 2024-12-17 03:23:09 +0900
Engine • revision cb4b5fff73
Tools • Dart 3.6.0 • DevTools 2.40.2

Folder stucture followed 
├── repositories/            # Data repositories
│   ├── learn_repository.dart
│   ├── network_repository.dart
│   └── profile_repository.dart
│
└── ui/                     # UI components
    ├── pages/
    │   ├── home_page/
    │   └── national_learning_week/
    └── widgets/
        ├── _banner/
        ├── _common/
        ├── _home/
        └── _network/


Restructuring Feature-First Structure:

lib/
├── core/                           # Core functionality
│   ├── config/
│   │   ├── app_config.dart
│   │   └── environment_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── color_constants.dart
│   │   └── telemetry_constants.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── services/
│   │   ├── analytics/
│   │   │   └── analytics_service.dart
│   │   └── telemetry/
│   │       └── telemetry_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_utils.dart
│       └── string_utils.dart
│
├── features/                       # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       └── login.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── home/                      # Home feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │           ├── carousel_card/
│   │           ├── designation_card/
│   │           └── hubs_strip/
│   │
│   └── learn/                     # Learning feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                        # Shared components
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   └── dialogs/
│   └── models/
│       └── base_models.dart
│
├── l10n/                         # Localization
│   └── app_localizations.dart
│
└── main.dart