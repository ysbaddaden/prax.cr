# Prax

Rack proxy server for development

This is an attempt to rewrite [Prax](https://github.com/ysbaddaden/prax) in
[Crystal](http://crystal-lang.org), a Ruby-inspired language that compiles
down to C. This should avoid problems with version managers, since Prax would
now be a binary application, yet remain as easily hackable as a Ruby
application, along with better performances (yay!).

This is actually mostly a stub, since the Crystal stdlib is still missing some
requirements (UNIXSocket, OpenSSL::SSL::SSLServer, Process.kill, Process.spawn)
which I'm implementing along the way.

## License

Prax is distributed under the [CeCILL 2.1 license](http://www.cecill.info).
Please see LICENSE for details.

## Authors

- Julien Portalier <julien@portalier.com>
