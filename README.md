rdcq
================

A package implementing methods for the estimation of cell abundaces from
omics data.

## Install

``` r
devtools::install_github("ddiez/rdcq")
```

## Usage

Load the package and run the shiny application by typing:

``` r
library(rdcq)
dcqUI()
```

## Acknowledgement

The purpose of this package is to implement several published methods
for the quantification of cell abundances, as well to provide a platform
for developing variants of these methods. Currently implements the
following published methods:

  - Digital Cell Quantification (DCQ), available at
    <http://dcq.tau.ac.il> and in the R package
    [ComICS](https://cran.r-project.org/package=ComICS).
