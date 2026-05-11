# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetTimezones < Formula
  desc "FMI smartmet — timezone region/coordinate data files"
  homepage "https://github.com/fmidev/smartmet-timezones"
  url "https://github.com/fmidev/smartmet-timezones.git",
      revision: "ce9cf08f9906e3963044d12cbea4ea1abd0b2cfd"
  version "2026.05.11"
  license "MIT"

  bottle do
    root_url "https://github.com/fmidev/homebrew-smartmet/releases/download/smartmet-timezones-2026.05.04"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "8c9f9243829e461d9cb72189864f4eb916100ffedfa7093140eee3e6063aa068"
  end

  def install
    (share/"smartmet/timezones").install "share/timezone.shz"
    (share/"smartmet/timezones").install "share/date_time_zonespec.csv"
  end

  test do
    assert_path_exists share/"smartmet/timezones/timezone.shz"
    assert_path_exists share/"smartmet/timezones/date_time_zonespec.csv"
  end
end
