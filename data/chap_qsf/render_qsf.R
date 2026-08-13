library(arbor)

M = structure(c(-0.145092815160751, -0.00567375123500824, 0.989401519298553,
                   0, 0.98861962556839, -0.0409939587116241, 0.144743040204048,
                   0, 0.0397382006049156, 0.999143242835999, 0.0115571245551109,
                   0, 0, 0, 0, 1), dim = c(4L, 4L))

U = structure(c(1, 0, 0, 0.0199999995529652, 0, 1, 0, 0.213333338499069,
            0, 0, 1, 0, 0, 0, 0, 1), dim = c(4L, 4L))

zoom = 0.5758918

qsf = readRDS("/home/jr/R packages/r-lidar-lab/arbor_book/data/chap_qsf/PRF193_qsf.rds")
dtm = terra::rast("/home/jr/R packages/r-lidar-lab/arbor_book/data/chap_qsf/PRF193_dtm.tif")
dtm = terra::aggregate(dtm, fact = 2)

plot(qsf, pal = "chocolate4") |> lidR::add_dtm3d(dtm)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = view, zoom = zoom, userProjection = U)
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf.png")
rgl::close3d()

plot(qsf, pal = "chocolate4") |> lidR::add_dtm3d(dtm)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = structure(c(-0.472489029169083, 0.123362094163895, 0.872660219669342,
                                    0, 0.88055020570755, 0.0242546293884516, 0.473332047462463, 0,
                                    0.0372251197695732, 0.992065250873566, -0.120086550712585, 0,
                                    0, 0, 0, 1), dim = c(4L, 4L)),
           zoom = 0.2030519,
           userProjection = structure(c(1, 0, 0, 0.353333324193954, 0, 1, 0, 1.71999990940094, 0, 0, 1, 0, 0, 0, 0, 1), dim = c(4L, 4L)))
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf_zoom.png")
rgl::close3d()

merch = qsf_merchantable(qsf)
plot(merch, pal = "chocolate4")  |> lidR::add_dtm3d(dtm)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = view, zoom = zoom, userProjection = U)
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf_merch.png")
rgl::close3d()

merch2 = qsm_merchantable(merch)
plot(merch2, pal = "chocolate4")  |> lidR::add_dtm3d(dtm)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = view, zoom = zoom, userProjection = U)
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf_merch2.png")
rgl::close3d()

merch3 = qsm_merchantable(qsf)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = view, zoom = zoom, userProjection = U)
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf_merch3.png")
rgl::close3d()

stem = qsm_stem(qsf)
plot(stem, pal = "chocolate4") |> lidR::add_dtm3d(dtm)
rgl::bg3d("white")
rgl::par3d(windowRect = c(100, 100, 1000, 1000))
rgl::par3d(userMatrix = view, zoom = zoom, userProjection = U)
rgl::rgl.snapshot("/home/jr/R packages/r-lidar-lab/arbor_book/figures/chap_qsf/qsf_stem.png")
rgl::close3d()
