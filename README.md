# Polynya_CNN2D_GMM
Last updated 22 May 2025 by Céline Heuzé

Main scripts to reproduce the results of Heuzé and Wong (2025), submitted to EGU's The Cryosphere:
0) Obtain the daily sea ice concentration data from NSIDC at https://nsidc.org/data/nsidc-0051/versions/2, and the daily polynya masks from Wong et al. (2025) - link to come when available;
1) Run dataprep.m to prepare the datasets for the network
2) [option] Run CNN2D.ipynb cell 1 to generate your own ensemble of models; alt directly use CNN2D_....keras in CNN2D.ipynb cell 2
3) Run GMM.ipynb
Information about which dataset with which dimension to use where is provided in all scripts.
Enjoy!
