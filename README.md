# NeuronBridge Aligners

[![DOI](https://zenodo.org/badge/488336834.svg)](https://zenodo.org/badge/latestdoi/488336834)

These containerized aligners are used by NeuronBridge to align user-uploaded imagery in preparation for ad-hoc searching. They run using Docker on AWS Batch.

## Build Containers

### Prepare container build environment

Copy 'env.template' to '.env' and set the container namespace or if you want namespaces - there may be more than one namespace, for example:
```
NAMESPACE=janeliascicomp
NAMESPACE=registry.int.janelia.org/neuronbridge
```
If there is no namespace the container image can still be created locally but it cannot be pushed to any registry using the provided [manage.sh](manage.sh) script

### Create Docker images

Run the build subcommand in order to create the containers from the specified directories:
```
./manage.sh build brain-aligner
```

### Push docker images

Run:
```
./manage.sh push brain-aligner
```
