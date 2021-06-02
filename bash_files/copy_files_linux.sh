#!/bin/bash
rsync -rv --max-size='50MB' "./$1" bnn-prj-07@ce-ailab.ewi.tudelft.nl:/data/home/bnn-prj-07/files
