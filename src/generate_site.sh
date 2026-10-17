#!/usr/bin/env bash

cat header.tmpl server.tmpl footer.tmpl > ../site/server.html

cat header.tmpl powerwall.tmpl footer.tmpl > ../site/powerwall.html

cat header.tmpl index.tmpl footer.tmpl > ../site/index.html

cat header.tmpl email.tmpl footer.tmpl > ../site/email.html

cat header.tmpl gallery-liskl-networks-datacenter.tmpl footer.tmpl > ../site/gallery/liskl-networks-datacenter.html

cat header.tmpl flashpaper.tmpl footer.tmpl > ../site/flashpaper.html

cat header.tmpl plex-db-analyzer.tmpl footer.tmpl > ../site/plex-db-analyzer.html
