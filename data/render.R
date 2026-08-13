
file = "/home/jr/R packages/r-lidar-lab/lidRtlsbook/data/Cook/plot1/plot1_r20.laz" ; cut_above_ground = 0.55

colorize_trees = function(las)
{
  p1 <- las@data$foliage    # 0 = wood, 1/2 = foliage
  p2 <- las@data$treeID     # tree IDs (non-continuous)
  n <- max(p2, na.rm = TRUE)   # number of unique trees

  # Example pastel palette
  pal <- pastel.colors(n)   # or any vector of colors per tree
  pal <- t(grDevices::col2rgb(pal))

  # Create vector to store RGB for each point
  cols <- pal[p2, ]

  # Darken foliage points
  foliage = p1 >= 1
  cols[foliage,] =   cols[foliage,] * 0.7
  R = as.integer(cols[,1])
  G = as.integer(cols[,2])
  B = as.integer(cols[,3])
  R[is.na(R)] = 150L
  G[is.na(G)] = 150L
  B[is.na(B)] = 150L

  # Assign to LAS
  las = add_lasrgb(las, R, G, B)
  las
}

# ===== PROCESSING PARAMETERS =====

t0 = Sys.time()

params = default_parameters

las <- readTLS(file, select = "0", filter = filter)

las    <- lidR::classify_ground(las, lidR::csf(rigidness = 1, class_threshold = 0.05, cloth_resolution = 0.1), last_returns = FALSE)
ground <- lidR::filter_poi(las, Classification == LASGROUND)
ground <- lidR::decimate_points(ground, lowest(0.25))
ground <- lidR::classify_noise(ground, sor(k = 10, m = 2))
ground <- lidR::remove_noise(ground)
ground$Classification <- lidR::LASGROUND
gc()

dtm <- lidR::rasterize_terrain(ground, 0.5, lidR::tin())
las <- lidR::height_above_ground(las, algorithm = lidR::tin(), dtm = dtm)
gc()

las <- lidR::filter_poi(las, hag > cut_above_ground)
las <- barycentric_predecimation(las, params)
las <- compute_anisotropy(las, params)
las <- segment_foliage(las, dtm, params)

seeds <- find_seeds(las, params)
seeds@data <- seeds@data[, .SD[sample(.N, max(min(.N, 3), .N/4))], by = treeID]

las <- segment_vegetation(las, seeds, params)
las <- colorize_trees(las)

trees <- remove_small_trees(las, max_heigh = 5)
trees <- fix_small_isolated_low_clusters(trees)

valid_trees <- clip_buffer(trees, -5)

# ==== VARIOUS EXPORTS ====

o <- tools::file_path_sans_ext(file)
t <- paste0(o, "_trees.laz")
v <- paste0(o, "_validtrees.laz")
o <- paste0(o, "_segmented.laz")
d <- paste0(o, "_dtm.tif")

writeLAS(las, o)
writeLAS(trees, t)
writeLAS(valid_trees, v)
terra::writeRaster(dtm, d, overwrite = T)

tree_dir = paste0(dirname(o), "/ITS/las")
if (!dir.exists(tree_dir)) dir.create(tree_dir, recursive = TRUE)
f = list.files(tree_dir, full.names = TRUE)
tmp = file.remove(f)

j = 0
for (i in unique(valid_trees$treeID))
{
  print(i)
  tree <- filter_poi(valid_trees, treeID == i)
  olas <- paste0(tree_dir, "/tree_", j, ".las")
  j = j+1
  writeLAS(tree, olas)
}

# ==== QSM ======

files = list.files(tree_dir, full.names = TRUE)

obj_dir = paste0(dirname(o), "/ITS/obj")
if (!dir.exists(obj_dir)) dir.create(obj_dir, recursive = TRUE)
f = list.files(obj_dir, full.names = TRUE)
tmp = file.remove(f)

csv_dir = paste0(dirname(o), "/ITS/csv")
if (!dir.exists(csv_dir)) dir.create(csv_dir, recursive = TRUE)
f = list.files(csv_dir, full.names = TRUE)
tmp = file.remove(f)

for (i in seq_along(files))
{
  f = files[i]
  tree = readLAS(f)
  qsm  <- qsm(tree, step = 0.1, cl_dist = 0.2)

  ocsv = paste0(csv_dir, "/", tools::file_path_sans_ext(basename(f)), ".csv")
  oobj = paste0(obj_dir, "/", tools::file_path_sans_ext(basename(f)), ".obj")

  qsm_write(qsm, ocsv)
  qsm_write(qsm, oobj)
}

tf = Sys.time()
difftime(tf, t0)
