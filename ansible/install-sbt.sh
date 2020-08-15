#!/bin/sh

yum install -y java-1.8.0-openjdk.x86_64
curl https://bintray.com/sbt/rpm/rpm > bintray-sbt-rpm.repo
mv bintray-sbt-rpm.repo /etc/yum.repos.d/
yum install -y sbt
sbt reload
