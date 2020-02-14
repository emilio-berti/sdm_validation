# SDMs validation via COMADRE database

## Code pipeline
  1. get_species.R
  2. get_occurrences.R
  3. clean_occurrences.R
  4. grin_records.R (this eats a lot of memory; do not parallelize with < 32 Gb of RAM)

## Occurrence data
We removed from the COMADRE dataset all mammal populations that had: 1) NA values in the MPM; 2) MPMs that were not ergodic, a necessary condition to obtained the asymptotic growth rate $lambda$; 3) population that did not have geo-references locations; and 4) captive or manipulated populations. As we performed the analyses at the species level, we removed sub-species taxonomic classifications. In total, we had 116 populations of 76 species.

We then gathered occurrence locations from several open-access databases (...) using the R package spocc (REF). We then removed spurious data points using R package CoordinateCleaner and thinned the remaining occurence records to have a separation distance of at least 10 km. In total, we identified # species with at least 30 occurrence locations for modelling.

Table: Number of occurrence records (n) per species. Records were obtained from multiple databases using the R package spocc, excluding spurious observations, and the occurrences were then thinned to ensure a minimum distance between point >= 10 km.

|species                     |    n|
|:---------------------------|----:|
|Lycaon pictus               |   34|
|Elephas maximus             |   40|
|Didelphis aurita            |   48|
|Phacochoerus aethiopicus    |   75|
|Pan troglodytes             |   88|
|Saguinus fuscicollis        |   89|
|Papio cynocephalus          |  123|
|Acinonyx jubatus            |  135|
|Lycalopex culpaeus          |  141|
|Eidolon helvum              |  146|
|Cebus capucinus             |  147|
|Urocitellus armatus         |  164|
|Cercopithecus mitis         |  173|
|Panthera pardus             |  185|
|Chlorocebus aethiops        |  194|
|Erythrocebus patas          |  224|
|Giraffa camelopardalis      |  273|
|Ursus maritimus             |  289|
|Urocitellus columbianus     |  322|
|Dipodomys spectabilis       |  328|
|Alouatta seniculus          |  347|
|Connochaetes taurinus       |  352|
|Kobus ellipsiprymnus        |  362|
|Trichosurus caninus         |  378|
|Tamiasciurus douglasii      |  547|
|Marmota flaviventris        |  662|
|Microtus oeconomus          |  782|
|Petaurus australis          |  814|
|Ovis canadensis             |  890|
|Phascolarctos cinereus      |  970|
|Callospermophilus lateralis | 1032|
|Petauroides volans          | 1094|
|Puma concolor               | 1311|
|Macaca mulatta              | 1666|
|Rangifer tarandus           | 1743|
|Lontra canadensis           | 1819|
|Dasypus novemcinctus        | 1943|
|Ursus arctos                | 2017|
|Gulo gulo                   | 2036|
|Sciurus niger               | 2150|
|Sigmodon hispidus           | 2237|
|Lynx rufus                  | 2785|
|Ursus americanus            | 3012|
|Tamiasciurus hudsonicus     | 3044|
|Odocoileus virginianus      | 3170|
|Vulpes vulpes               | 3195|
|Canis latrans               | 4401|
|Alces alces                 | 4826|
|Procyon lotor               | 5092|
|Cervus elaphus              | 5582|
|Lutra lutra                 | 7509|
|Canis lupus                 | 7892|
|Sus scrofa                  | 8648|
