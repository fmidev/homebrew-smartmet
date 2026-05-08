# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetQdless < Formula
  desc "FMI smartmet — interactive UTF-8 terminal viewer for querydata"
  homepage "https://github.com/fmidev/smartmet-qdless"
  url "https://github.com/fmidev/smartmet-qdless.git",
      revision: "235a738d20c7d59c60789b56c99b7e2a0b30e113"
  version "2026.05.08.1"
  license "MIT"

  # GRIB/NetCDF input requires smartmet-library-grid-files, which is not yet
  # in this tap. The QueryData (.sqd) path uses newbase directly and is built;
  # GRIB and NetCDF inputs return a clear "not built" error.

  depends_on "boost"
  depends_on "fmidev/smartmet/gshhg-gmt-nc4"
  depends_on "fmidev/smartmet/smartmet-library-calculator"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-imagine"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmidev/smartmet/smartmet-library-smarttools"
  depends_on "fmt"
  depends_on "howard-hinnant-date"
  depends_on "jsoncpp"
  depends_on "ncurses"
  depends_on "netcdf"
  depends_on "netcdf-cxx"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/qdless-macos.patch"
    cp "#{tap_patches}/qdless.Makefile.mac", "Makefile.mac"

    macgyver   = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis        = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase    = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    imagine    = Formula["fmidev/smartmet/smartmet-library-imagine"].opt_prefix
    calculator = Formula["fmidev/smartmet/smartmet-library-calculator"].opt_prefix
    smarttools = Formula["fmidev/smartmet/smartmet-library-smarttools"].opt_prefix
    gshhg      = Formula["fmidev/smartmet/gshhg-gmt-nc4"].opt_share/"gshhg-gmt-nc4"

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "QDLESS_DATA_DIR=#{share}/smartmet/qdless",
           "QDLESS_GSHHG_DIR=#{gshhg}",
           "MACGYVER_INC=#{macgyver}/include/smartmet",   "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",             "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",     "NEWBASE_LIB=#{newbase}/lib",
           "IMAGINE_INC=#{imagine}/include/smartmet",     "IMAGINE_LIB=#{imagine}/lib",
           "CALCULATOR_INC=#{calculator}/include/smartmet", "CALCULATOR_LIB=#{calculator}/lib",
           "SMARTTOOLS_INC=#{smarttools}/include/smartmet", "SMARTTOOLS_LIB=#{smarttools}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "DC_PREFIX=#{Formula["double-conversion"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}",
           "JSONCPP_PREFIX=#{Formula["jsoncpp"].opt_prefix}",
           "NCURSES_PREFIX=#{Formula["ncurses"].opt_prefix}",
           "NETCDF_PREFIX=#{Formula["netcdf"].opt_prefix}",
           "NETCDFCXX_PREFIX=#{Formula["netcdf-cxx"].opt_prefix}"

    system "make", "-f", "Makefile.mac", "install",
           "PREFIX=#{prefix}",
           "QDLESS_DATA_DIR=#{share}/smartmet/qdless"
  end

  test do
    assert_path_exists bin/"qdless"
    assert_match(/Usage: qdless/, shell_output("#{bin}/qdless --help"))
  end
end
