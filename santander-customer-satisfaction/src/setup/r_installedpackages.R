# R Installation and Administration
# https://cran.r-project.org/doc/manuals/r-release/R-admin.html


sessionInfo()

packages = installed.packages()
rownames(packages) # to see all installed packages
colnames(packages) # to see all fields

#packages["sp",c("Package","Version","License")]
