# NSSwitch hosts resolver plugin

Allows software that rely on NSSwitch to resolve domains for Prax (like
myapp.test). Command line software like `host` and `dig` won't resolve the
address, but `getent` will.

## Install

Compile, copy or link the shared object to `/lib` and add `prax` to the `hosts`
line of `/etc/nsswitch.conf`, and eventually restart your browser (this is
required).

    $ cd ext/
    $ make
    $ sudo make install
    $ sudo vi /etc/nsswitch.conf

    hosts: files mdns4_minimal [NOTFOUND=return] prax dns mdns4

Do not change the whole line to look like this, just add prax before `dns`.

## Credits

Code is from hoof by pyromaniac at https://github.com/poyromaniac/hoof and
distributed under the MIT licence.

Tweaked by Julien Portalier to parse the `PRAX_DOMAINS` environment variable
for extensions to serve.
