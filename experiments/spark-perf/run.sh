#!/bin/bash
set -e -x

# delete previous results
rm -fr results/benchoutput/*
rm -fr results/facts/*

mkdir -p $outdir/
docker run --rm -ti \
  -v `pwd`/ansible:/experiment \
  -v `pwd`/vars.yml:/experiment/vars.yml \
  -v `pwd`/results/benchoutput:/results \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  ivotron/ansible:2.2.0.0 -c \
    "ansible-playbook \
      -e @vars.yml \
      -e local_results_path=/results \
      playbook.yml"
