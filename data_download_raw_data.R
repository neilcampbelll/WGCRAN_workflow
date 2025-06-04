
for(i in 2023:2009){

data <- icesVMS::get_vms(year = i)

saveRDS(data, paste0("data/VMS", i, ".RDS"))

}

