# SDMs validation via COMADRE database

## Occurrence data
We removed from the COMADRE dataset all mammal populations that had: 1) NA values in the MPM; 2) MPMs that were not ergodic, a necessary condition to obtained the asymptotic growth rate $lambda$; and 3) population that did not have geo-references locations. As we performed the analyses at the species level, we removed sub-species taxonomic classifications. In total, we had 116 populations of 76 species.

We then gathered occurrence locations from several open-access databases (...) using the R package spocc (REF). 
