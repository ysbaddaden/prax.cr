# Prax

Rack proxy server for development

This is an attempt to rewrite [Prax](https://github.com/ysbaddaden/prax) in
[Crystal](http://crystal-lang.org), a Ruby-inspired language that compiles
down to C. This should avoid problems with version managers, since Prax would
now be a binary application, yet remain as easily hackable as a Ruby
application, along with better performances (yay!).

This is in "working" state!

Lot of work is still required: evented or thread pool of incoming requests,
keepalive connections, proxying websockets, SSL server, etc.

## License

Prax is distributed under the [CeCILL 2.1 license](http://www.cecill.info).
Please see LICENSE for details.

HTML templates for rendering errors are from [Pow!!](http://pow.cx/), by Sam
Stephenson and Basecamp, and are under the
[MIT license](http://www.opensource.org/licenses/MIT).

## Authors

- Julien Portalier <julien@portalier.com>
