# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetQdtools < Formula
  desc "FMI smartmet — command-line tools for querydata, GRIB, NetCDF, HDF5"
  homepage "https://github.com/fmidev/smartmet-qdtools"
  url "https://github.com/fmidev/smartmet-qdtools.git",
      revision: "604ec7fedc298b2f5a43a8068df6b15effdf5bdc"
  version "2026.05.04"
  license "MIT"

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
    cp "#{tap_patches}/qdtools.Makefile.mac", "Makefile.mac"

    # Vendor dtl headers so qddifference compiles
    resource("dtl").stage do
      mkdir_p buildpath/"include/dtl"
      cp Dir["dtl/*.hpp"], buildpath/"include/dtl/"
    end

    macgyver   = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis        = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase    = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    imagine    = Formula["fmidev/smartmet/smartmet-library-imagine"].opt_prefix
    calculator = Formula["fmidev/smartmet/smartmet-library-calculator"].opt_prefix
    smarttools = Formula["fmidev/smartmet/smartmet-library-smarttools"].opt_prefix
    tz = Formula["fmidev/smartmet/smartmet-timezones"].opt_share/"smartmet/timezones"

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "TIMEZONES_DIR=#{tz}",
           "MACGYVER_INC=#{macgyver}/include/smartmet",   "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",             "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",     "NEWBASE_LIB=#{newbase}/lib",
           "IMAGINE_INC=#{imagine}/include/smartmet",     "IMAGINE_LIB=#{imagine}/lib",
           "CALCULATOR_INC=#{calculator}/include/smartmet", "CALCULATOR_LIB=#{calculator}/lib",
           "SMARTTOOLS_INC=#{smarttools}/include/smartmet", "SMARTTOOLS_LIB=#{smarttools}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "DC_PREFIX=#{Formula["double-conversion"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}",
           "PNG_PREFIX=#{Formula["libpng"].opt_prefix}",
           "JPEG_PREFIX=#{Formula["jpeg-turbo"].opt_prefix}",
           "BZIP2_PREFIX=#{Formula["bzip2"].opt_prefix}",
           "ECCODES_PREFIX=#{Formula["eccodes"].opt_prefix}",
           "NETCDF_PREFIX=#{Formula["netcdf"].opt_prefix}",
           "NETCDFCXX_PREFIX=#{Formula["netcdf-cxx"].opt_prefix}",
           "HDF5_PREFIX=#{Formula["hdf5"].opt_prefix}"
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
