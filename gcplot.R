#!/usr/bin/env Rscript
##########################
# REPLICATE GROWTH CURVE #
##########################

# Processing arguments
args = commandArgs(trailingOnly = T)
if((length(args) == 0) || args[1] == "help") {
	stop("No files were suplied. Exiting...
\n
Usage:
======
\n
	./gcplot.R --args <growth_file.txt> <spec_file.txt> <plot_name.png>
\n
	* <growth_file.txt> Tabular separated file with the growth data
\n
	* <spec_file.txt> Specification file with informations about the experiment
\n
	* <plot_name.png> Filename for the output chart image
\n

Please, make sure the R package ggplot2 is installed successfully
If you are heaving trouble dealing with the file types, please, see README.md
\n
\n
gcplot: Automated plotting software for growth curves with biological replicates
================================================================================
by Vinícius H F dos Santos
Version 1.0
2018
\n
")
}
# Loading packages
library(ggplot2)

# Loading files
gc_header = read.table(args[1], stringsAsFactors = F)
spec = read.table(args[2], stringsAsFactors = F)
flname = paste0(args[3])

# Getting treatment information
treat = unique(as.character(gc_header[1,2:ncol(gc_header)]))
nrep = length(which(gc_header[1,] == treat[1]))


if(is.na(spec[3,1])){ titl = " " }else{ titl = paste(strsplit(as.character(spec[3,1]), split = "_")[[1]], collapse = " ")}
if(is.na(spec[2,1])){ ylab = "OD600" }else{ ylab = as.character(spec[2,1]) }
if(is.na(spec[1,1])){ xlab = "Time (hours)" }else{ xlab = paste0("Time (", spec[1,1], ")") }

# GC: Time | treat_replicate1 | treat_replicate2 | treat_replicate1 | ....... | treatn_replicaten
gc = as.data.frame(gc_header[2:nrow(gc_header),])
cols = ncol(gc)
rows = nrow(gc)
colnames(gc) = 1:cols
rownames(gc) = 1:rows

nspp = (cols-1)/nrep
df.list = list()

# Creating splitted dataframes
for(i in 1:nspp){
	if(i == 1){from = 2}
	to = from+nrep-1 # 4
	growth_mean = apply(data.matrix(gc[,from:to]), 1, mean)
	growth_sd = apply(data.matrix(gc[,from:to]), 1, sd)
	data = data.frame(Time = as.numeric(gc[,1]), 
			  Mean = growth_mean,
			  sd = growth_sd,
			  Treatment = treat[i])
	df.list[[i]] = data
	from = to+1
}

# Meging them
df.merged = do.call(rbind, df.list)

# ggplotting
p = ggplot(data = df.merged, aes(x = Time, y = Mean)) +
	geom_line(aes(colour = Treatment), size = 1.3) +
	geom_errorbar(aes(ymin = Mean-sd, ymax = sd+Mean, colour = Treatment), size = 0.2) +
	geom_point(aes(colour = Treatment), size = 1.4)+
	labs(title = titl, x = xlab, y = ylab) + 
	theme_classic() +
	theme(text = element_text(size = 20),
		plot.title = element_text(hjust = 0.5),
		legend.title=element_blank())

ggsave(filename = flname, plot = p)

writeLines("Exitting...
\n
\n
gcplot: An automated pipeline for plotting growth curves
=========================================================
by Vinícius H F dos Santos
Version 1.0
2018\n")
