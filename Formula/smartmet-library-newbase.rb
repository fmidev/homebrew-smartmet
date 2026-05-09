# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryNewbase < Formula
  desc "FMI smartmet — querydata, projections, and core data structures"
  homepage "https://github.com/fmidev/smartmet-library-newbase"
  url "https://github.com/fmidev/smartmet-library-newbase.git",
      revision: "574bd90bc526ec0b4e8d41b3d87a910eff4c7edf"
  version "2026.05.10"
  license "MIT"

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "howard-hinnant-date"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/newbase-macos.patch"
    cp "#{tap_patches}/newbase.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"t.cpp").write <<~CPP
      #include <newbase/NFmiPoint.h>
      int main() { NFmiPoint p(1,2); return p.X() == 1 ? 0 : 1; }
    CPP
    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    system ENV.cxx, "-std=c++17",
           "-I#{include}/smartmet",
           "-I#{macgyver}/include/smartmet",
           "-I#{gis}/include/smartmet",
           "-L#{lib}", "-lsmartmet-newbase",
           "-Wl,-rpath,#{lib}",
           "-o", "t", "t.cpp"
    system "./t"
  end
end
