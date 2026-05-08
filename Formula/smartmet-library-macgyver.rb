# Built by fmidev/homebrew-smartmet for macOS only — see README for details.
class SmartmetLibraryMacgyver < Formula
  desc "FMI smartmet — foundational utility library"
  homepage "https://github.com/fmidev/smartmet-library-macgyver"
  url "https://github.com/fmidev/smartmet-library-macgyver.git",
      revision: "bc6bb9b6a5d775b0bcf27f9e5bc1b887ebaafc34"
  version "2026.05.08"
  license "MIT"

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmidev/smartmet/smartmet-timezones"
  depends_on "fmt"
  depends_on "howard-hinnant-date"
  depends_on "libpq"
  depends_on "libpqxx"

  def install
    # Apply macOS portability patch
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/macgyver-macos.patch"

    # Drop in the portable Makefile.mac from the tap
    cp "#{tap_patches}/macgyver.Makefile.mac", "Makefile.mac"

    tz = Formula["fmidev/smartmet/smartmet-timezones"].opt_share/"smartmet/timezones"
    system "make", "-f", "Makefile.mac", "-j#{ENV.make_jobs}",
           "WITH_POSTGRES=1", "TIMEZONES_DIR=#{tz}"
    system "make", "-f", "Makefile.mac", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"t.cpp").write <<~CPP
      #include <macgyver/Hash.h>
      #include <iostream>
      int main() {
        auto h = Fmi::hash_value(std::string("hello"));
        std::cout << h << std::endl;
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17",
           "-I#{include}/smartmet",
           "-L#{lib}", "-lsmartmet-macgyver",
           "-Wl,-rpath,#{lib}",
           "-o", "t", "t.cpp"
    system "./t"
  end
end
