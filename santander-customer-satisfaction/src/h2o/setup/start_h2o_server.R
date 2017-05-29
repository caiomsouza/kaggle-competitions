library(h2oEnsemble)  # This will load the `h2o` R package as well
#h2o.init(nthreads = -1)  # Start an H2O cluster with nthreads = num cores on your machine
h2o.init(nthreads = -1, ip = "localhost", port = 54321, startH2O = TRUE, max_mem_size="6g", min_mem_size = "6g")
h2o.removeAll() # Clean slate - just in case the cluster was already running
