#!/usr/bin/env bash

cat header.tmpl server.tmpl footer.tmpl > ../site/server.html

cat header.tmpl powerwall.tmpl footer.tmpl > ../site/powerwall.html

cat header.tmpl index.tmpl footer.tmpl > ../site/index.html
