# Ecom

A Flutter shopping app built against the [DummyJSON Products API](https://dummyjson.com/docs/products), using BLoC state management and clean architecture. Built as a technical assessment, feature by feature, with a reviewed commit after each one (see `git log` and [AI_USAGE.md](AI_USAGE.md) for how that process worked).

## Features

- **Product catalogue** — paginated grid, debounced search, category filter, pull-to-refresh, offline cache fallback
- **Product details** — image carousel, price/discount, rating, stock, description
- **Favourites** — add/remove, persisted locally, shared instantly across every screen
- **Cart** — quantity stepper, remove, subtotal/discount/total, persisted locally
- **Localization** — English and Arabic, with RTL layout, switchable at runtime
- **Application states** — initial/pagination loading, empty results, network/API failure with retry, image-load failure, no-search-results; a failed refresh never clears data that was already loaded successfully

## Architecture

Clean architecture, feature-first:

```
lib/
  core/           # cross-cutting: DI, networking, theme, router, error types, localization, shared widgets
  features/
    products/     # catalogue + product details (data / domain / presentation)
    favourites/   # data / domain / presentation
    cart/         # data / domain / presentation
  l10n/           # ARB source strings (generated AppLocalizations is gitignored, see below)
```

Each feature is split into `data` (models, datasources, repository implementations), `domain` (entities, repository contracts, use cases), and `presentation` (bloc/cubit, pages, widgets). API calls only happen inside repositories/datasources — never from widgets.

**Favourites and Cart deliberately skip the use-case layer.** They're pure local CRUD over Hive with no orchestration logic beyond "read/write the box," so a `UseCase` wrapper around a one-line repository call would be ceremony with no payoff. The Products feature *does* use explicit use cases (`GetProducts`, `SearchProducts`, `GetProductsByCategory`, `GetProductById`, `GetCategories`) because it has real branching logic in the bloc that benefits from a stable, testable seam.

**State management**: `flutter_bloc`. `ProductsBloc` (full Bloc) handles the catalogue's multi-event flow (pagination, search, category, refresh). `ProductDetailsCubit`, `FavouritesCubit`, `CartCubit`, and `LocaleCubit` are plain Cubits — each only ever needs "load" or "mutate and re-emit," so a full Bloc's event layer would add nothing. `FavouritesCubit` and `CartCubit` are registered as **singletons** in the DI container (not per-page factories) and provided once at the app root, so the catalogue, details screen, and their own tabs all reflect the same state instantly — no manual refresh/sync needed.

## Package choices

| Package | Why |
|---|---|
| `flutter_bloc` | State management, as required. Bloc where multi-event orchestration pays off, Cubit where it's just load/mutate. |
| `dio` | HTTP client with first-class `CancelToken` support — used to actually abort superseded search/category requests, not just ignore their results. |
| `get_it` | Simple, explicit dependency injection without codegen. |
| `hive` / `hive_flutter` | Local persistence for favourites, cart, and cached product data. Chosen over `sqflite`/`drift` because the data is small, schema-less key→JSON-string data with no relational queries — a NoSQL key-value store is a better fit and needs no migrations. Chosen over plain `shared_preferences` because it handles larger structured payloads (full product objects) more comfortably. |
| `rxdart` | `debounceTime` + `switchMap` for search-as-you-type debouncing directly on the bloc's event stream, without a separate `bloc_concurrency` dependency. |
| `go_router` | Declarative routing with `StatefulShellRoute.indexedStack`, which keeps each bottom-nav tab's own `Navigator` (and therefore scroll position and bloc state) alive when switching tabs — this is what satisfies the "preserve list/scroll state on navigation" requirement, for free. |
| `cached_network_image` | Image caching plus built-in placeholder/error-widget states for the image-load-failure requirement. |
| `connectivity_plus` | Network-reachability check used by the repository to decide when to fall back to cached data. |
| `equatable` | Value equality for entities/states without hand-written `==`/`hashCode`. |
| Official `flutter_localizations` + ARB (`intl`, `flutter gen-l10n`) | Standard Flutter localization tooling rather than a third-party package like `easy_localization` — no extra dependency, and RTL comes for free from the Arabic locale. |
| `bloc_test`, `mocktail` (dev) | Bloc testing with real (not manually faked) time-based debounce assertions, and interface mocking without codegen. |

No `dartz`/`fpdart`: a small hand-rolled `Result<T>` sealed class (`core/utils/result.dart`) covers the one thing needed — typed success/failure from repositories — without pulling in a general-purpose functional programming library.

## Getting started

```bash
flutter pub get   # also regenerates lib/l10n/app_localizations*.dart (gitignored, see l10n.yaml)
flutter run
```

The generated localization files aren't committed — `pubspec.yaml` sets `flutter: generate: true`, so `flutter pub get` (and `flutter build`/`flutter run`) regenerate them automatically from the ARB sources in `lib/l10n/`.

## Testing

```bash
flutter analyze
flutter test
```

The test suite covers bloc/cubit logic (including a real-timing test that debounced search only fires one API call), JSON parsing of malformed/missing API fields, a real Hive-backed persistence round-trip, and widget-level rendering/interaction. See [AI_USAGE.md](AI_USAGE.md) for how each feature was verified end-to-end (including live runs against the real API) before being committed.
