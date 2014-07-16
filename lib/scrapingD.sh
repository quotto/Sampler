#!/bin/bash
source $HOME/.bash_profile
cd $1
rbenv local 2.1.2
bundle exec rails runner Tasks::ScrapingBatchRunner.execute\(\"executeByDate\"\)
