#!/bin/sh

TASKLIB=$PWD/src
INPUT_FILE_DIRECTORIES=$PWD/data
S3_ROOT=s3://moduleiotest
WORKING_DIR=$PWD/job_1112

RHOME=/packages/R-2.8.1/

JOB_DEFINITION_NAME="R28_Generic"
JOB_ID=gp_job_helloWorld_$1
JOB_QUEUE=TedTest


COMMAND_LINE="java -cp /build -DR_HOME=$RHOME -Dr_flags=\"--no-save --quiet --slave --no-restore\" RunR $TASKLIB/hello.R hello"

DOCKER_CONTAINER=genepattern/docker-r-2-8
