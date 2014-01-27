#!/bin/bash
source $HOME/.bash_profile
rvm use ruby-1.9.3-p448
/var/www/sampler/current/script/rails runner Tasks::ScrapingBatchRunner.execute\(\"executeByDate\"\)
