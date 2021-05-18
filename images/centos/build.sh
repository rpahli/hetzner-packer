#!/bin/bash

for i in $(ls -d centos-8_k8s*/); do
 name=${i%%/};
 echo $name
 #cd $name
 tar -h -czvf $name.tar.gz $name
 #mv $name.tar.gz ../
 #cd -
done