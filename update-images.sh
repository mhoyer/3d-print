#!/bin/bash

# getting docker tags, see: https://stackoverflow.com/a/39454426
# semver sorting, see: https://stackoverflow.com/a/63027058 

function fetch_tags() {
  image="$1"
  tags=$(wget -q https://registry.hub.docker.com/v1/repositories/${image}/tags -O - \
    | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' \
    | tr '}' '\n' \
    | awk -F: '{print $3}' \
    | grep -E '^[.0-9]+$' \
    | sort -t "." -k1,1n -k2,2n -k3,3n
  )
  latest_tag=$(echo "$tags" | tail -n1)

  echo "found $1:$latest_tag"
  sed -i "s|image: ${1}:.*|image: ${1}:${latest_tag}|g" docker-compose.yml
}

fetch_tags octoprint/octoprint

git diff docker-compose.yml

