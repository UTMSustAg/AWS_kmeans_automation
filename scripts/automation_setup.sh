#!/bin/bash
git clone https://github.com/UTMSustAg/AWS_kmeans_automation.git
echo "Starting setup.sh..."
cd /home/ubuntu/AWS_kmeans_automation/scripts/
bash setup.sh
echo "Starting ec2-setup.sh..."
bash efs_setup.sh
echo "Starting Rscript..."
Rscript n_ras_kmeans.R $@ 
echo "Finish Rscript. Check output!"
