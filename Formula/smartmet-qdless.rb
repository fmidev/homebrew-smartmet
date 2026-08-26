# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetQdless < Formula
  desc "FMI smartmet — interactive UTF-8 terminal viewer for querydata / GRIB / NetCDF"
  homepage "https://github.com/fmidev/smartmet-qdless"
  url "https://github.com/fmidev/smartmet-qdless.git",
      revision: "e63ab5b684ec025190cb500e37ef2485b2b5b397"
  version "2026.05.29.1"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-qdless-2026.05.29.1"
    sha256 arm64_tahoe: "7dbe7b43e0375a5505af8d7264148ba965519be4b9173852d801d9fa5cc6b4f3"
  end

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

    macgyver   = formula_opt_prefix("fmidev/smartmet/smartmet-library-macgyver")
    gis        = formula_opt_prefix("fmidev/smartmet/smartmet-library-gis")
    newbase    = formula_opt_prefix("fmidev/smartmet/smartmet-library-newbase")
    grid_files = formula_opt_prefix("fmidev/smartmet/smartmet-library-grid-files")
    # spine + trax are pulled in transitively by grid-files; qdless's own
    # source no longer references them directly.
    spine      = formula_opt_prefix("fmidev/smartmet/smartmet-library-spine")
    trax       = formula_opt_prefix("fmidev/smartmet/smartmet-library-trax")
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
           "BOOST_PREFIX=#{formula_opt_prefix("boost")}",
           "FMT_PREFIX=#{formula_opt_prefix("fmt")}",
           "DC_PREFIX=#{formula_opt_prefix("double-conversion")}",
           "DATE_PREFIX=#{formula_opt_prefix("howard-hinnant-date")}",
           "JSONCPP_PREFIX=#{formula_opt_prefix("jsoncpp")}",
           "NCURSES_PREFIX=#{formula_opt_prefix("ncurses")}",
           "NETCDF_PREFIX=#{formula_opt_prefix("netcdf")}",
           "NETCDFCXX_PREFIX=#{formula_opt_prefix("netcdf-cxx")}",
           "GDAL_PREFIX=#{formula_opt_prefix("gdal")}",
           "WEBP_PREFIX=#{formula_opt_prefix("webp")}"

    system "make", "-f", "Makefile.mac", "install",
           "PREFIX=#{prefix}",
           "QDLESS_DATA_DIR=#{share}/smartmet/qdless"
  end

  test do
    assert_path_exists bin/"qdless"
    assert_match(/Usage: qdless/, shell_output("#{bin}/qdless --help"))
  end
end
