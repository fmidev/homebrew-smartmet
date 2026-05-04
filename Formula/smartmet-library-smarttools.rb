class SmartmetLibrarySmarttools < Formula
  desc "FMI smartmet — interpreter and helper utilities for newbase data"
  homepage "https://github.com/fmidev/smartmet-library-smarttools"
  url "https://github.com/fmidev/smartmet-library-smarttools.git",
      revision: "a558a7f2774b71e36d40ddf2febbeac7e432e490"
  version "2026.02.04"
  license "MIT"

  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "boost"
  depends_on "double-conversion"
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
    assert_predicate lib/"libsmartmet-smarttools.dylib", :exist?
  end
end
