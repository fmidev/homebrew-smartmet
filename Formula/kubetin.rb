# Prebuilt binaries from the upstream release — unlike the smartmet
# formulae in this tap, there is nothing to compile and no bottle to
# publish. kubetin ships static Go binaries with no runtime dependencies
# beyond a kubeconfig.
class Kubetin < Formula
  desc "Multi-cluster Kubernetes terminal monitor"
  homepage "https://github.com/fmidev/kubetin"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Apple Silicon only, matching the rest of this tap. Upstream gained a
  # darwin-amd64 target after v1.6.0; add an `on_intel` block here once a
  # release carrying it exists.
  on_macos do
    on_arm do
      url "https://github.com/fmidev/kubetin/releases/download/v1.6.0/kubetin-v1.6.0-darwin-arm64.tar.gz"
      sha256 "c174e70104f6ce43740f954f306e3befbb6b15b088d432f84e80454050d97f5b"
    end
  end

  def install
    bin.install "kubetin"
    prefix.install "LICENSE", "README.md"
  end

  test do
    # -version prints and exits without entering the TUI, so it is safe
    # to run headless under test-bot.
    assert_match version.to_s, shell_output("#{bin}/kubetin -version")

    # With no kubeconfig at all, kubetin should fail cleanly rather than
    # hang waiting on a terminal.
    ENV["KUBECONFIG"] = testpath/"nonexistent"
    assert_match(/kubeconfig|context/i, shell_output("#{bin}/kubetin -trust 2>&1", 1))
  end
end
