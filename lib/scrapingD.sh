#!/bin/bash
source $HOME/.bash_profile
rbenv local 2.1.0
/var/www/sampler/current/script/rails runner Tasks::ScrapingBatchRunner.execute\(\"executeByDate\"\)
