# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetGdalQuerydataDriver < Formula
  desc "FMI smartmet — GDAL driver plugin for QueryData (.sqd, .fqd) raster files"
  homepage "https://github.com/fmidev/smartmet-gdal-querydata-driver"
  url "https://github.com/fmidev/smartmet-gdal-querydata-driver.git",
      revision: "b858129fd1ab206d4e1698aab48cdf33810d4c5f"
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

  def install
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    cp "#{tap_patches}/gdal-querydata-driver.Makefile.mac", "Makefile.mac"

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
           "DATE_PREFIX=#{Formula["howard-hinnant-date"].opt_prefix}"

    # Install into the formula's own lib/gdalplugins. Homebrew's link step
    # auto-symlinks lib/** into HOMEBREW_PREFIX/lib/**, so the plugin lands
    # at HOMEBREW_PREFIX/lib/gdalplugins/gdal_querydata.dylib — exactly where
    # Homebrew's GDAL looks. The Makefile.mac install target also handles
    # ad-hoc codesigning (macOS hardened runtime SIGKILLs unsigned dylibs
    # loaded into signed processes).
    system "make", "-f", "Makefile.mac", "install",
           "PREFIX=#{prefix}", "GDAL_PLUGIN_DIR=#{lib}/gdalplugins"
  end

  def caveats
    <<~EOS
      The plugin is installed at:
        #{opt_lib}/gdalplugins/gdal_querydata.dylib
      and symlinked under:
        #{HOMEBREW_PREFIX}/lib/gdalplugins/gdal_querydata.dylib

      Homebrew's GDAL does NOT scan #{HOMEBREW_PREFIX}/lib/gdalplugins by
      default — it only looks inside its own Cellar. To make gdalinfo /
      gdal_translate / gdalwarp pick the plugin up, point GDAL_DRIVER_PATH
      at the Homebrew plugin dir (one-time, add to your shell rc):

        echo 'export GDAL_DRIVER_PATH="$(brew --prefix)/lib/gdalplugins"' \\
            >> ~/.zshrc
        source ~/.zshrc

      Then verify:
        gdalinfo --formats | grep querydata
        # → querydata -raster,multidimensional raster- (rws): FMI QueryData (*.sqd, *.fqd)

      For QGIS (which bundles its own GDAL), set the same variable via
      Settings → Options → System → Environment and restart QGIS. See the
      upstream README for the full QGIS workflow:
        https://github.com/fmidev/smartmet-gdal-querydata-driver
    EOS
  end

  test do
    system "gdalinfo", "--formats"
    assert_path_exists HOMEBREW_PREFIX/"lib/gdalplugins/gdal_querydata.dylib"
  end
end
