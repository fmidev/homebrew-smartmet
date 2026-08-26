# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryImagine < Formula
  desc "FMI smartmet — image generation and rendering"
  homepage "https://github.com/fmidev/smartmet-library-imagine"
  url "https://github.com/fmidev/smartmet-library-imagine.git",
      revision: "2800acf4aafeabf3b63098d55438c7df8144a22d"
  version "2026.05.10"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-library-imagine-2026.05.10"
    sha256 cellar: :any, arm64_tahoe: "768a449a2b0543b332622439000e3bc573e049f4ec1e9e0e72cfdc6240c9514e"
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

    macgyver = formula_opt_prefix("fmidev/smartmet/smartmet-library-macgyver")
    gis      = formula_opt_prefix("fmidev/smartmet/smartmet-library-gis")
    newbase  = formula_opt_prefix("fmidev/smartmet/smartmet-library-newbase")
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "MACGYVER_INC=#{macgyver}/include/smartmet", "MACGYVER_LIB=#{macgyver}/lib",
           "GIS_INC=#{gis}/include/smartmet",           "GIS_LIB=#{gis}/lib",
           "NEWBASE_INC=#{newbase}/include/smartmet",   "NEWBASE_LIB=#{newbase}/lib",
           "BOOST_PREFIX=#{formula_opt_prefix("boost")}",
           "FMT_PREFIX=#{formula_opt_prefix("fmt")}",
           "GDAL_PREFIX=#{formula_opt_prefix("gdal")}",
           "DC_PREFIX=#{formula_opt_prefix("double-conversion")}",
           "DATE_PREFIX=#{formula_opt_prefix("howard-hinnant-date")}",
           "PNG_PREFIX=#{formula_opt_prefix("libpng")}",
           "JPEG_PREFIX=#{formula_opt_prefix("jpeg-turbo")}",
           "FT_PREFIX=#{formula_opt_prefix("freetype")}"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_path_exists lib/"libsmartmet-imagine.dylib"
  end
end
