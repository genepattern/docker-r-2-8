#!/bin/sh

# Rscript src/SurvivalCurve.R SurvivalCurve data/surv.txt -c data/surv.cls surv time censor -fcls.clinical F automatic -lt -lc 1 1 -m 0 1 log 0 T left-bottom

# /Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/r28/tests/survival_curve


TASKLIB=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/r28/tests/helloWorld/src
INPUT_FILE_DIRECTORIES=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/r28/tests/helloWorld/data
S3_ROOT=s3://moduleiotest
WORKING_DIR=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/r28/tests/helloWorld/job_1111

# in this container it automatically does the java -cp RunR before the command
#
RHOME=/packages/R-2.8.1/
COMMAND_LINE="runS3OnBatch.sh $TASKLIB $INPUT_FILE_DIRECTORIES $S3_ROOT $WORKING_DIR java -cp /build -DR_HOME=$RHOME \"-Dr_flags=--no-save --quiet --slave --no-restore\" RunR $TASKLIB/hello.R hello"

JOB_DEFINITION_NAME="R28_Generic"
JOB_ID=gp_job_helloWorld_$1
JOB_QUEUE=TedTest

# ##### NEW PART FOR SCRIPT INSTEAD OF COMMAND LINE ################################
# Make the input file directory since we need to put the script to execute in it
mkdir -p $INPUT_FILE_DIRECTORIES
mkdir -p $INPUT_FILE_DIRECTORIES/.gp_metadata

aws s3 sync $INPUT_FILE_DIRECTORIES $S3_ROOT$INPUT_FILE_DIRECTORIES

echo "#!/bin/bash\n" > $INPUT_FILE_DIRECTORIES/.gp_metadata/exec.sh
echo "echo \"$COMMAND_LINE\"" >>$INPUT_FILE_DIRECTORIES/.gp_metadata/exec.sh
echo $COMMAND_LINE >>$INPUT_FILE_DIRECTORIES/.gp_metadata/exec.sh
echo "\n " >>$INPUT_FILE_DIRECTORIES/gp_metadata/exec.sh

chmod a+x $INPUT_FILE_DIRECTORIES/.gp_metadata/exec.sh

REMOTE_COMMAND="$INPUT_FILES_DIR/.gp_metadata/exec.sh"
# note the batch submit now uses REMOTE_COMMAND instead of COMMAND_LINE 

#
# Copy the input files to S3 using the same path
#

aws s3 sync $INPUT_FILE_DIRECTORIES $S3_ROOT$INPUT_FILE_DIRECTORIES --profile genepattern
aws s3 sync $TASKLIB $S3_ROOT$TASKLIB --profile genepattern


######### end new part for script #################################################


#       --container-overrides memory=2000 \

aws batch submit-job \
      --job-name $JOB_ID \
      --job-queue $JOB_QUEUE \
      --container-overrides 'memory=3600' \
      --job-definition $JOB_DEFINITION_NAME \
      --parameters taskLib=$TASKLIB,inputFileDirectory=$INPUT_FILE_DIRECTORIES,s3_root=$S3_ROOT,working_dir=$WORKING_DIR,exe1="$REMOTE_COMMAND"  \
      --profile genepattern


