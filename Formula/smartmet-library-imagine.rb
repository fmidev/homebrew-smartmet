# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryImagine < Formula
  desc "FMI smartmet — image generation and rendering"
  homepage "https://github.com/fmidev/smartmet-library-imagine"
  url "https://github.com/fmidev/smartmet-library-imagine.git",
      revision: "0e24d19f00cdfbf5557d766eb0d18fa6b9879994"
  version "2026.02.04"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-imagine-2026.02.04"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe: "83d57c7979e814652ac0138511feb4fe636a51bad6c620fb170a1ebc2b5fc54c"
  end

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-library-gis"
  depends_on "fmidev/smartmet/smartmet-library-macgyver"
  depends_on "fmidev/smartmet/smartmet-library-newbase"
  depends_on "fmt"
  depends_on "freetype"
  depends_on "gdal"
  depends_on "howard-hinnant-date"
  depends_on "jpeg-turbo"
  depends_on "libpng"

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    cp "#{tap_patches}/imagine.Makefile.mac", "Makefile.mac"

    macgyver = Formula["fmidev/smartmet/smartmet-library-macgyver"].opt_prefix
    gis      = Formula["fmidev/smartmet/smartmet-library-gis"].opt_prefix
    newbase  = Formula["fmidev/smartmet/smartmet-library-newbase"].opt_prefix
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib",
           "BOOST_PREFIX=#{Formula["boost"].opt_prefix}",
           "FMT_PREFIX=#{Formula["fmt"].opt_prefix}",
           "GDAL_PREFIX=#{Formula["gdal"].opt_prefix}",
           "DC_PREFIX=#{Formula["double-conversion"].opt_prefix}",
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}",
           "PNG_PREFIX=#{Formula["libpng"].opt_prefix}",
           "JPEG_PREFIX=#{Formula["jpeg-turbo"].opt_prefix}",
           "FT_PREFIX=#{Formula["freetype"].opt_prefix}"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-imagine.dylib"
  end
end
