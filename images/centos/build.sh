#!/bin/bash

for i in $(ls -d centos-8_k8s*/); do
 name=${i%%/};
 echo $name
 tar -h -czvf $name.tar.gz -C $name .
done