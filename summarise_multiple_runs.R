#!/usr/bin/env Rscript

# ============================================================
#  Summarise multiple PhyloNOW runs
#
#  Usage: Rscript summarise_multiple_runs.R -i /home/user/phyloNOW_runs/ -o /home/user/phyloNOW_summary/
# ============================================================

# --- Load libraries and function ----------------------------
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(tidyverse))

# create a function to retrieve parameter value with default
f_get_param <- function(value, default) {
  ifelse (is.null(value) || value=="", default, value)
}

# --- Argument parsing ----------------------------------------
option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="Path to directory containing multiple PhyloNOW runs [required]", metavar="DIR"),
  make_option(c("-o", "--output"), type="character", default=NULL,
              help="Path to output directory for summaries [required]", metavar="DIR")
)

# parse the arguments
opt <- parse_args(OptionParser(option_list=option_list))

# stop the code if input or output directory is not specified
if (is.null(opt$input) || is.null(opt$output)) {
  stop("Both -i/--input and -o/--output are required.\n
        Usage: Rscript summarise_multiple_runs.R -i /home/user/phyloNOW_runs/ -o /home/user/phyloNOW_summary/")
}

# --- Load and validate input/output directories --------------
input_dir <- path.expand(opt$input)
output_dir <- path.expand(opt$output)

list_input <- list.dirs(input_dir, recursive=FALSE, full.names=FALSE)
if (length(list_input) == 0) {
    stop(paste("No subdirectories found in input directory:", input_dir))
}

# create output directory if not exists
if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive=TRUE)
}

# --- Output files --------------------------------------------
fn_summary <- file.path(output_dir, "all_summary.tsv")
fn_correlation_summary <- file.path(output_dir, "correlation_summary.tsv")

fn_wsize_coord <- file.path(output_dir, "wsize_x_coordinates.tiff")
fn_top_coord <- file.path(output_dir, "topology_x_coordinates.tiff")
fn_top_coord_highbs <- file.path(output_dir, "topology_x_coordinates_highbs.tiff")

fn_chrlen_wsize_mean <- file.path(output_dir, "chrlen_x_wsize_mean.tiff")
fn_chrlen_wsize_median <- file.path(output_dir, "chrlen_x_wsize_median.tiff")

# --- Visualise variation across coordinates -------------------
df_visualisation <- data.table::data.table()
df_visualisation_2 <- data.table::data.table()
df_visualisation_3 <- data.table::data.table()

# iterate over inputs
for (input in list_input) {
    # input files
    fn_topsum <- file.path(input_dir, input, paste0(input, ".topsum"))
    fn_winsum <- file.path(input_dir, input, paste0(input, ".winsum"))
    if (!file.exists(fn_topsum) || !file.exists(fn_winsum)) {
        message(paste("Warning: Missing .topsum or .winsum file for input:", input))
        next
    }

    # open input files
    df_topsum <- data.table::fread(fn_topsum)
    df_winsum <- data.table::fread(fn_winsum)

    # extract the median and mean window size
    df_visualisation_3 <- rbind(df_visualisation_3, data.table::data.table(chr=input,
                                                                           wsize_mean=mean(df_winsum$length),
                                                                           wsize_median=median(df_winsum$length)))

    # convert the lengths into genomic positions
    df_topsum <- df_topsum %>% mutate(start = lag(cumsum(length), default=0)+1,
                                      stop = start+length-1,
                                      chr = input)
    df_winsum <- data.table::data.table(pos = seq(1, sum(df_winsum$length)),
                                        len = rep(df_winsum$length, times=df_winsum$length),
                                        chr = input)

    # update the output data.frame
    df_visualisation <- rbind(df_visualisation, df_topsum)
    df_visualisation_2 <- rbind(df_visualisation_2, df_winsum)
}

# save data.frame
data.table::fwrite(df_visualisation, file=fn_summary, sep="\t", quote=F)

# --- Topologies across genomic coordinates -------------------
df_visualisation$chr <- factor(df_visualisation$chr, levels=stringr::str_sort(unique(df_visualisation$chr), numeric=T, decreasing=T))
df_visualisation$y <- as.numeric(df_visualisation$chr) * 1.5

# plot topologies across genomic coordinates (all gene trees) 
plot <- ggplot(df_visualisation) +
    geom_rect(aes(xmin=start, xmax=stop, ymin=y-0.6, ymax=y+0.6, fill=topology)) +
    labs(x="Genomic Position (bp)", y="Chromosome", fill="Topology") +
    scale_y_continuous(breaks=unique(df_visualisation$y), labels=unique(df_visualisation$chr), expand=c(0.02, 0.02)) +
    theme(axis.title.x=element_text(size=40, margin = margin(t=20, r=0, b=0, l=0)),
          axis.title.y=element_text(size=40, margin = margin(t=0, r=20, b=0, l=0)),
          axis.text.y=element_text(size=40),
          axis.text.x=element_text(size=40),
          panel.grid.major.y=element_blank(),
          panel.grid.minor.y=element_blank(),
          legend.title=element_text(size=30),
          legend.text=element_text(size=30),
          legend.key.size=unit(2,"cm"))

tiff(filename=fn_top_coord, units="px", width=3840, height=1080)
print(plot)
dev.off()

# plot topologies across genomic coordinates (gene trees with high bootstrap value)
df_visualisation$topology <- ifelse(df_visualisation$is_highbs, df_visualisation$topology, "low_bs")

plot <- ggplot(df_visualisation) +
    geom_rect(aes(xmin=start, xmax=stop, ymin=y-0.6, ymax=y+0.6, fill=topology)) +
    labs(x="Genomic Position (bp)", y="Chromosome", fill="Topology") +
    scale_y_continuous(breaks=unique(df_visualisation$y), labels=unique(df_visualisation$chr), expand=c(0.02, 0.02)) +
    theme(axis.title.x=element_text(size=40, margin = margin(t=20, r=0, b=0, l=0)),
          axis.title.y=element_text(size=40, margin = margin(t=0, r=20, b=0, l=0)),
          axis.text.y=element_text(size=40),
          axis.text.x=element_text(size=40),
          panel.grid.major.y=element_blank(),
          panel.grid.minor.y=element_blank(),
          legend.title=element_text(size=30),
          legend.text=element_text(size=30),
          legend.key.size=unit(2,"cm"))

tiff(filename=fn_top_coord_highbs, units="px", width=3840, height=1080)
print(plot)
dev.off()

# --- Window sizes across genomic coordinates -----------------
plot <- ggplot(df_visualisation_2, aes(x=pos, y=len)) +
  geom_point(linewidth=1, alpha=0.8) +
  scale_y_log10(labels=scales::label_number(trim = TRUE, accuracy = NULL)) +
  facet_wrap(.~chr, ncol=2) +
  xlab("Genomic Position (bp)") + ylab("Block Length (bp)") +
  theme(
      axis.title.x=element_text(size=40),
      axis.title.y=element_text(size=40),
      axis.text.y=element_text(size=30),
      axis.text.x=element_text(size=30),
      strip.text=element_text(size=30),
      legend.title=element_text(size=30),
      legend.text=element_text(size=30),
      legend.key.size=unit(2,"cm")
    )

tiff(filename=fn_wsize_coord, units="px", width=4000, height=8000)
print(plot)
dev.off()

# --- Correlation analyses ------------------------------------
# function: calculate pseudo R² for linear and non-linear models
pseudo_r2 <- function(fit, y) {
  1 - sum(residuals(fit)^2) / sum((y - mean(y))^2)
}

# output table
df_correlation <- data.table::data.table(wsize=character(), model=character(), r2=numeric(), aic=numeric())

# --- Mean window size vs chromosome length -------------------
fit_lin  <- lm(wsize_mean ~ chr, data=df_visualisation_3)
fit_log  <- lm(wsize_mean ~ log(chr), data=df_visualisation_3)
fit_asym <- nls(wsize_mean ~ SSasymp(chr, Asym, R0, lrc), data=df_visualisation_3)

# update output table
df_correlation <- rbind(df_correlation, data.table::data.table(wsize="mean", model="linear", r2=pseudo_r2(fit_lin, df_visualisation_3$wsize_mean), aic=AIC(fit_lin)),
                                        data.table::data.table(wsize="mean", model="logarithmic", r2=pseudo_r2(fit_log, df_visualisation_3$wsize_mean), aic=AIC(fit_log)),
                                        data.table::data.table(wsize="mean", model="asymptotic", r2=pseudo_r2(fit_asym, df_visualisation_3$wsize_mean), aic=AIC(fit_asym)))

# create a sequence of x values for plotting the fitted lines
x_seq <- seq(min(df_visualisation_3$chr), max(df_visualisation_3$chr), length.out=200)
newdata <- data.frame(chr=x_seq)

df_lines <- data.frame(
  x = rep(x_seq, 3),
  y = c(
    predict(fit_lin, newdata=newdata),
    predict(fit_log, newdata=newdata),
    predict(fit_asym, newdata=newdata)
  ),
  model = rep(c("Linear", "Logarithmic", "Asymptote"), each=200)
)

# visualisation
plot <- ggplot(df_visualisation_3) +
  geom_point(aes(x=chr/1000000, y=wsize_mean), size=5) +
  geom_line(data=df_lines, aes(colour=model, x=x/1000000, y=y), alpha=0.7, linewidth=2) +
  labs(x="Chromosome length (Mb)", y="Average window size (bp)", color="Model") +
  scale_colour_manual(values = c(Linear="#00ba38",
                                 Logarithmic="#619cff",
                                 Asymptote="#f8766d")) +
  theme(
    axis.title.x=element_text(size=40),
    axis.title.y=element_text(size=40),
    axis.text.y=element_text(size=30),
    axis.text.x=element_text(size=30),
    legend.title=element_text(size=30),
    legend.text=element_text(size=30),
    legend.key.size=unit(2,"cm")
  )

tiff(filename=fn_chrlen_wsize_mean, units="px", width=1080, height=720)
print(plot)
dev.off()

# --- Median window size vs chromosome length -----------------
fit_lin  <- lm(wsize_median ~ chr, data=df_visualisation_3)
fit_log  <- lm(wsize_median ~ log(chr), data=df_visualisation_3)
fit_asym <- nls(wsize_median ~ SSasymp(chr, Asym, R0, lrc), data=df_visualisation_3)

# update output table
df_correlation <- rbind(df_correlation, data.table::data.table(wsize="median", model="linear", r2=pseudo_r2(fit_lin, df_visualisation_3$wsize_median), aic=AIC(fit_lin)),
                                        data.table::data.table(wsize="median", model="logarithmic", r2=pseudo_r2(fit_log, df_visualisation_3$wsize_median), aic=AIC(fit_log)),
                                        data.table::data.table(wsize="median", model="asymptotic", r2=pseudo_r2(fit_asym, df_visualisation_3$wsize_median), aic=AIC(fit_asym)))

# create a sequence of x values for plotting the fitted lines
df_lines <- data.frame(
  x = rep(x_seq, 3),
  y = c(
    predict(fit_lin, newdata=newdata),
    predict(fit_log, newdata=newdata),
    predict(fit_asym, newdata=newdata)
  ),
  model = rep(c("Linear", "Logarithmic", "Asymptote"), each=200)
)

# visualisation
plot <- ggplot(df_visualisation_3) +
  geom_point(aes(x=chr/1000000, y=wsize_median), size=5) +
  geom_line(data=df_lines, aes(colour=model, x=x/1000000, y=y), alpha=0.7, linewidth=2) +
  labs(x="Chromosome length (Mb)", y="Median window size (bp)", color="Model") +
  scale_colour_manual(values = c(Linear="#00ba38",
                                 Logarithmic="#619cff",
                                 Asymptote="#f8766d")) +
  theme(
    axis.title.x=element_text(size=40),
    axis.title.y=element_text(size=40),
    axis.text.y=element_text(size=30),
    axis.text.x=element_text(size=30),
    legend.title=element_text(size=30),
    legend.text=element_text(size=30),
    legend.key.size=unit(2,"cm")
  )

tiff(filename=fn_chrlen_wsize_mean, units="px", width=1080, height=720)
print(plot)
dev.off()

# save data.table
data.table::fwrite(df_correlation, file=fn_correlation_summary, sep="\t", quote=F)