# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
#
# GSHHG (Global Self-consistent Hierarchical High-resolution Geography)
# coastline / border / river data in GMT's binned NetCDF-4 format. Used by
# smartmet-qdless for its terminal coastline overlay. Mirrors the Fedora
# `gshhg-gmt-nc4` RPM convention (data under /usr/share/gshhg-gmt-nc4/).
class GshhgGmtNc4 < Formula
  desc "GSHHG coastline / border / river data in GMT binned NetCDF-4 format"
  homepage "https://www.soest.hawaii.edu/pwessel/gshhg/"
  url "https://github.com/GenericMappingTools/gshhg-gmt/releases/download/2.3.7/gshhg-gmt-2.3.7.tar.gz"
  sha256 "9bb1a956fca0718c083bef842e625797535a00ce81f175df08b042c2a92cfe7f"
  license "LGPL-3.0-or-later"

  def install
    target = share/"gshhg-gmt-nc4"
    target.install Dir["binned_*.nc"]
    target.install "README.TXT", "LICENSE.TXT", "COPYINGv3", "COPYING.LESSERv3"
  end

  test do
    %w[binned_GSHHS_c.nc binned_border_c.nc binned_river_c.nc].each do |f|
      assert_path_exists share/"gshhg-gmt-nc4"/f
    end
  end
end
