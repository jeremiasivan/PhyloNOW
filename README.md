# PhyloNOW

**PhyloNOW (Phylogenomic Non-Overlapping Windows)** is an R pipeline to partition chromosome alignments into non-overlapping windows with variable sizes based on local AIC improvements. It consists of two main steps: iterative splitting and iterative merging of neighbouring windows. This pipeline is mainly developed and tested using MacOS and Linux, so there might be incompatibilities using Windows.

> [!NOTE]
> This repository stores the R codes for running PhyloNOW with your own input alignments. If you want to simulate chromosome alignments with varying recombination rates <i>or</i> run non-overlapping windows with fixed window sizes, please visit <b>SimNOW (Simulation Non-Overlapping Windows)</b> Github <a href="https://github.com/jeremiasivan/SimNOW">repository</a>.

**If you use PhyloNOW, please cite as:**
```
J. Ivan & R. Lanfear. (2026). Using Variable Window Sizes for Phylogenomic Analyses of Whole Genome Alignments, bioRxiv. doi:10.64898/2026.03.04.709403
```

## Table of Content
- <a href="#prereqs">Prerequisites</a>
- <a href="#genpipe">General Pipeline</a>
- <a href="#timecom">Time Complexity</a>
- <a href="#refs">References</a>

## <a id="prereqs">Prerequisites</a>
PhyloNOW requires several software and R packages to run. We recommend you to use environment management system (e.g. `conda`) to install the prerequisites, but you can also use `install.packages()` built-in function in R or RStudio.

### Software
|    Name    |                             Website                              |                             Anaconda                             |
| ---------- |:----------------------------------------------------------------:|:----------------------------------------------------------------:|
| IQ-TREE    | <a href="http://www.iqtree.org">Link</a>                         | <a href="https://anaconda.org/bioconda/iqtree">Link</a>          |
| SeqKit     | <a href="https://bioinf.shenwei.me/seqkit/">Link</a>             | <a href="https://anaconda.org/bioconda/seqkit">Link</a>          |

### R packages
|    Name    |                               CRAN                               |                             Anaconda                             |
| ---------- |:----------------------------------------------------------------:|:----------------------------------------------------------------:|
| data.table | <a href="https://cran.r-project.org/package=data.table">Link</a> | <a href="https://anaconda.org/conda-forge/r-data.table">Link</a> |
| doSNOW     | <a href="https://cran.r-project.org/package=doSNOW">Link</a>     | <a href="https://anaconda.org/conda-forge/r-dosnow">Link</a>     |
| log4r      | <a href="https://cran.r-project.org/package=log4r">Link</a>      | <a href="https://anaconda.org/conda-forge/r-log4r">Link</a>      |
| optparse   | <a href="https://cran.r-project.org/package=optparse">Link</a>   | <a href="https://anaconda.org/conda-forge/r-optparse">Link</a>   |
| phangorn   | <a href="https://cran.r-project.org/package=phangorn">Link</a>   | <a href="https://anaconda.org/conda-forge/r-phangorn">Link</a>   |
| rmarkdown  | <a href="https://cran.r-project.org/package=rmarkdown">Link</a>  | <a href="https://anaconda.org/conda-forge/r-rmarkdown">Link</a>  |
| seqinr     | <a href="https://cran.r-project.org/package=seqinr">Link</a>     | <a href="https://anaconda.org/conda-forge/r-seqinr">Link</a>     |
| tidyverse  | <a href="https://cran.r-project.org/package=tidyverse">Link</a>  | <a href="https://anaconda.org/conda-forge/r-tidyverse">Link</a>  |
| yaml       | <a href="https://cran.r-project.org/package=yaml">Link</a>       | <a href="https://anaconda.org/conda-forge/r-yaml">Link</a>       |

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
        conda install -c conda-forge r-data.table r-doSNOW r-log4r r-optparse r-phangorn r-markdown r-seqinr r-tidyverse r-yaml bioconda::iqtree bioconda::seqkit
        ```

3. **Update the parameters in config.yaml** <br>

4. **Run PhyloNOW** <br>
    ```
    Rscript run_pipeline.R --config config.yaml
    Rscript run_pipeline.R --config config.yaml --redo
    ```

    In UNIX-based operating systems (e.g., Linux and MacOS), it is advisable to use `nohup` or `tmux` to run the whole pipeline. For Windows, you can use `psmux`. 

---
## <a id="refs">References</a>
1. Minh, B.Q., et al. (<a href="https://doi.org/10.1093/molbev/msaa015">2020</a>). **IQ-TREE 2: New Models and Efficient Methods for Phylogenetic Inference in the Genomic Era**. *Molecular Biology and Evolution*, *37*(5), 1530–1534.

2. Shen et al. (<a href="https://doi.org/10.1371/journal.pone.0163962">2016</a>). **SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation**. *PLOS ONE*, *11*(10), e0163962.

3. Anthropic. (2026). Claude 4.6 Sonnet was used to generate `config.yaml` and `run_pipeline.R`. 

---
*Last update: 06 June 2026 by Jeremias Ivan*