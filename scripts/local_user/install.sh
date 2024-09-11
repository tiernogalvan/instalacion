#!/bin/bash
#
# This script can be used to create local user for students
#

useradd -m -s /bin/bash estudiante

adduser estudiante docker

passwd estudiante Sandia4you
