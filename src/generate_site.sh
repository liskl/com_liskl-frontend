#!/usr/bin/env bash

cat header.tmpl server.tmpl footer.tmpl > ../site/server.html

cat header.tmpl powerwall.tmpl footer.tmpl > ../site/powerwall.html

cat header.tmpl index.tmpl footer.tmpl > ../site/index.html

cat header.tmpl email.tmpl footer.tmpl > ../site/email.html

cat header.tmpl gallery-liskl-networks-datacenter.tmpl footer.tmpl > ../site/gallery/liskl-networks-datacenter.html

cat header.tmpl flashpaper.tmpl footer.tmpl > ../site/flashpaper.html

cat header.tmpl plex-db-analyzer.tmpl footer.tmpl > ../site/plex-db-analyzer.html

cat header.tmpl video-ingestion.tmpl footer.tmpl > ../site/video-ingestion.html

cat header.tmpl coolledux.tmpl footer.tmpl > ../site/coolledux.html

cat header.tmpl storage-inventory.tmpl footer.tmpl > ../site/storage-inventory.html

cat header.tmpl claude-marketplace.tmpl footer.tmpl > ../site/claude-marketplace.html

cat header.tmpl shard.tmpl footer.tmpl > ../site/shard.html
