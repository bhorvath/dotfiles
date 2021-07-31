#!/bin/bash

# Mocha and solarized don't play well together and mocha's devs have no
# interest in doing anything about it.
# https://github.com/mochajs/mocha/issues/3183

if [[ $# -eq 0 ]]
then
  echo "Provide a path to the root of a git repository"
  exit 1
fi

cd $1
ack -li "pass: 90" --noignore-dir=node_modules | xargs sed -i "s/pass: 90/pass: 92/; s/'error stack': 90/'error stack': 92/; s/fast: 90/fast: 92/; s/light: 90/light: 92/; s/'diff gutter': 90/'diff gutter': 92/; s/'diff added': 42/'diff added': 34/; s/'diff removed': 41/'diff removed': 33/"
