#!/bin/bash
echo $2
echo $1
gcloud compute disks list --project $2 --format='value(name,zone)'|grep $1| while read DISK_NAME ZONE; do
  echo $DISK_NAME
  echo $ZONE
  gcloud compute disks --project $2 snapshot $DISK_NAME --snapshot-names autogcs-${DISK_NAME:0:31}-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after 60 days
#
gcloud compute snapshots list --project $2 --filter="creationTimestamp<$(date --date="30 days ago" +"%Y-%m-%d")" --regexp "(autogcs.*)" --uri | while read SNAPSHOT_URI; do
   gcloud compute snapshots --project $2 --quiet delete $SNAPSHOT_URI
done
#
