# encoding: UTF-8
require "formula"

class Yaz < Formula
  homepage "http://www.indexdata.com/yaz"
  url "http://ftp.indexdata.dk/pub/yaz/yaz-5.4.2.tar.gz"
  sha1 "2d64a212481ffaa1afbb15b9fbdc7cc7c9068ca7"

  bottle do
    cellar :any
    sha1 "849a16244770beb4c81bc041e6b1a18c98319e03" => :mavericks
    sha1 "9a59e1db4ece4e96748c5fc33a1428b0ee8d78af" => :mountain_lion
    sha1 "56bcb0632a14290463789ba1ebe74ac5a6f319e6" => :lion
  end

  depends_on "pkg-config" => :build
  depends_on "gnutls" => :optional

  option "without-icu", "Build without ICU support and dependency on icu4c"
  if build.with? "icu"
    depends_on "icu4c"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-xml2"
    system "make install"
  end

  test do
    # This test converts between MARC8, an obscure mostly-obsolete library
    # text encoding supported by yaz-iconv, and UTF8.
    File.open("marc8.txt", "w") do |f|
      f.write "$1!0-!L,i$3i$si$Ki$Ai$O!+=(B"
    end
    result = `"#{bin}/yaz-iconv" -f marc8 -t utf8 marc8.txt`.chomp
    result.force_encoding(Encoding::UTF_8) if result.respond_to?(:force_encoding)
    assert_equal "世界こんにちは！", result

    # Test ICU support if building with ICU by running yaz-icu
    # with the example icu_chain from its man page.
    if build.with? "icu"
      # The input string should be transformed to be:
      # * without control characters (tab)
      # * split into tokens at word boundaries (including -)
      # * without whitespace and Punctuation
      # * xy transformed to z
      # * lowercase
      configuration = <<-EOS.undent
        <?xml version="1.0" encoding="UTF-8"?>
        <icu_chain locale="en">
          <transform rule="[:Control:] Any-Remove"/>
          <tokenize rule="w"/>
          <transform rule="[[:WhiteSpace:][:Punctuation:]] Remove"/>
          <transliterate rule="xy > z;"/>
          <display/>
          <casemap rule="l"/>
        </icu_chain>
      EOS

      input = "yaz-ICU	xy!"
      expectedresult = <<-EOS.undent
        1 1 'yaz' 'yaz'
        2 1 '' ''
        3 1 'icuz' 'ICUz'
        4 1 '' ''
      EOS

      configurationfile = (testpath/"icu-chain.xml")
      File.open(configurationfile, "w") { |f| f.write(configuration) }
      inputfile = (testpath/"icu-test.txt")
      File.open(inputfile, "w") { |f| f.write(input) }

      command = "#{bin}/yaz-icu -c #{configurationfile} #{inputfile}"
      result = `#{command}`
      assert_equal expectedresult, result
    end
  end
end
