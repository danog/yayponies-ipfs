#!/bin/bash
cd $1/ypmirror
git reset --hard
git pull origin master

for f in $(find . -type f -name '*.php'); do
    curl "$2/$f" -so $f
done

cd ..
hash=$(ipfs name publish /ipfs/$(ipfs add -r ypmirror/ | sed '/ ypmirror$/!d;s/added //;s/ .*//g') | sed 's/:.*//g;s/Published to //g')
echo "Create a DNS TXT record with value dnslink=/ipfs/$hash and name _dnslink.domain.name.
Then configure it using https://www.cloudflare.com/distributed-web-gateway

Enjoy!

~Daniil Gentili"

