#!/bin/bash

SUDO=
BUILDER=docker

# Parse command
if [[ $# -eq 0 ]]; then
    echo "Error: No command specified"
    exit 1
fi

COMMAND=$1
shift

# Parse container names (everything until we hit an option starting with -)
container_names=()
while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^- ]]; do
    container_names+=("$1")
    shift
done

# Parse build/push options
build_opts=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-podman)
            BUILDER=podman
            shift
            ;;
        *)
            build_opts+=("$1")
            shift
            ;;
    esac
done

helpmsg="
$0 COMMAND <container> [OPTIONS]
$0 help

COMMAND:
  build    Build container image(s)
  push     Push container image(s)
  help     Show this help message

OPTIONS:
  --with-podman              Use podman instead of docker
  --platform=<platforms>     Build for specific platform(s) (comma-separated)
  --no-cache                 Build without cache
  <any docker/podman opts>   Additional build/push options

EXAMPLES:
  # Build with docker (default)
  $0 build brain-aligner

  # Build with podman
  $0 build brain-aligner --with-podman

  # Multi-platform build with podman (creates manifest)
  $0 build brain-aligner --with-podman --platform=linux/amd64,linux/arm64

  # Build with additional options
  $0 build brain-aligner --no-cache --build-arg VERSION=1.0

  # Push with podman
  $0 push brain-aligner --with-podman
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
    fi
}

function buildContainer() {
    local _name=$1
    shift
    local -a additional_args=("${@}")

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

        # Check if using podman with --platform flag
        local use_manifest=false
        local platform=""
        if [[ "$BUILDER" == "podman" ]]; then
            for arg in "${additional_args[@]}"; do
                if [[ "$arg" == --platform=* ]]; then
                    use_manifest=true
                    platform="${arg#--platform=}"
                    break
                fi
            done
        fi

        if [[ "$use_manifest" == "true" ]]; then
            # Podman multi-platform build using manifest
            echo "Building with podman manifest for platform: $platform"

            # Get the first tag for manifest name
            local manifest_name=""
            if [[ ${#namespaces[@]} -gt 0 ]]; then
                manifest_name="${namespaces[0]}/${NAME}"
            else
                manifest_name="${NAME}"
            fi

            # Create manifest if it doesn't exist, or remove and recreate
            echo "Creating manifest: $manifest_name"
            $SUDO $BUILDER manifest exists "$manifest_name" 2>/dev/null && \
                $SUDO $BUILDER manifest rm "$manifest_name"
            if $SUDO $BUILDER image exists "$manifest_name" 2>/dev/null; then
                echo "Removing existing image blocking manifest name: $manifest_name"
                $SUDO $BUILDER ps -a --format '{{.ID}}' --filter "ancestor=$manifest_name" | xargs -r $SUDO $BUILDER rm -f
                $SUDO $BUILDER rmi --force "$manifest_name"
            fi
            $SUDO $BUILDER manifest create "$manifest_name"

            # Build for each platform
            IFS=',' read -ra PLATFORMS <<< "$platform"
            for plat in "${PLATFORMS[@]}"; do
                echo "Building for platform: $plat"
                local temp_tag="${manifest_name}-${plat//\//-}"

                # Remove existing image if it exists (podman requires this before manifest add)
                if $SUDO $BUILDER image exists "$temp_tag" 2>/dev/null; then
                    echo "Removing existing image: $temp_tag"
                    $SUDO $BUILDER ps -a --format '{{.ID}}' --filter "ancestor=$temp_tag" | xargs -r $SUDO $BUILDER rm -f
                    $SUDO $BUILDER rmi --force "$temp_tag"
                fi

                # Build the image for this platform
                local filtered_args=()
                for arg in "${additional_args[@]}"; do
                    if [[ "$arg" != --platform=* ]]; then
                        filtered_args+=("$arg")
                    fi
                done

                $SUDO $BUILDER build --platform "$plat" -t "$temp_tag" "${filtered_args[@]}" "$cdir"

                # Add to manifest
                echo "Adding $temp_tag to manifest $manifest_name"
                $SUDO $BUILDER manifest add "$manifest_name" "$temp_tag"
            done

            # Tag manifest with all namespace tags
            if [[ ${#namespaces[@]} -gt 1 ]]; then
                for ns in "${namespaces[@]:1}"; do
                    local additional_manifest="${ns}/${NAME}"
                    echo "Creating additional manifest tag: $additional_manifest"
                    $SUDO $BUILDER manifest exists "$additional_manifest" 2>/dev/null && \
                        $SUDO $BUILDER manifest rm "$additional_manifest"
                    if $SUDO $BUILDER image exists "$additional_manifest" 2>/dev/null; then
                        echo "Removing existing image blocking manifest name: $additional_manifest"
                        $SUDO $BUILDER ps -a --format '{{.ID}}' --filter "ancestor=$additional_manifest" | xargs -r $SUDO $BUILDER rm -f
                        $SUDO $BUILDER rmi --force "$additional_manifest"
                    fi
                    $SUDO $BUILDER manifest create "$additional_manifest"
                    for plat in "${PLATFORMS[@]}"; do
                        local temp_tag="${namespaces[0]}/${NAME}-${plat//\//-}"
                        $SUDO $BUILDER manifest add "$additional_manifest" "$temp_tag"
                    done
                done
            fi
        else
            # Standard docker/podman build
            $SUDO $BUILDER build $BUILD_ARGS ${additional_args[@]} $cdir
        fi
    done
}

function pushContainer() {
    local _name="$1"
    shift
    local -a additional_args=("${@}")

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
                local image_name="${ns}/${NAME}"

                # Check if this is a manifest (when using podman)
                if [[ "$BUILDER" == "podman" ]] && $SUDO $BUILDER manifest exists "$image_name" 2>/dev/null; then
                    echo "Pushing manifest: $image_name"
                    $SUDO $BUILDER manifest push ${additional_args[@]} "$image_name"
                else
                    echo "Pushing image: $image_name"
                    $SUDO $BUILDER push ${additional_args[@]} "$image_name"
                fi
            done
        fi
    done
}

readNamespaces

case ${COMMAND} in
    build)
        if [[ ${#container_names[@]} -eq 0 ]]; then
            echo "Error: No container specified"
            echo "$helpmsg"
            exit 1
        fi
        for container_name in "${container_names[@]}"; do
            echo "Build ${container_name}"
            buildContainer ${container_name} "${build_opts[@]}"
        done
        ;;

    push)
        if [[ ${#container_names[@]} -eq 0 ]]; then
            echo "Error: No container specified"
            echo "$helpmsg"
            exit 1
        fi
        for container_name in "${container_names[@]}"; do
            echo "Push ${container_name}"
            pushContainer ${container_name} "${build_opts[@]}"
        done
        ;;

    help)
        echo "$helpmsg"
        exit 0
        ;;

    *)
        echo "Error: Unknown command '${COMMAND}'"
        echo "$helpmsg"
        exit 1
        ;;
esac
