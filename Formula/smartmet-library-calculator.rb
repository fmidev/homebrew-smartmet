# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryCalculator < Formula
  desc "FMI smartmet — weather analysis calculator framework"
  homepage "https://github.com/fmidev/smartmet-library-calculator"
  url "https://github.com/fmidev/smartmet-library-calculator.git",
      revision: "dadd227e21847e5640dc195e96f180f9e8a41ea5"
  version "2026.02.04"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-calculator-2026.02.04"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe: "c6fd3a736f6e58ef30c729e3173832eeee248ca0c0e7a315d0f3d8dbd7adc52b"
  end

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "howard-hinnant-date"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    cp "#{tap_patches}/calculator.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase  = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-calculator.dylib"
  end
end
