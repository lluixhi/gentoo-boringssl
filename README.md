# BoringSSL

This is an experimental overlay for building the Gentoo tree with BoringSSL
instead of LibreSSL or OpenSSL!

NOTE: This will most likely never be supported by upstream, which explicitly
says that BoringSSL should not be used as a system provider.

## How to install the overlay

With paludis: see [Paludis repository configuration](http://paludis.exherbo.org/configuration/repositories/index.html)

With layman:
```
layman -f -o https://raw.githubusercontent.com/lluixhi/gentoo-boringssl/master/boringssl-overlay.xml -a boringssl
```
