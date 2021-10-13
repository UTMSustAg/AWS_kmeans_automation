# Ecoregion Delineation Automation Process
Download and run "bash ec2_launch.sh 5" to run 5 instances which will clone the repo, download the required software/libraries in each, and runs the k-means clustering ecoregion delineation code for different cluster numbers.

Maps and CSVs will be put in the outputs/ directory.

Note: In the beginning stages.

Requires: WorldClim data: tif -> CSV. Will be adjusted in the future with different data type inputs.

WARNING: ClusterNor has been removed from CRAN so "n_ras_kmeans.R" will error when importing the library. Update with cloning the knor repo will come soon.
