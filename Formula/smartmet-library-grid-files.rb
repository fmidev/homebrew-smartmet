# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryGridFiles < Formula
  desc "FMI smartmet — unified GRIB1/GRIB2/NetCDF/QueryData reader library"
  homepage "https://github.com/fmidev/smartmet-library-grid-files"
  url "https://github.com/fmidev/smartmet-library-grid-files.git",
      revision: "ae2db04aa9c52b6ef7f998c5d5eb85b5cfe44fb7"
  version "2026.05.27"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-grid-files-2026.05.27"
    sha256 cellar: :any, arm64_tahoe: "1927cd8a7775f6466751e61a16b05d25f1c0e1fd9c6ecc1cbab2a010f4a9e9be"
  end

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

    macgyver = formula_opt_prefix("fmidev/smartmet/smartmet-library-macgyver")
    gis      = formula_opt_prefix("fmidev/smartmet/smartmet-library-gis")
    newbase  = formula_opt_prefix("fmidev/smartmet/smartmet-library-newbase")
    spine    = formula_opt_prefix("fmidev/smartmet/smartmet-library-spine")
    trax     = formula_opt_prefix("fmidev/smartmet/smartmet-library-trax")

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib",
           "SPINE_INC=#{spine}/include/smartmet",       "SPINE_LIB=#{spine}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "TRAX_INC=#{trax}/include/smartmet",         "TRAX_LIB=#{trax}/lib",
           "BOOST_PREFIX=#{formula_opt_prefix("boost")}",
           "FMT_PREFIX=#{formula_opt_prefix("fmt")}",
           "GDAL_PREFIX=#{formula_opt_prefix("gdal")}",
           "GEOS_PREFIX=#{formula_opt_prefix("geos")}",
           "CURL_PREFIX=#{formula_opt_prefix("curl")}",
           "JPEG_PREFIX=#{formula_opt_prefix("jpeg-turbo")}",
           "PNG_PREFIX=#{formula_opt_prefix("libpng")}",
           "WEBP_PREFIX=#{formula_opt_prefix("webp")}",
           "OPENJPEG_PREFIX=#{formula_opt_prefix("openjpeg")}",
           "AEC_PREFIX=#{formula_opt_prefix("libaec")}",
           "OPENSSL_PREFIX=#{formula_opt_prefix("openssl@3")}",
           "DATE_PREFIX=#{formula_opt_prefix("howard-hinnant-date")}"

    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-grid-files.dylib"
    assert_path_exists include/"smartmet/grid-files/grid/GridFile.h"
  end
end
