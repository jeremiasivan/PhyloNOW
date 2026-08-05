# PhyloNOW

**PhyloNOW (Phylogenomic Non-Overlapping Windows)** is an R pipeline to partition chromosome alignments into non-overlapping windows with variable sizes based on local AIC improvements. It consists of two main steps: iterative splitting and iterative merging of neighbouring windows. This pipeline is mainly developed and tested using MacOS and Linux, so there might be incompatibilities using Windows.

> [!NOTE]
> This repository stores the R codes for running non-overlapping windows with variable window sizes. If you want to simulate chromosome alignments with varying recombination rates and patterns, please use <a href="https://github.com/jeremiasivan/SimNOW"><b>SimNOW (Simulation Non-Overlapping Windows)</b></a>. If you want to run non-overlapping windows with fixed window size (which has been shown to perform poorly compared to using variable window sizes), please use <a href="https://github.com/jeremiasivan/StepwiseNOW"><b>StepwiseNOW (Stepwise Non-Overlapping Windows)</b></a>.

**If you use PhyloNOW, please cite as:**
```
J. Ivan & R. Lanfear. (2026). PhyloNOW: Using Variable Window Sizes for Phylogenomic Analyses of Whole Genome Alignments, bioRxiv. doi:10.64898/2026.03.04.709403.
```

## Table of Content
- <a href="#prereqs">Prerequisites</a>
- <a href="#genpipe">General Pipeline</a>
- <a href="#inout">Input and Output Files</a>
- <a href="#refs">References</a>

## <a id="prereqs">Prerequisites</a>
PhyloNOW requires several software and R packages to run. We recommend you to use environment management system (e.g. `conda`) to install the prerequisites, but you can also use `install.packages()` built-in function in R or RStudio.

### Software
|    Name    |                             Website                              |                             Anaconda                             |
| ---------- |:----------------------------------------------------------------:|:----------------------------------------------------------------:|
| IQ-TREE    | <a href="http://www.iqtree.org">Link</a>                         | <a href="https://anaconda.org/bioconda/iqtree">Link</a>          |
| SeqKit     | <a href="https://bioinf.shenwei.me/seqkit/">Link</a>             | <a href="https://anaconda.org/bioconda/seqkit">Link</a>          |

### R packages
|    Name    |                               CRAN                               |                                   Anaconda                               |
| ---------- |:----------------------------------------------------------------:|:------------------------------------------------------------------------:|
| ape        | <a href="https://cran.r-project.org/package=ape">Link</a>        | <a href="https://anaconda.org/conda-forge/r-ape">Link</a>                |
| Biostrings | <a href="https://bioconductor.org/packages/Biostrings">Link</a>  | <a href="https://anaconda.org/bioconda/bioconductor-biostrings">Link</a> |
| data.table | <a href="https://cran.r-project.org/package=data.table">Link</a> | <a href="https://anaconda.org/conda-forge/r-data.table">Link</a>         |
| doSNOW     | <a href="https://cran.r-project.org/package=doSNOW">Link</a>     | <a href="https://anaconda.org/conda-forge/r-dosnow">Link</a>             |
| log4r      | <a href="https://cran.r-project.org/package=log4r">Link</a>      | <a href="https://anaconda.org/conda-forge/r-log4r">Link</a>              |
| optparse   | <a href="https://cran.r-project.org/package=optparse">Link</a>   | <a href="https://anaconda.org/conda-forge/r-optparse">Link</a>           |
| phytools   | <a href="https://cran.r-project.org/package=phytools">Link</a>   | <a href="https://anaconda.org/conda-forge/r-phytools">Link</a>           |
| rmarkdown  | <a href="https://cran.r-project.org/package=rmarkdown">Link</a>  | <a href="https://anaconda.org/conda-forge/r-rmarkdown">Link</a>          |
| tidyverse  | <a href="https://cran.r-project.org/package=tidyverse">Link</a>  | <a href="https://anaconda.org/conda-forge/r-tidyverse">Link</a>          |
| yaml       | <a href="https://cran.r-project.org/package=yaml">Link</a>       | <a href="https://anaconda.org/conda-forge/r-yaml">Link</a>               |

## <a id="genpipe">General Pipeline</a>
1. **Clone the Git repository** <br>
    ```
    git clone git@github.com:jeremiasivan/PhyloNOW.git
    ```

2. **Install the prerequisites** <br>
    - Create a new conda environment
        ```
        conda create -n phylonow
        conda activate phylonow
        ```
    -  Installing prerequisites
        ```
        conda install -c conda-forge r-ape r-data.table r-doSNOW r-log4r r-optparse r-phytools r-rmarkdown r-tidyverse r-yaml bioconda::bioconductor-biostrings bioconda::iqtree bioconda::seqkit
        ```

3. **Update the parameters in `config.yaml`** <br>

4. **Run PhyloNOW** <br>
    ```
    Rscript run_pipeline.R --config config.yaml
    Rscript run_pipeline.R --config config.yaml --redo
    ```

    In UNIX-based operating systems (e.g., Linux and MacOS), it is advisable to use `nohup` or `tmux` to run the whole pipeline. For Windows, you can use `psmux`. 

### [Additional Step] Summarise multiple PhyloNOW runs
If you have multiple PhyloNOW runs representing different chromosomes from the same set of taxa, you can summarise the window size variation across chromosomes with `summarise_multiple_runs.R`
1. **Store all PhyloNOW output folders in one folder**
2. **Run `summarise_multiple_runs.R`**
    ```
    Rscript summarise_multiple_runs.R -i /home/user/all_phyloNOW_runs/ -o /home/user/all_phyloNOW_summary/
    ```

## <a id="inout">Input and Output Files</a>

### Input Files
To run PhyloNOW, users are required to provide multiple sequence alignment in FASTA format.

### Output Files
Running PhyloNOW will create an output folder that consists of:
- `fasta/`   : individual folder for the starting window alignments and trees
- `split/`   : individual folder for each iteration of the splitting step, with its respective table summary (`summary_iterXX.tsv`)
- `merge/`   : individual folder for each iteration of the merging step, with its respective table summary (`summary_iterXX.tsv`)
- `final/`   : individual folder for the final window alignments and trees
- `prefix.winsum`  : summary table for individual window alignments and AIC
- `prefix.topsum`  : summary table for individual window alignments and topologies
- `prefix.aicsum`  : summary table for AIC changes after every iteration
- `prefix_all.uqtops`      : proportions of all gene tree topologies
- `prefix_highbs.uqtops`   : proportions of highly-supported gene tree topologies
- `prefix.log`             : PhyloNOW log file
- `prefix_report.html`     : PhyloNOW HTML report

### Example
Please see <a href="/example/">`example/`</a> for example input and output files for running PhyloNOW on mitochondrial DNA of great apes (downloaded from <a href="https://hgdownload.soe.ucsc.edu/goldenPath/hg38/multiz20way">UCSC Genome Browser</a>).

---
## <a id="refs">References</a>
1. Minh, B.Q., et al. (<a href="https://doi.org/10.1093/molbev/msaa015">2020</a>). **IQ-TREE 2: New Models and Efficient Methods for Phylogenetic Inference in the Genomic Era**. *Molecular Biology and Evolution*, *37*(5), 1530–1534.

2. Shen, W., et al. (<a href="https://doi.org/10.1371/journal.pone.0163962">2016</a>). **SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation**. *PLOS ONE*, *11*(10), e0163962.

3. Paradis, E., et al. (<a href="https://doi.org/10.1093/bioinformatics/btg412">2004</a>). **APE: Analyses of Phylogenetics and Evolution in R language**. *Bioinformatics*, *20*(2), 289-290.

4. Pagès, H., et al. (<a href="https://doi.org/10.18129/B9.bioc.Biostrings">2026</a>). **Biostrings: Efficient manipulation of biological strings**. *R package*.

5. Barrett, T., et al. (<a href="https://doi.org/10.32614/CRAN.package.data.table">2026</a>). **data.table: Extension of 'data.frame'**. *R package*.

6. Daniel, F. (<a href="https://cran.r-project.org/package=doSNOW">2022</a>). **doSNOW: Foreach Parallel Adaptor for the 'snow' Package**. *R package*.

7. White, J.M., & Jacobs, A. (<a href="https://doi.org/10.32614/CRAN.package.log4r">2024</a>). **log4r: A Fast and Lightweight Logging System for R, Based on 'log4j'**. *R package*.

8. Davis, T.L. (<a href="https://doi.org/10.32614/CRAN.package.optparse">2026</a>). **optparse: Command Line Option Parser**. *R package*.

9. Revell, L. (<a href="https://doi.org/10.1111/j.2041-210X.2011.00169.x">2011</a>). **phytools: an R package for phylogenetic comparative biology (and other things)**. *Methods in Ecology and Evolution*, *3*(2), 217-223.

10. Allaire, J.J., et al. (<a href="https://doi.org/10.32614/CRAN.package.rmarkdown">2026</a>). **rmarkdown: Dynamic Documents for R**. *R package*.

11. Wickham, H., et al. (<a href="https://doi.org/10.21105/joss.01686">2019</a>). **Welcome to the tidyverse**. *Journal of Open Source Software*, *4*(43), 1686.

12. Stephens, J., et al. (<a href="https://doi.org/10.32614/CRAN.package.yaml">2025</a>). **yaml: Methods to Convert R Data to YAML and Back**. *R package*.

13. Anthropic. (<a href="https://claude.ai/">2026</a>). Claude 4.6 Sonnet was used to generate `config.yaml` and `run_pipeline.R`. 

---
*Last update: 05 August 2026 by Jeremias Ivan*