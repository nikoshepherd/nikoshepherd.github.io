#!/bin/sh
echo $GPG_PRIVATE_KEY | base64 -d | gpg --import
gpg --output site.tgz --decrypt site.tgz.gpg && rm site.tgz.gpg
tar -xvf site.tgz && rm site.tgz