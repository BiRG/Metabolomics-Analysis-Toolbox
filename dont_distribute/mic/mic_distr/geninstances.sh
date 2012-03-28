#!/bin/bash
mkdir -p instances
rels=`java -jar distr.jar listrelations | tail -n+2 | cut -f2`
for r in $rels; do
    java -jar distr.jar geninstance $r 1000 0.01 0.01 | tail -n+2 > instances/$r.1000.txt
done