#!/bin/bash
gcloud compute disks list --project $PROJECT --format='value(name,zone)'|grep $GREPTHING| while read DISK_NAME ZONE; do
  gcloud compute disks --project $PROJECT snapshot $DISK_NAME --snapshot-names autogcs-${DISK_NAME:0:31}-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after 60 days
#
gcloud compute snapshots list --project $PROJECT --filter="creationTimestamp<$(date --date="30 days ago" +"%Y-%m-%d")" --regexp "(autogcs.*)" --uri | while read SNAPSHOT_URI; do
   gcloud compute snapshots --project $PROJECT delete $SNAPSHOT_URI
done
#
