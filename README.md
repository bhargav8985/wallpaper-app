# Wallpaper App (Flutter)

A starter Flutter app inspired by wallpaper gallery apps (like superhero wallpaper apps on Play Store).

## What this starter includes

- Explore tab with:
  - Search
  - Category chips (Trending, Superheroes, Anime, Cars, Nature, Abstract)
  - Wallpaper grid
- Wallpaper details screen with:
  - Hero animation
  - Download button placeholder
  - Favorite toggle
- Favorites tab

## Run locally

1. Install Flutter SDK.
2. In this folder run:

```bash
flutter pub get
flutter run
```

## Production upgrades you should add next

- Connect to a real wallpapers API or your own backend.
- Add authentication if you need user sync.
- Cache images and favorites locally (Hive/Isar/shared_preferences).
- Implement real download + set wallpaper using platform channels.
- Add Android runtime permissions and privacy policy.
- Add ads / premium if needed.

## Suggested architecture for scaling

- `lib/features/discovery`
- `lib/features/favorites`
- `lib/features/wallpaper_detail`
- `lib/core/network`
- `lib/core/storage`

Then use Riverpod/Bloc for state management.
