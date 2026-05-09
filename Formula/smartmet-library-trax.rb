# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryTrax < Formula
  desc "FMI smartmet — contouring / isoline-tracing library"
  homepage "https://github.com/fmidev/smartmet-library-trax"
  url "https://github.com/fmidev/smartmet-library-trax.git",
      revision: "824042e13eb9058659659a2d740b318939b6fe64"
  version "2026.05.10"
  license "MIT"

  depends_on "boost"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "geos"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    cp "#{tap_patches}/trax.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix

    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "PREFIX=#{prefix}",
           "MACGYVER_INC=#{macgyver}/include", "MACGYVER_LIB=#{macgyver}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "GEOS_PREFIX=#{Formula["geos"].opt_prefix}"

    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-trax.dylib"
    assert_path_exists include/"smartmet/trax/Contour.h"
  end
end
