#!/bin/sh

chmod +x zigqt/usr/local/bin/headless.sh
chmod +x zigqt/etc/init.d/headless
cd zigqt && tar czvf ../zigqt.apkovl.tar.gz *
cd ..
