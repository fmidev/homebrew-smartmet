# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetTimezones < Formula
  desc "FMI smartmet — timezone region/coordinate data files"
  homepage "https://github.com/fmidev/smartmet-timezones"
  url "https://github.com/fmidev/smartmet-timezones.git",
      revision: "f8a4b1d6a110db9083aa86bf28258a935e46064e"
  version "2026.05.04"
  license "MIT"

  def install
    (share/"smartmet/timezones").install "share/timezone.shz"
    (share/"smartmet/timezones").install "share/date_time_zonespec.csv"
  end

  test do
    assert_path_exists share/"smartmet/timezones/timezone.shz"
    assert_path_exists share/"smartmet/timezones/date_time_zonespec.csv"
  end
end
