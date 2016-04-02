#!/bin/bash
source $HOME/.bash_profile
cd $1
if [ $2 != "development" ] && [ $2 != "production" ]; then
  echo "not use $2"
  exit 1
fi
rbenv local 2.1.2
bundle exec rails runner Tasks::ScrapingBatchRunner.execute\(\"executeByDate\"\) -e $2
