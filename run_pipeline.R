#!/usr/bin/env Rscript

# ============================================================
#  PhyloNOW
#
#  Usage: Rscript run_pipeline.R --config config.yaml
#         Rscript run_pipeline.R --config config.yaml --redo
# ============================================================

# --- Load libraries and function ----------------------------
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(yaml))

# create a function to retrieve parameter value with default
f_get_param <- function(value, default) {
  ifelse (is.null(value) || value=="", default, value)
}

# --- Argument parsing ----------------------------------------
option_list <- list(
  make_option(c("-c", "--config"), type="character", default=NULL,
              help="Path to YAML config file [required]", metavar="FILE"),
  make_option(c("-r", "--redo"), action="store_true", default=FALSE,
              help="Re-run all analyses and override previous results")
)

# parse the arguments
opt <- parse_args(OptionParser(option_list=option_list))

# stop the code if config file is invalid
if (is.null(opt$config)) {
  stop("--config is required.\n
        Usage: Rscript run_pipeline.R --config config.yaml")
}

if (!file.exists(opt$config)) {
  stop(paste("Config file not found:", opt$config))
}

# --- Load and validate config --------------------------------
cfg <- yaml::read_yaml(opt$config)

# set required parameters
required_fields <- c("codedir", "outdir", "input_aln", "exe_seqkit", "exe_iqtree")
missing <- setdiff(required_fields, names(cfg))
if (length(missing) > 0) {
  stop(paste("Missing required config fields:", paste(missing, collapse=", ")))
}

# check if input alignment is invalid
if (is.null(cfg$input_aln) || cfg$input_aln == "") {
  stop("input_aln must be set in the config file.")
}

if (!file.exists(path.expand(cfg$input_aln))) {
  stop(paste("input_aln file not found:", cfg$input_aln))
}

# check if prefix is set, otherwise use the alignment filename
if (is.null(cfg$prefix) || cfg$prefix == "") {
  cfg$prefix <- tools::file_path_sans_ext(basename(cfg$input_aln))
}

# --- Apply CLI overrides -------------------------------------
if (opt$redo) {
  message("Note: --redo flag set via CLI, overriding config.")
  cfg$redo <- TRUE
}

# --- Map config to rmarkdown params --------------------------
params <- list(
  codedir               = cfg$codedir,
  prefix                = cfg$prefix,
  outdir                = cfg$outdir,
  thread                = as.integer(f_get_param(cfg$thread, 1)),
  redo                  = as.logical(f_get_param(cfg$redo, FALSE)),

  exe_seqkit            = cfg$exe_seqkit,
  exe_iqtree            = cfg$exe_iqtree,

  set_blmin             = as.logical(f_get_param(cfg$set_blmin, TRUE)),
  set_model             = as.logical(f_get_param(cfg$set_model, FALSE)),
  substitution_model    = f_get_param(cfg$substitution_model, ""),

  bootstrap_type        = f_get_param(cfg$bootstrap_type, ""),
  bootstrap             = as.integer(f_get_param(cfg$bootstrap, 1000)),
  outgroup              = f_get_param(cfg$outgroup, ""),

  run_rootstrap         = as.logical(f_get_param(cfg$run_rootstrap, FALSE)),
  run_midpoint_root     = as.logical(f_get_param(cfg$run_midpoint_root, FALSE)),

  input_aln             = cfg$input_aln,
  init_wsize            = as.integer(f_get_param(cfg$init_wsize, NA)),
  split_prop            = unlist(f_get_param(cfg$split_prop, list(0.25, 0.5, 0.75))),
  min_informative_sites = as.integer(f_get_param(cfg$min_informative_sites, 1))
)

# --- Run PhyloNOW --------------------------------------------
rmd_path <- file.path(path.expand(params$codedir), "codes", "1_main.Rmd")
if (!file.exists(rmd_path)) {
  stop(paste("1_main.Rmd not found:", rmd_path))
}

message("Starting PhyloNOW pipeline...")
message("  Config:  ", opt$config)
message("  Prefix:  ", params$prefix)
message("  Output:  ", params$outdir)
message("  Input:   ", params$input_aln)
message("  Threads: ", params$thread)

# render the Rmarkdown file
rmarkdown::render(
  input       = rmd_path,
  params      = params,
  output_file = paste0(params$prefix, "_report.html"),
  output_dir  = file.path(path.expand(params$outdir), params$prefix),
  quiet       = FALSE
)

message("Done. Report: ",
        file.path(path.expand(params$outdir), params$prefix,
                  paste0(params$prefix, "_report.html")))