# fmidev/homebrew-smartmet

Homebrew tap for FMI's [smartmet](https://github.com/fmidev) software on macOS.

## Quick start

```sh
brew tap fmidev/smartmet      # only needed once when this tap is published
brew install fmidev/smartmet/smartmet-qdtools
```

This pulls in the full library stack (macgyver → gis → newbase → imagine,
calculator, smarttools → qdtools) plus 42 command-line tools (`qdinfo`,
`qdstat`, `gribtoqd`, `qdtogrib`, `nctoqd`, `h5toqd`, …) and the
timezone data files. The timezone path is baked into the binaries at
build time, so no environment variable setup is needed.

If you want to point the binaries at a different timezone dataset (e.g.
for testing), the env-var override still works:

```sh
export FMI_TIMEZONES_DIR=/path/to/smartmet/timezones
```

## Available formulae

| Formula | Description |
|---------|-------------|
| `smartmet-library-macgyver`   | foundational utilities |
| `smartmet-library-gis`        | GDAL/GEOS/PROJ wrappers |
| `smartmet-library-newbase`    | querydata, projections |
| `smartmet-library-imagine`    | image generation |
| `smartmet-library-calculator` | analysis calculator framework |
| `smartmet-library-smarttools` | interpreter for newbase data |
| `smartmet-qdtools`            | 42 CLI tools |
| `smartmet-timezones`          | timezone shapefile + boost zonespec |

## What's not included

These features are off by default because their dependencies are not in
Homebrew:

| Feature                                  | Missing dep         |
|------------------------------------------|---------------------|
| `bufrtoqd`, `radartoqd` (BUFR conversion)| `libecbufr`, `libbufr` |
| `metar2qd` (METAR conversion)            | `libmetar`          |
| `EPSGInfo` API (gis)                     | `sqlite3pp`         |

`qddifference` (querydata diffing, depends on the header-only `dtl` library)
and Postgres support in `smartmet-library-macgyver` (depends on `libpqxx`)
are both built by default — `dtl` is fetched automatically as a build-time
resource, and `libpqxx` is a brew dependency.

## How this works

This tap pins each formula to a specific upstream commit and applies
small portability patches (kept in `patches/`) for things that the
upstream code doesn't yet handle on macOS — `pthread_setname_np`
signature, POSIX vs GNU `strerror_r`, `MADV_DONTDUMP`, `sincos`,
`std::random_shuffle`, `std::ptr_fun`, plus an `FMI_TIMEZONES_DIR`
env-var override for the hardcoded `/usr/share/smartmet/timezones`
path.

All patches are guarded with platform/feature macros so they don't
change Linux behavior. See `MACOS_PORTING_BRIEF.md` in the user's
working tree for the full developer-facing summary.

The tap also drops in a portable `Makefile.mac` for each package
(stored under `patches/*.Makefile.mac`) since the upstream Makefiles
depend on FMI's internal `smartbuildcfg` + RPM tooling that isn't
available on macOS.

## Staying in sync with upstream

A scheduled GitHub Actions workflow (`.github/workflows/auto-update.yml`)
runs every Monday and compares each formula's pinned `revision:` with
the latest commit on the corresponding `fmidev/smartmet-*` upstream repo.
If anything is newer it opens a PR bumping `revision:` and `version:`,
which CI then rebuilds bottles for. Apply the **`pr-pull`** label on
the auto-PR to publish the refreshed bottles.

You can also trigger the check manually from the Actions tab
(`auto-update-formulae` → "Run workflow"). If an upstream change
breaks one of our `patches/*.patch` files, CI will fail on the auto-PR
and a maintainer needs to regenerate the patch.

## Known test failures (informational)

Out of 138 unit tests across the libraries, 135 pass on macOS. The 3
that still fail are:

- `gis/DEMTest`, `gis/LandCoverTest` — need a separate FMI raster
  dataset at `/smartmet/share/gis/rasters/`.
- `imagine/NFmiApproximateBezierFitTest` — tiny floating-point
  precision diff (likely fails the same way on Linux clang).

`smartmet-qdtools` integration tests (`*.test`) are not run via brew —
they need the FMI test data corpus expected at
`/usr/share/smartmet/test/data/qdtools/`. To run them locally:

```sh
git clone git@github.com:fmidev/smartmet-qdtools-test-data.git
sudo mkdir -p /usr/share/smartmet/test/data
sudo ln -s "$PWD/smartmet-qdtools-test-data" /usr/share/smartmet/test/data/qdtools
# then in a checkout of smartmet-qdtools:
make -C test test
```
