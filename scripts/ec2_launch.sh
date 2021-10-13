#!/bin/bash

# Replace anything encased in "+++" with your info

echo "Launching EC2 instance..."
INSTS=$(aws ec2 run-instances \
	--image-id ami-09e67e426f25ce0d7 \
	--count $# \
	--instance-type m4.xlarge \
	--key-name +++KEY-NAME+++ \
	--security-group-ids +++SECURITY-GROUP-IDS+++ \
	--subnet-id +++SUBNET-ID+++)

IDS=($(echo "$INSTS" | jq '.Instances[].InstanceId' | tr -d '"'))
STATUS=($(echo "$INSTS" | jq '.Instances[].State.Name' | tr -d '"'))
DNSS=()

echo "Our IDs: ${IDS[@]}"
echo "Our Status: ${STATUS[@]}"

for i in "${!IDS[@]}"; do
	echo "Checking state for ${IDS[$i]}..."
	while [[ "${STATUS[$i]}" == pending ]]; do
		echo "Waiting for running status..."
		sleep 5
		OUT=$(aws ec2 describe-instances --instance-ids ${IDS[$i]})
		STATUS[$i]=$(echo "$OUT" | jq '.Reservations[].Instances[].State.Name' | tr -d '"')
		echo "New Status: ${STATUS[$i]}"
	done
	echo "${IDS[$i]} state: ${STATUS[$i]}"
	DNS+=($(echo "$OUT" | jq '.Reservations[].Instances[].PublicDnsName' | tr -d '"'))
done

echo "Fetching host names..."
echo "OUR DNS: ${DNS[@]}"

sleep 30

echo "Starting connection to EC2 instances..."
for i in "${!DNS[@]}"; do 
	echo "Connecting to ${DNS[i]}..."
	sudo ssh -o StrictHostKeyChecking=no -i +++KEY-FILE+++ ubuntu@${DNS[i]} 'bash -s' < automation_setup.sh "${@:i+1:1}" & 
done

echo "Waiting to finish all processes on all instances..."
wait

echo "Terminating instances..."
aws ec2 terminate-instances --instance-ids ${IDS[@]}
