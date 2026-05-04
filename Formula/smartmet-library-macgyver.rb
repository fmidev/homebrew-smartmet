class SmartmetLibraryMacgyver < Formula
  desc "FMI smartmet — foundational utility library"
  homepage "https://github.com/fmidev/smartmet-library-macgyver"
  url "https://github.com/fmidev/smartmet-library-macgyver.git",
      revision: "73de27ea386d6334abb87f24723816bfbce8f913"
  version "2026.03.24"
  license "MIT"

  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmt"
  depends_on "howard-hinnant-date"

  # Optional: PostgreSQL support (off by default — enable with --with-postgres)
  option "with-postgres", "Build PostgreSQLConnection (requires libpqxx)"
  depends_on "libpqxx" => :optional

  def install
    # Apply macOS portability patch
    tap_patches = Tap.fetch("fmidev/smartmet").path/"patches"
    system "patch", "-p1", "-i", "#{tap_patches}/macgyver-macos.patch"

    # Drop in the portable Makefile.mac from the tap
    cp "#{tap_patches}/macgyver.Makefile.mac", "Makefile.mac"

    args = ["-f", "Makefile.mac", "-j#{ENV.make_jobs}"]
    args << "WITH_POSTGRES=1" if build.with?("postgres")
    system "make", *args

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
