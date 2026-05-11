# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryGis < Formula
  desc "FMI smartmet — geospatial utilities (GDAL/GEOS/PROJ wrappers)"
  homepage "https://github.com/fmidev/smartmet-library-gis"
  url "https://github.com/fmidev/smartmet-library-gis.git",
      revision: "db4b3c5a7d1a74344ff1dc6cf44ff421310bebba"
  version "2026.05.10"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-gis-2026.05.10"
    sha256 cellar: :any, arm64_tahoe: "a9cfc1f8f2c1ec169ce19485faae4891fe58f50fac959a05f60931103313d2f5"
  end

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmt"
  depends_on "gdal"
  depends_on "geos"
  depends_on "howard-hinnant-date"
  depends_on "proj"
  depends_on "sqlite"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    # No source patches needed for gis (just exclude EPSGInfo.cpp via Makefile.mac)
    cp "#{tap_patches}/gis.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "MACGYVER_INC=#{macgyver}/include/smartmet",
           "MACGYVER_LIB=#{macgyver}/lib"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"t.cpp").write <<~CPP
      #include <gis/Box.h>
      int main() {
        Fmi::Box b(0,0,1,1,100,100);
        return b.width() == 100 ? 0 : 1;
      }
    CPP
    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    system ENV.cxx, "-std=c++17",
           "-I#{include}/smartmet", "-I#{macgyver}/include/smartmet",
           "-L#{lib}", "-lsmartmet-gis",
           "-Wl,-rpath,#{lib}",
           "-o", "t", "t.cpp"
    system "./t"
  end
end
