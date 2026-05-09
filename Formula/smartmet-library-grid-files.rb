# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryGridFiles < Formula
  desc "FMI smartmet — unified GRIB1/GRIB2/NetCDF/QueryData reader library"
  homepage "https://github.com/fmidev/smartmet-library-grid-files"
  url "https://github.com/fmidev/smartmet-library-grid-files.git",
      revision: "60b95067c09fb9b268e1432147cd553007171d89"
  version "2026.05.08.1"
  license "MIT"

  # macOS port note: Linux's userfaultfd memory-mapper path is disabled via
  # SMARTMET_NO_USERFAULTFD; local files still work via boost::iostreams::
  # mapped_file. Remote (S3/HTTP) lazy paging is not available — load whole
  # files instead.

  depends_on "boost"
  depends_on "curl"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmidev/smartmet/smartmet-library-spine"
  depends_on "fmidev/smartmet/smartmet-library-trax"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "geos"
  depends_on "howard-hinnant-date"
  depends_on "jpeg-turbo"
  depends_on "libaec"
  depends_on "libpng"
  depends_on "openjpeg"
  depends_on "openssl@3"
  depends_on "webp"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/grid-files-macos.patch"
    cp "#{tap_patches}/grid-files.Makefile.mac", "Makefile.mac"
    cp "#{tap_patches}/grid-files.macos-prelude.h", "macos-prelude.h"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase  = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    spine    = Formula["fmidev/smartmet/smartmet-library-spine"].opt_prefix
    trax     = Formula["fmidev/smartmet/smartmet-library-trax"].opt_prefix

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib",
           "SPINE_INC=#{spine}/include/smartmet",       "SPINE_LIB=#{spine}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "TRAX_INC=#{trax}/include/smartmet",         "TRAX_LIB=#{trax}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "GEOS_PREFIX=#{Formula["geos"].opt_prefix}",
           "CURL_PREFIX=#{Formula["curl"].opt_prefix}",
           "JPEG_PREFIX=#{Formula["jpeg-turbo"].opt_prefix}",
           "PNG_PREFIX=#{Formula["libpng"].opt_prefix}",
           "WEBP_PREFIX=#{Formula["webp"].opt_prefix}",
           "OPENJPEG_PREFIX=#{Formula["openjpeg"].opt_prefix}",
           "AEC_PREFIX=#{Formula["libaec"].opt_prefix}",
           "OPENSSL_PREFIX=#{Formula["openssl@3"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}"

    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-grid-files.dylib"
    assert_path_exists include/"smartmet/grid-files/grid/GridFile.h"
  end
end
