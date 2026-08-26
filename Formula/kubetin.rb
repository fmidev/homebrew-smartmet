# Prebuilt binaries from the upstream release — unlike the smartmet
# formulae in this tap, there is nothing to compile and no bottle to
# publish. kubetin ships static Go binaries with no runtime dependencies
# beyond a kubeconfig.
class Kubetin < Formula
  desc "Multi-cluster Kubernetes terminal monitor"
  homepage "https://github.com/fmidev/kubetin"
  url "https://github.com/fmidev/kubetin/releases/download/v1.6.0/kubetin-v1.6.0-darwin-arm64.tar.gz"
  sha256 "c174e70104f6ce43740f954f306e3befbb6b15b088d432f84e80454050d97f5b"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Apple Silicon only, matching the rest of this tap.
  #
  # Scoped with depends_on rather than wrapping the url in on_arm:
  # Homebrew evaluates the formula for every macOS version and arch, and
  # an arch-only url leaves it with none at all on Intel — test-bot
  # rejects that as "formula requires at least a URL". This way Intel
  # gets a clear refusal instead of an invalid formula.
  #
  # Upstream is adding a darwin-amd64 target; once a release carries one,
  # these become on_arm/on_intel url blocks and the arch line goes away.
  depends_on arch: :arm64
  depends_on :macos

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
