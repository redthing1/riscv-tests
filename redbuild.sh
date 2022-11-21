#!/usr/bin/env bash

set -e # exit on error
if [ -n "$DEBUG" ]; then
    # echo all commands in debug mode
    set -x
fi

print_logo() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
}
# print_logo
print_info() {
    echo "REDBUILD v2.0.0"
    echo " container engine: $CONTAINER_ENGINE"
    printf " host: $(uname -s)/$(uname -m) $(uname -r)\n"
    printf "\n"
}

testcmd () {
    command -v "$1" >/dev/null
}

# detect container engine, prefer podman but fall back to docker
CONTAINER_ENGINE="unknown-container-engine"
detect_container_engine() {
    if testcmd podman; then
        CONTAINER_ENGINE="podman"
    elif testcmd docker; then
        CONTAINER_ENGINE="docker"
    else
        echo "ERROR: no suitable container engine found. please install podman or docker."
        exit 1
    fi
}

detect_container_engine
print_info

export BUILDER_TAG=builder_$(head /dev/urandom | tr -dc a-z0-9 | head -c10) # random tag to avoid name collisions

# build the builder image
build_builder_image() {
    printf "building builder image [tag: $BUILDER_TAG]...\n"
    $CONTAINER_ENGINE build -t $BUILDER_TAG -f build.docker | sed 's/^/  /'
}
# run the build inside the builder image
run_build() {
    printf "running build in builder image [tag: $BUILDER_TAG]...\n"
    $CONTAINER_ENGINE run --rm -it -v $(pwd):/prj $BUILDER_TAG /bin/bash -l -c "cd /prj && ./build.sh" | sed 's/^/  /'
}

build_builder_image
run_build