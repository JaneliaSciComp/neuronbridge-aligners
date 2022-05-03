#!/bin/bash

SUDO=
DOCKER=docker

COMMANDS=$1
CMDARR=(${COMMANDS//+/ })
shift 1 # remove command parameter from args

container_names="${@}"

helpmsg="
$0 COMMAND <containers>
$0 help

where COMMAND is one of {build,push} 
"

function findContainerDirs {
    local _name="$1"

    container_dirs=()
    for i in $(find . -name "${_name}" );  do
        if [[ -f ${i}/Dockerfile ]]; then
            container_dirs+=("${i}")
            break
        else
            for containerDir in $(find "${i}" -name "Dockerfile");  do
                container_dirs+=($(dirname "${containerDir}"))
            done
        fi
    done
    if [[ -z ${container_dirs} ]]; then
        echo "No container directory was found for ${container_name}"
        exit 1
    fi
}

function readNamespaces {
    namespaces=()
    if [[ -e ".env" ]] ; then
        source .env
        namespaces=($(awk '/NAMESPACE=/ { print(substr($1,11))}' .env))
            for t in ${local_container_tags[@]}; do
                $SUDO $DOCKER push ${t}
            done

    fi
}

function buildContainer() {
    local _name=$1

    findContainerDirs "${_name}"

    for cdir in ${container_dirs[@]}; do
        local container_name=$(basename "$cdir")
        echo "Build $container_name in $cdir"

        local BUILD_ARGS=""
        local NAME=""

        if [[ -e "${cdir}/NAME" ]]; then
            NAME=$(cat "${cdir}/NAME")
        else
            NAME="${container_name}:latest"
        fi

        if [[ ${#namespaces[@]} -gt 0 ]]; then
            for ns in ${namespaces[@]}; do
                BUILD_ARGS="${BUILD_ARGS} -t ${ns}/${NAME}"
            done
        else
            BUILD_ARGS="${BUILD_ARGS} -t ${NAME}"
        fi

        $SUDO $DOCKER build $BUILD_ARGS $cdir
    done
}

function pushContainer() {
    local _name="$1"

    findContainerDirs "${_name}"

    for cdir in ${container_dirs[@]}; do
        local NAME=""

        if [[ -e "${cdir}/NAME" ]]; then
            NAME=$(cat "${cdir}/NAME")
        else
            NAME="${container_name}:latest"
        fi

        if [[ ${#namespaces[@]} -gt 0 ]]; then
            for ns in ${namespaces[@]}; do
                $SUDO $DOCKER push "${ns}/${NAME}"
            done
        fi
    done
}

if [[ ${#@} -eq 0 ]] ; then
    echo $helpmsg
    exit 1
fi

readNamespaces

for COMMAND in "${CMDARR[@]}" ; do
    case ${COMMAND} in
        build)
            for container_name in "${container_names[@]}"; do
                buildContainer ${container_name}
            done
            ;;

        push)
            for container_name in "${container_names[@]}"; do
                pushContainer ${container_name}
            done
            ;;

        help)
            echo $helpmsg
            exit 0
            ;;

    esac
done
