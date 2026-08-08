# AI Usage

## AI tools used

- **Claude Code** (Anthropic, Sonnet 5), used as the CLI coding agent for the entire implementation — architecture, feature code, tests, and this documentation.

## How the work was directed

This was not a single "build the whole app" prompt. I (the candidate) drove the process feature by feature: I asked for a Flutter shopping app in BLoC + clean architecture, but explicitly told the AI **not** to build and commit everything at once. Instead, for each functional area (scaffolding, localization, catalogue, details, favourites, cart, tests, docs) the AI implemented the slice, ran `flutter analyze`/`flutter test`/a live Chrome smoke test against the real DummyJSON API, and then stopped and told me the exact commit message to use — I reviewed the diff and ran `git commit` myself after each one, rather than letting the AI commit on my behalf. Partway through I also reminded it not to skip this checkpoint ("don't forget about the commits, tell me when to make a commit after each feature"), and it kept to that for the remaining features. This produced the seven feature commits plus this docs commit, each independently buildable and testable, rather than one large opaque commit.

## Parts substantially generated with AI assistance

Essentially all source code in `lib/` and `test/` was AI-generated under this direction-and-review loop:

- Clean-architecture scaffolding: DI container (`get_it`), Dio HTTP client, `Result`/`Failure` types, Material 3 theme, `go_router` bottom-nav shell
- English/Arabic localization (ARB catalog, RTL handling, runtime language toggle)
- Product catalogue: entities, repository, use cases, `ProductsBloc` (pagination, debounced search, category filter, pull-to-refresh, offline cache fallback), grid UI and all required UI states
- Product details screen
- Favourites and Cart features (Hive-backed repositories, singleton cubits shared across screens)
- The 37-test suite (bloc/cubit logic, JSON parsing edge cases, real Hive persistence, widget rendering)

I reviewed each diff before committing and made the final call on package choices, feature ordering, and the two questions the AI asked upfront (test target device, who runs `git init`).

## An AI suggestion I corrected

While writing a regression test for the product grid, the AI's first version rendered the full `ProductsView` (real bloc, real `CachedNetworkImage`s) and called `tester.pumpAndSettle()`. That hung for a full 10-minute test timeout — unrelated to real networking (Flutter's test `HttpClient` short-circuits to a 400 response immediately), but something in the image-cache/platform-channel plumbing never settles under `pumpAndSettle` in a widget test. Rather than accept a slow, occasionally-hanging test, I had it replace that test with a minimal, isolated reproduction of the actual mechanism under test (a bare `GridView.builder` with a tiny fake cubit, no network images at all), which runs in under a second and still proves the fix.

## A problem encountered in AI-generated code

The first version of the catalogue and favourites grids called `context.select<FavouritesCubit, bool>(...)` directly inside `GridView.builder`'s `itemBuilder`. `flutter analyze` was completely clean, and it looked correct — but the moment the grid actually rendered in a live `flutter run -d chrome` session, `provider` threw a runtime assertion: `context.select` can't be used directly inside a `SliverChildBuilderDelegate` item because the framework can't safely scope the rebuild to just that item. Static analysis and even `flutter test`'s type-checking gave no signal here; it only showed up by actually running the app. The fix was to extract a small `_ProductGridItem`/`_FavouriteGridItem` widget so `select` runs in its own `BuildContext` below the sliver's keep-alive wrapper. This is the reason every feature in this repo was verified with a real `flutter run -d chrome` pass against the live API before being marked done, not just `flutter analyze`.

## How the generated solution was tested and verified

For every feature commit:

1. `flutter analyze` — zero issues required before moving on.
2. `flutter test` — the full suite (37 tests by the final commit) had to pass, including `bloc_test`-based `ProductsBloc` tests with real debounce timing, JSON-parsing edge cases for malformed API data, and a real Hive-backed (temp-directory) persistence test rather than only an in-memory fake.
3. A live `flutter run -d chrome` smoke test against the real `dummyjson.com` API, with the process log grepped for uncaught exceptions/assertions — this is what caught the `context.select`-in-sliver bug above, which the first two checks missed entirely.
4. Final acceptance on a physical Android device is on me (the candidate) — the AI's sandbox only had Chrome and Windows desktop as run targets, so I connected a real device to do that verification myself.
