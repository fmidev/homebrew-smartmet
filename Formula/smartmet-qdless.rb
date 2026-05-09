# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetQdless < Formula
  desc "FMI smartmet — interactive UTF-8 terminal viewer for querydata / GRIB / NetCDF"
  homepage "https://github.com/fmidev/smartmet-qdless"
  url "https://github.com/fmidev/smartmet-qdless.git",
      revision: "218d7b039b9015e6f7c22b74b1d7779015102cbb"
  version "2026.05.10.1"
  license "MIT"

  # GRIB1 / GRIB2 / NetCDF input is built unconditionally via
  # smartmet-library-grid-files. The grid-files config + parameter / geometry
  # CSVs are auto-discovered at /opt/homebrew/share/smartmet/grid-files/ (set
  # by the smartmet-library-grid-files formula); QDLESS_GRID_FILES_CONF
  # overrides the path at runtime.

  depends_on "boost"
  depends_on "fmidev/smartmet/gshhg-gmt-nc4"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-grid-files"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "howard-hinnant-date"
  depends_on "jsoncpp"
  depends_on "ncurses"
  depends_on "netcdf"
  depends_on "netcdf-cxx"
  depends_on "webp"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/qdless-macos.patch"
    cp "#{tap_patches}/qdless.Makefile.mac", "Makefile.mac"

    macgyver   = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis        = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase    = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    grid_files = Formula["fmidev/smartmet/smartmet-library-grid-files"].opt_prefix
    # spine + trax are pulled in transitively by grid-files; qdless's own
    # source no longer references them directly.
    spine      = Formula["fmidev/smartmet/smartmet-library-spine"].opt_prefix
    trax       = Formula["fmidev/smartmet/smartmet-library-trax"].opt_prefix
    gshhg      = Formula["fmidev/smartmet/gshhg-gmt-nc4"].opt_share/"gshhg-gmt-nc4"

    # The grid-files headers live at <grid-files prefix>/include/smartmet/
    # grid-files/...; qdless sources include <grid-files/...>, so GRID_FILES_INC
    # must point at the dir whose child is `grid-files/`.
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "QDLESS_DATA_DIR=#{share}/smartmet/qdless",
           "QDLESS_GSHHG_DIR=#{gshhg}",
           "MACGYVER_INC=#{macgyver}/include/smartmet",   "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",             "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",     "NEWBASE_LIB=#{newbase}/lib",
           "SPINE_INC=#{spine}/include/smartmet",         "SPINE_LIB=#{spine}/lib",
           "TRAX_INC=#{trax}/include/smartmet",           "TRAX_LIB=#{trax}/lib",
           "GRID_FILES_INC=#{grid_files}/include/smartmet", "GRID_FILES_LIB=#{grid_files}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "DC_PREFIX=#{Formula["double-conversion"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}",
           "JSONCPP_PREFIX=#{Formula["jsoncpp"].opt_prefix}",
           "NCURSES_PREFIX=#{Formula["ncurses"].opt_prefix}",
           "NETCDF_PREFIX=#{Formula["netcdf"].opt_prefix}",
           "NETCDFCXX_PREFIX=#{Formula["netcdf-cxx"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "WEBP_PREFIX=#{Formula["webp"].opt_prefix}"

    system "make", "-f", "Makefile.mac", "install",
           "PREFIX=#{prefix}",
           "QDLESS_DATA_DIR=#{share}/smartmet/qdless"
  end

  test do
    assert_path_exists bin/"qdless"
    assert_match(/Usage: qdless/, shell_output("#{bin}/qdless --help"))
  end
end
