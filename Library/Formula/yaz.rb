require 'formula'

class Yaz < Formula
  homepage 'http://www.indexdata.com/yaz'
  url 'http://ftp.indexdata.dk/pub/yaz/yaz-5.0.14.tar.gz'
  sha1 'a599f37cbbb91703c934f0207a346dd3a1cf9a5a'
  head 'git://git.indexdata.com/yaz.git'
  
  depends_on 'pkg-config' => :build
  depends_on 'gnutls' => :build
  depends_on 'libmemcached' => :build
  depends_on 'libgcrypt' => :build

  def install
    system "./buildconf.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-xml2"
    system "make install"
  end
end
