#!/bin/bash
###### https://help.mikrotik.com/docs/display/RKB/Create+an+RouterOS+CHR+7.6+AMI
imageVersion=$(printenv CHR_TARGET_VERSION)
imageDescription="Mikrotik RouterOS CHR v${imageVersion}"
imageKey="chr-${imageVersion}.img"
runNumber=$(printenv GITHUB_RUN_NUMBER)

JOB="$1"

case $JOB in
    "import-snapshot")
        imageBucket="$2"
        [ -z "$imageBucket" ] && echo "No image bucket provided, cannot continue" && break

        aws ec2 import-snapshot \
            --description "${imageDescription} image" \
            --disk-container Format=RAW,UserBucket={S3Bucket=${imageBucket},S3Key=${imageKey}} | jq -r '.ImportTaskId'
    ;;

    "monitor-import")
        import_task_id=`echo "$2" | xargs`
        [ -z "$import_task_id" ] && echo "No import task ID provided, cannot continue" && break

        x=1
        while [ ${x} -le 6 ]
        do
            sleep 20
            snapshot=$(aws ec2 describe-import-snapshot-tasks \
                --import-task-ids $import_task_id | jq -r '.ImportSnapshotTasks[0].SnapshotTaskDetail.SnapshotId // ""')
            [ ! -z "$snapshot" ] && echo $snapshot && break
            x=$(( $x + 1 ))
        done
    ;;

    "register-image")
        snapshot_id=`echo "$2" | xargs`
        [ -z "$snapshot_id" ] && echo "No snapshot ID provided, cannot continue" && break

        aws ec2 register-image \
          --name "$imageDescription" \
          --description "Mikrotik CHR image created directly from the RAW image available on https://mikrotik.com/download. ghrun#${runNumber}" \
          --architecture x86_64 \
          --virtualization-type hvm \
          --ena-support \
          --root-device-name "/dev/sda1" \
          --block-device-mappings "[{\"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"SnapshotId\": \"$snapshot_id\"}}]" | jq -r '.ImageId'
    ;;

    "publish-image")
        image_id=`echo "$2" | xargs`
        [ -z "$image_id" ] && echo "No image ID provided, cannot continue" && break

        aws ec2 modify-image-attribute \
            --image-id $image_id \
            --launch-permission "Add=[{Group=all}]"
    ;;

    *)
        echo "Unknown job type: ${JOB}"
    ;;
esac
