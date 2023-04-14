#!/usr/bin/env bash
# git version update may trigger pug rebuild, which in turns need a new git version - a infinite loop.
# we don't have a better solution for this for for now we manually generate the version tag.
key="$(suuid)"
key=${key:3:12}
printf "//- module\n//- generated with npm run pug-rebuild.\n- var version=\"$key\";" > frontend/web/src/pug/modules/version.pug
