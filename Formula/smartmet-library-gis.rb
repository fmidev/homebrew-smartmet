class SmartmetLibraryGis < Formula
  desc "FMI smartmet — geospatial utilities (GDAL/GEOS/PROJ wrappers)"
  homepage "https://github.com/fmidev/smartmet-library-gis"
  url "https://github.com/fmidev/smartmet-library-gis.git",
      revision: "5b339fd33f3f6bdff856b33a60224f81c8e755bc"
  version "2026.04.02"
  license "MIT"

  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "boost"
  depends_on "double-conversion"
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
