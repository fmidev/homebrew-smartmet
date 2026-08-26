# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetQdtools < Formula
  desc "FMI smartmet — command-line tools for querydata, GRIB, NetCDF, HDF5"
  homepage "https://github.com/fmidev/smartmet-qdtools"
  url "https://github.com/fmidev/smartmet-qdtools.git",
      revision: "48b37c0c5e4e27781efe8f822e619ae1f5bf6231"
  version "2026.05.27"
  license "MIT"
  # revision 1: qdtools-macos.patch now fixes Hdf5File.cpp + NcFileExtended.cpp
  # for GDAL 3.13 (GetMetadata returns CSLConstList, not char**). Source
  # revision is unchanged.
  revision 1

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-qdtools-2026.05.27_1"
    sha256 cellar: :any, arm64_tahoe: "e973645aa0876d731aacb805b952bfce20a08273ba2a9b099a1f00c68a5af1c9"
  end

  depends_on "boost"
  depends_on "bzip2"
  depends_on "double-conversion"
  depends_on "eccodes"
  depends_on "fmidev/smartmet/smartmet-library-calculator"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-imagine"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmidev/smartmet/smartmet-library-smarttools"
  depends_on "fmidev/smartmet/smartmet-timezones"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "hdf5"
  depends_on "howard-hinnant-date"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "netcdf"
  depends_on "netcdf-cxx"

  # Vendored at build time: dtl is a header-only diff library used by
  # qddifference. Not in Homebrew core, so we fetch it directly.
  resource "dtl" do
    url "https://github.com/cubicdaiya/dtl.git",
        revision: "32567bb9ec704f09040fb1ed7431a3d967e3df03"
  end

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/qdtools-macos.patch"
    cp "#{tap_patches}/qdtools.Makefile.mac", "Makefile.mac"

    # Vendor dtl headers so qddifference compiles
    resource("dtl").stage do
      mkdir_p buildpath/"include/dtl"
      cp Dir["dtl/*.hpp"], buildpath/"include/dtl/"
    end

    macgyver   = formula_opt_prefix("fmidev/smartmet/smartmet-library-macgyver")
    gis        = formula_opt_prefix("fmidev/smartmet/smartmet-library-gis")
    newbase    = formula_opt_prefix("fmidev/smartmet/smartmet-library-newbase")
    imagine    = formula_opt_prefix("fmidev/smartmet/smartmet-library-imagine")
    calculator = formula_opt_prefix("fmidev/smartmet/smartmet-library-calculator")
    smarttools = formula_opt_prefix("fmidev/smartmet/smartmet-library-smarttools")
    tz = Formula["fmidev/smartmet/smartmet-timezones"].opt_share/"smartmet/timezones"

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "TIMEZONES_DIR=#{tz}",
           "MACGYVER_INC=#{macgyver}/include/smartmet",   "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",             "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",     "NEWBASE_LIB=#{newbase}/lib",
           "IMAGINE_INC=#{imagine}/include/smartmet",     "IMAGINE_LIB=#{imagine}/lib",
           "CALCULATOR_INC=#{calculator}/include/smartmet", "CALCULATOR_LIB=#{calculator}/lib",
           "SMARTTOOLS_INC=#{smarttools}/include/smartmet", "SMARTTOOLS_LIB=#{smarttools}/lib",
           "BOOST_PREFIX=#{formula_opt_prefix("boost")}",
           "FMT_PREFIX=#{formula_opt_prefix("fmt")}",
           "GDAL_PREFIX=#{formula_opt_prefix("gdal")}",
           "DC_PREFIX=#{formula_opt_prefix("double-conversion")}",
           "DATE_PREFIX=#{formula_opt_prefix("howard-hinnant-date")}",
           "PNG_PREFIX=#{formula_opt_prefix("libpng")}",
           "JPEG_PREFIX=#{formula_opt_prefix("jpeg-turbo")}",
           "BZIP2_PREFIX=#{formula_opt_prefix("bzip2")}",
           "ECCODES_PREFIX=#{formula_opt_prefix("eccodes")}",
           "NETCDF_PREFIX=#{formula_opt_prefix("netcdf")}",
           "NETCDFCXX_PREFIX=#{formula_opt_prefix("netcdf-cxx")}",
           "HDF5_PREFIX=#{formula_opt_prefix("hdf5")}"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    # Most qdtools binaries print usage and exit non-zero on no args, so
    # check installed binaries directly. qdinfo with no args exits 0.
    assert_path_exists bin/"qdinfo"
    assert_path_exists bin/"qdstat"
    assert_path_exists bin/"gribtoqd"
    assert_path_exists bin/"qdtogrib"
    system bin/"qdinfo"
  end
end
