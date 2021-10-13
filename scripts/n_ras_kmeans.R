start_time <- Sys.time()

dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)  # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path
install.packages(c("rgdal", "raster", "ggplot2", "clusternor"))

library(rgdal)
library(raster)
library(ggplot2)
library(clusternor)
#library(parallel)

print("Get arguments")
args <- commandArgs(trailingOnly=TRUE)

print("setting directories")
mainoutdir <- file.path("/home/ubuntu/efs/data/clustering_output/leila_test_output/north_america")
suboutdir <- paste("k", args[1], sep="")
dir.create(file.path(mainoutdir, suboutdir))
outdir <- file.path(mainoutdir, suboutdir)
print(outdir)
datadir <- file.path("/home/ubuntu/efs/data/clustering_datasets/north_america")

print("getting data")
rasters.list <- list.files(path=datadir, full.names=TRUE, recursive=FALSE)
num_rasters <- length(rasters.list)
rasters.df <- lapply(rasters.list, read.csv, header=FALSE)

print("stack the dataframes")
rb.df <- do.call(rbind, rasters.df)
names(rb.df) <- c("X", "Y", "BIO1", "BIO10", "BIO11", "BIO12", "BIO13", "BIO14", "BIO15", "BIO16", "BIO17", "BIO18", "BIO19", "BIO2", "BIO3", "BIO4", "BIO5", "BIO6", "BIO7", "BIO8", "BIO9")

num_pixels_each <- nrow(rb.df) / num_rasters
print(num_pixels_each)
print(nrow(rb.df))
print(head(rb.df))

print("remove coord")
cd.df <- rb.df[c(3:ncol(rb.df))]

print("normalize data")
ncd.df <- scale(cd.df, center=TRUE, scale=TRUE)

print("kmeans")
ncd.df <- data.matrix(ncd.df)
nut.clusters <- Kmeans(ncd.df, as.integer(args[1]))

print("put coord back")
cl.df <- data.frame(rb.df[1:2], nut.clusters$cluster)

print("add headers")
names(cl.df) <- c("lon", "lat", "cluster")

print("make it into a class")
cl.df$cluster <- as.factor(cl.df$cluster)

print("split the data frames")
for (i in 1:num_rasters) {
  ras_name <- sub('\\.csv$', '', basename(rasters.list[i]))
  print(ras_name)

  print("extract list")
  results.df <- cl.df[((num_pixels_each*(i-1))+1):(num_pixels_each*i), ]
  print(head(results.df))

  print("make the cluster table")
  write.table(results.df, file.path(outdir, paste(ras_name, args[0], "cluster.csv", sep="_")), sep="|", col.names=TRUE, row.names=FALSE)
  
  print("Making the means table...")
  kmeans.means <- nut.clusters$centers
  colnames(kmeans.means) <- c("BIO1", "BIO10", "BIO11", "BIO12", "BIO13", "BIO14", "BIO15", "BIO16", "BIO17", "BIO18", "BIO19", "BIO2", "BIO3", "BIO4", "BIO5", "BIO6", "BIO7", "BIO8", "BIO9")
  write.table(kmeans.means, file.path(outdir, paste(ras_name, args[0], "means_table.csv", sep="_")), sep="|", col.names=TRUE, row.names=TRUE)

  print("create maps")
  p <- ggplot(results.df, aes(x=lon, y=lat)) + geom_raster(aes(fill=cluster)) + coord_fixed(1.3)
  p <- p + ggtitle(paste(ras_name, "Ecoregion delineation")) + labs(x="Longitude", y="Latituide") + theme(plot.title=element_text(hjust=0.5))
  p <- p + theme(legend.position="right") + theme(legend.title = element_blank())
  ggsave(file.path(outdir, paste(ras_name, args[0], "ecoregions.png", sep="_")), device='png', plot=p, width=11, height=8.5)

}

ggplot_color.df <- ggplot_build(p)$data[[1]]
unique_hex.df <- unique(ggplot_color.df[c("fill","group")])
unique_RGB.df <- as.data.frame(col2rgb(unique_hex.df[,1], alpha =FALSE))
transpose_RGB.df <- t(unique_RGB.df)
merge_RGB.df <- cbind(unique_hex.df[,2], paste(transpose_RGB.df[,1], transpose_RGB.df[,2], transpose_RGB.df[,3], sep=":"))
order_RGB.df <- merge_RGB.df[order(as.numeric(merge_RGB.df[,1])), ]
write.table(order_RGB.df, file.path(outdir, "R_color_scheme.csv"), sep=" ", col.names=FALSE, row.names=FALSE, quote=FALSE)

end_time <- Sys.time()
print(end_time - start_time)
