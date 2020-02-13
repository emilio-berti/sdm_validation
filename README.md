# SDMs validation via COMADRE database

## Code pipeline
  1. get_species.R
  2. get_occurrences.R
  3. clean_occurrences.R
  4. grin_records.R (this eats a lot of memory; do not parallelize with < 16 Gb RAM)

## Occurrence data
We removed from the COMADRE dataset all mammal populations that had: 1) NA values in the MPM; 2) MPMs that were not ergodic, a necessary condition to obtained the asymptotic growth rate $lambda$; and 3) population that did not have geo-references locations. As we performed the analyses at the species level, we removed sub-species taxonomic classifications. In total, we had 116 populations of 76 species.

We then gathered occurrence locations from several open-access databases (...) using the R package spocc (REF). We then removed spurious data points using R package CoordinateCleaner and thinned the remaining occurence records to have a separation distance of at least 10 km. In total, we identified # species with at least 30 occurrence locations for modelling.

Table: Number of occurrence records (n) per species, obtained from multiple databases using R package spocc.
|Species                     |    n|
|:---------------------------|----:|
|Beatragus hunteri           |   12|
|Brachyteles hypoxanthus     |   16|
|Clethrionomys rufocanus     |   48|
|Spermophilus dauricus       |   55|
|Hippocamelus bisulcus       |   91|
|Saguinus imperator          |   96|
|Propithecus edwardsi        |   97|
|Hemitragus jemlahicus       |  122|
|Macropus eugenii            |  222|
|Didelphis aurita            |  247|
|Onychogalea fraenata        |  253|
|Gorilla beringei            |  285|
|Propithecus verreauxi       |  362|
|Saguinus fuscicollis        |  369|
|Chlorocebus aethiops        |  377|
|Trichosurus caninus         |  496|
|Papio cynocephalus          |  506|
|Dipodomys spectabilis       |  554|
|Pan troglodytes             |  603|
|Microtus oeconomus          |  604|
|Phacochoerus aethiopicus    |  619|
|Lycalopex culpaeus          |  620|
|Arctocephalus australis     |  700|
|Erythrocebus patas          |  707|
|Capra ibex                  |  747|
|Lycaon pictus               |  851|
|Elephas maximus             |  856|
|Cercopithecus mitis         |  857|
|Leptonychotes weddellii     |  874|
|Connochaetes taurinus       |  889|
|Macaca mulatta              |  919|
|Alouatta seniculus          |  941|
|Lutra lutra                 |  942|
|Cebus capucinus             |  967|
|Gulo gulo                   |  970|
|Kobus ellipsiprymnus        |  971|
|Giraffa camelopardalis      |  979|
|Acinonyx jubatus            |  987|
|Eidolon helvum              | 1008|
|Panthera pardus             | 1016|
|Petaurus australis          | 1036|
|Urocyon littoralis          | 1048|
|Urocitellus columbianus     | 1073|
|Marmota flaviventris        | 1105|
|Petauroides volans          | 1108|
|Urocitellus armatus         | 1118|
|Ursus arctos                | 1232|
|Alces alces                 | 1255|
|Sigmodon hispidus           | 1271|
|Phocarctos hookeri          | 1337|
|Lontra canadensis           | 1373|
|Ovis canadensis             | 1405|
|Ursus americanus            | 1444|
|Cervus elaphus              | 1463|
|Mirounga leonina            | 1464|
|Puma concolor               | 1469|
|Callospermophilus lateralis | 1491|
|Canis latrans               | 1497|
|Rangifer tarandus           | 1498|
|Odocoileus virginianus      | 1506|
|Ursus maritimus             | 1525|
|Dasypus novemcinctus        | 1549|
|Tamiasciurus douglasii      | 1550|
|Tamiasciurus hudsonicus     | 1556|
|Phascolarctos cinereus      | 1579|
|Eumetopias jubatus          | 1603|
|Halichoerus grypus          | 1643|
|Procyon lotor               | 1661|
|Physeter macrocephalus      | 1694|
|Canis lupus                 | 1715|
|Lynx rufus                  | 1724|
|Sus scrofa                  | 1763|
|Sciurus niger               | 1849|
|Vulpes vulpes               | 1877|
|Zalophus californianus      | 2014|
