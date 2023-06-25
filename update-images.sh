#!/bin/bash

# getting docker tags, see: https://stackoverflow.com/a/39454426
# semver sorting, see: https://stackoverflow.com/a/63027058 

function fetch_tags() {
  image="$1"
  docker_response=$(wget -q https://registry.hub.docker.com/v2/repositories/${image}/tags?page_size=30 -O -)
  tags=$(echo "${docker_response}" \
    | jq -r '.results[].name' \
    | grep -E '^[0-9]+\.[0-9]+$' \
    | sort -t "." -k1,1n -k2,2n -k3,3n
  )
  latest_tag=$(echo "$tags" | tail -n1)

  if [ -z "$latest_tag" ]; then
    echo "${docker_response}"
    echo
    echo "Unable to extract a matching tag from response above from https://registry.hub.docker.com/v1/repositories/${image}/tags."
    exit 1
  fi

  echo "found $1:$latest_tag"
  sed -i "s|image: ${1}:.*|image: ${1}:${latest_tag}|g" docker-compose.yaml
}

fetch_tags octoprint/octoprint

git diff docker-compose.yaml

