# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibrarySpine < Formula
  desc "FMI smartmet — core framework: HTTP server, plugins, formatters, caching"
  homepage "https://github.com/fmidev/smartmet-library-spine"
  url "https://github.com/fmidev/smartmet-library-spine.git",
      revision: "299c5ea41bdd1d920b5d0dd495235f9f7a4f57b0"
  version "2026.05.10"
  license "MIT"

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "howard-hinnant-date"
  depends_on "jsoncpp"
  depends_on "libconfig"
  depends_on "libpq"
  depends_on "libpqxx"
  depends_on "mariadb-connector-c"
  depends_on "openssl@3"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/spine-macos.patch"
    cp "#{tap_patches}/spine.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase  = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "JSONCPP_PREFIX=#{Formula["jsoncpp"].opt_prefix}",
           "LIBCONFIG_PREFIX=#{Formula["libconfig"].opt_prefix}",
           "MARIADB_PREFIX=#{Formula["mariadb-connector-c"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "DC_PREFIX=#{Formula["double-conversion"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}",
           "OPENSSL_PREFIX=#{Formula["openssl@3"].opt_prefix}",
           "PQXX_PREFIX=#{Formula["libpqxx"].opt_prefix}",
           "PQ_PREFIX=#{Formula["libpq"].opt_prefix}"

    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-spine.dylib"
    assert_path_exists include/"smartmet/spine/Reactor.h"
  end
end
