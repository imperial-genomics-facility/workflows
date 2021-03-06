#!/bin/bash

## script to run GATK for counting covariates before base quality recalibration

#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=1:mem=5gb

#PBS -M igf@imperial.ac.uk
#PBS -m bea
#PBS -j oe

#PBS -q pqcgi

SETUP_LOG=setupLog
USAGE_FILE=usageFile
SUMMARY_SCRIPT_PATH=summaryScriptPath

echo -n "" > $USAGE_FILE
echo -e "job_name\texit_stat\tncpus\tcpupercent\tmem\twalltime" >> $USAGE_FILE

for JOB_ID in `grep 'job ID' $SETUP_LOG`
do
    echo "$JOB_ID"
    if [[ "$JOB_ID" == [0-9]*.cx1b ]]
    then

        JOB_ID=`basename $JOB_ID .cx1b` 

        env MAILRC=/dev/null \
        password-igf@exchange.imperial.ac.uk='weDDel15e' \
        ssl-verify=ignore \
        nss-config-dir=/groupvol/cgi/resources/mailsert/ \
        nail -n -N -R -f imaps://igf@exchange.imperial.ac.uk/21_PBS/cx1 <<EOF > $TMPDIR/usage 2>&1
        print (subject $JOB_ID)
EOF

        echo -n -e "$JOB_ID\t" >> $USAGE_FILE
        echo -n -e "`grep 'Job Name' $TMPDIR/usage|cut -f2 -d ':'|uniq|tr -d ' '`\t" >> $USAGE_FILE
        echo -n -e "`grep 'Exit_status' $TMPDIR/usage|cut -f2 -d '='`\t" >> $USAGE_FILE
        echo -n -e "`grep 'resources_used.ncpus' $TMPDIR/usage|cut -f2 -d '='`\t" >> $USAGE_FILE
        echo -n -e "`grep 'resources_used.cpupercent' $TMPDIR/usage|cut -f2 -d '='`\t" >> $USAGE_FILE
        echo -n -e "`grep 'resources_used.mem' $TMPDIR/usage|cut -f2 -d '='`\t" >> $USAGE_FILE
        echo "`grep 'resources_used.walltime' $TMPDIR/usage|cut -f2 -d '='`" >> $USAGE_FILE

    fi

done

#run summary script
perl $SUMMARY_SCRIPT_PATH

