# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibrarySmarttools < Formula
  desc "FMI smartmet — interpreter and helper utilities for newbase data"
  homepage "https://github.com/fmidev/smartmet-library-smarttools"
  url "https://github.com/fmidev/smartmet-library-smarttools.git",
      revision: "04aeeb29917b76e497ba8e0cc5feed991405b951"
  version "2026.05.08"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-smarttools-2026.05.08"
    sha256 cellar: :any, arm64_tahoe: "a7a6e1896c16bec8a3913fd394511aa04e21c13f058ebff39ddf61f56cddafab"
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
    system "patch", "-p1", "-i", "#{tap_patches}/smarttools-macos.patch"
    cp "#{tap_patches}/smarttools.Makefile.mac", "Makefile.mac"

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
    assert_path_exists lib/"libsmartmet-smarttools.dylib"
  end
end
