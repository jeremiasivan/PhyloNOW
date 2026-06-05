# phyloNOW

**phyloNOW (phylogenomic non-overlapping windows)** is an R pipeline to partition chromosome alignments onto non-overlapping windows with variable sizes based on local AIC improvements. It consists of two main steps: iterative splitting and iterative merging of neighbouring windows. This pipeline is mainly developed and tested using MacOS and Linux, so there might be incompatibilities using Windows.

> [!NOTE]
> This repository is primarily used to store the code for running phyloNOW with your own input alignments. If you want to simulate chromosome alignments with varying recombination rates and patterns instead, please visit <b>SimNOW (simulation non-overlapping windows)</b> Github <a href="https://github.com/jeremiasivan/SimNOW">repository</a>.

**If you use this pipeline, please cite as:**
```
J. Ivan & R. Lanfear. (2026). Using Variable Window Sizes for Phylogenomic Analyses of Whole Genome Alignments, bioRxiv. doi:10.64898/2026.03.04.709403
```

## Table of Content
- <a href="#prereqs">Prerequisites</a>
- <a href="#genpipe">General Pipeline</a>
- <a href="#timecom">Time Complexity</a>
- <a href="#refs">References</a>

## <a id="prereqs">Prerequisites</a>
This pipeline requires several software and R packages to run. All software have to be executable, while the R packages should be installed either in your local directory or virtual environment. We recommend you to use environment management system (e.g. `conda`) to install the packages, but you can also use `install.packages()` built-in function in R or RStudio.

### Software
- <a href="http://www.iqtree.org">IQ-TREE 2</a>
- <a href="https://bioinf.shenwei.me/seqkit/">SeqKit</a>

### R packages
|    Name    |                               CRAN                               |                             Anaconda                             |
| ---------- |:----------------------------------------------------------------:|:----------------------------------------------------------------:|
| data.table | <a href="https://cran.r-project.org/package=data.table">Link</a> | <a href="https://anaconda.org/conda-forge/r-data.table">Link</a> |
| doSNOW     | <a href="https://cran.r-project.org/package=doSNOW">Link</a>     | <a href="https://anaconda.org/conda-forge/r-dosnow">Link</a>     |
| log4r      | <a href="https://cran.r-project.org/package=log4r">Link</a>      | <a href="https://anaconda.org/conda-forge/r-log4r">Link</a>      |
| phangorn   | <a href="https://cran.r-project.org/package=phangorn">Link</a>   | <a href="https://anaconda.org/conda-forge/r-phangorn">Link</a>   |
| rmarkdown  | <a href="https://cran.r-project.org/package=rmarkdown">Link</a>  | <a href="https://anaconda.org/conda-forge/r-rmarkdown">Link</a>  |
| seqinr     | <a href="https://cran.r-project.org/package=seqinr">Link</a>     | <a href="https://anaconda.org/conda-forge/r-seqinr">Link</a>     |
| tidyverse  | <a href="https://cran.r-project.org/package=tidyverse">Link</a>  | <a href="https://anaconda.org/conda-forge/r-tidyverse">Link</a>  |

## <a id="genpipe">General Pipeline</a>
1. **Clone the Git repository** <br>
    ```
    git clone git@github.com:jeremiasivan/phyloNOW.git
    ```

2. **Install the prerequisites** <br>
    Please download `ms`, `IQ-TREE 2`, and `SeqKit` from the links above. For the `R` packages, I prefer to download them from `Anaconda` as below.

    - Setting up conda environment with R
        ```
        conda create -n phylonow
        conda activate phylonow
        ```
    -  Installing R packages
        ```
        conda install package-name
        ```
        Notes: Please install all of the R packages and their dependencies. A good starting point is to install <a href="https://anaconda.org/conda-forge/r-essentials">`r-essentials`</a> which includes commonly-used packages in R. 

3. **Update the parameters in the file** <br>
    Please refer to <a href="/codes/README.md">`codes/README.md`</a> for the details of each parameter and which files to be updated. 

4. **Run the code file** <br>
    For running the whole pipeline:
    ```
    Rscript -e "rmarkdown::render('~/phyloNOW/codes/1_main.Rmd')"
    ```

    In UNIX-based operating systems (e.g., Linux and MacOS), it is advisable to use `nohup` or `tmux` to run the whole pipeline. For Windows, you can use `start`, but I have never tried it before. 

---
## <a id="refs">References</a>
1. Minh, B.Q., et al. (<a href="https://doi.org/10.1093/molbev/msaa015">2020</a>). **IQ-TREE 2: New Models and Efficient Methods for Phylogenetic Inference in the Genomic Era**. *Molecular Biology and Evolution*, *37*(5), 1530–1534.

2. Shen et al. (<a href="https://doi.org/10.1371/journal.pone.0163962">2016</a>). **SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation**. *PLOS ONE*, *11*(10), e0163962.

---
*Last update: 05 June 2026 by Jeremias Ivan*