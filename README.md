# fmidev/homebrew-smartmet

Homebrew tap for FMI's [smartmet](https://github.com/fmidev) software on macOS.

## Quick start

```sh
brew tap fmidev/smartmet      # only needed once when this tap is published
brew install fmidev/smartmet/smartmet-qdtools
```

This pulls in the full library stack (macgyver → gis → newbase → imagine,
calculator, smarttools → qdtools) plus 42 command-line tools (`qdinfo`,
`qdstat`, `gribtoqd`, `qdtogrib`, `nctoqd`, `h5toqd`, …).

After installing, set the timezone data path so commands that load
timezone info (most of qdtools) can find it:

```sh
export FMI_TIMEZONES_DIR=$(brew --prefix smartmet-timezones)/share/smartmet/timezones
```

(Add this to your shell rc.)

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
| `qddifference` (querydata diffing)       | `dtl` (header-only) |
| `EPSGInfo` API (gis)                     | `sqlite3pp`         |
| Postgres support (macgyver)              | `libpqxx` (in brew) — pass `--with-postgres` |

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

## Known test failures (informational)

Out of 138 unit tests across the libraries, 135 pass on macOS. The 3
that still fail are:

- `gis/DEMTest`, `gis/LandCoverTest` — need a separate FMI raster
  dataset at `/smartmet/share/gis/rasters/`.
- `imagine/NFmiApproximateBezierFitTest` — tiny floating-point
  precision diff (likely fails the same way on Linux clang).

`smartmet-qdtools` integration tests (`*.test`) are not run via brew
because they need the upstream FMI test data corpus
(`/usr/share/smartmet/test/data/qdtools/`).
