package_type_distro <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  package_type = unique(mydata$packagetype)
  advisories <- c()
  for(x in package_type){
    #d <- mydata[ which(mydata$package.type==x & grepl('CVE', mydata$file)), ]
    d <- mydata[ which(mydata$packagetype==x), ]
    advisories <- c(advisories, nrow(d))
  }
  pct <- round(advisories/sum(advisories)*100)
  package_type <- paste(package_type,"#")
  package_type <- paste(package_type, advisories)
  package_type <- paste(package_type,"(",pct)
  package_type <- paste(package_type,"%",sep="")
  package_type <- paste(package_type,")")
  pie(advisories, labels = package_type, main=paste("Advisory Distribution (Package Type) Total:", sum(advisories)))
}

cve_distro <- function(csv) {
  advisory_type <- c("CVEs", "Non CVEs")
  advisories <- c()
  mydata = read.table(csv, header = TRUE,  sep = ",")
  # CVEs
  cves <- mydata[ which(grepl('CVE', mydata$file)), ]
  advisories <- c(advisories, nrow(cves))
  
  # Non CVEs
  ncves <- mydata[ which(!grepl('CVE', mydata$file)), ]
  advisories <- c(advisories, nrow(ncves))
  
  pct <- round(advisories/sum(advisories)*100)
  advisory_type <- paste(advisory_type,"#")
  advisory_type <- paste(advisory_type, advisories)
  advisory_type <- paste(advisory_type,"(",pct)
  advisory_type <- paste(advisory_type,"%",sep="")
  advisory_type <- paste(advisory_type,")")
  pie(advisories, labels = advisory_type,  main=paste("Advisory Distribution (CVEs) Total:", sum(advisories)))
}

mean_time_to_merge <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  delta_data <- mydata[ which(mydata$delta>=0 & grepl('CVE', mydata$file)), ]
  mean(delta_data$delta)
}

median_time_to_merge <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  delta_data <- mydata[ which(mydata$delta>=0 & grepl('CVE', mydata$file)), ]
  median(delta_data$delta)
}

merged_advisories <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  creation_date = c(cve_data$mergedate)
  x <- as.POSIXct(cve_data$mergedate)
  mo <- strftime(x, "%m")
  yr <- strftime(x, "%Y")
  dd <- data.frame(mo, yr, amt = 1)
  agg <- aggregate(amt ~ mo + yr, dd, FUN = sum)
  agg$date = paste(agg$yr, agg$mo, sep = "-")
  xx <- barplot(agg$amt, 
          col = terrain.colors(6), 
          xlab="", 
          ylab="#CVEs Advisories added", 
          ylim = c(0,max(agg$amt)*1.1),
          args.legend = list(bty = 'n', x = 'top', ncol = 1))
  text(x = xx, y = agg$amt, label = agg$amt, pos = 3, cex = 0.8, col = "orange3")
  axis(1, at=xx, labels=agg$date, tick=FALSE, las=2, line=-0.5)
}

throughput <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  x <- as.POSIXct(cve_data$mergedate)
  mo <- strftime(x, "%m")
  yr <- strftime(x, "%Y")
  dd <- data.frame(mo, yr, amt = 1)
  agg <- aggregate(amt ~ mo + yr, dd, FUN = sum)
  agg$date = paste(agg$yr, agg$mo, "01",  sep = "-")
  agg$month = paste(agg$yr, agg$mo,  sep = "-")
  diff = c()
  entrynum = length(agg$date)
  for (i in 1:entrynum-1) {
    date1 = as.Date(agg$date[i], format="%Y-%m-%d")
    date2 = as.Date(agg$date[i+1], format="%Y-%m-%d")
    diff = c(diff, date2-date1)
  }
  agg$daydiff = c(diff, Sys.Date() - as.Date(agg$date[entrynum], format="%Y-%m-%d"))
  agg$throughput <- ifelse(agg$daydiff==0,0,agg$amt/agg$daydiff)
  date <- as.Date(agg$date, "%Y-%m-%d")
  xx <- barplot(agg$throughput, 
                col = terrain.colors(6), 
                xlab="", 
                ylab="Throughput (#CVE/days)", 
                ylim = c(0,max(agg$throughput)*1.5),
                args.legend = list(bty = 'n', x = 'top', ncol = 1))
  text(x = xx, y = agg$throughput, label = round(agg$throughput, digits = 1), pos = 3, cex = 0.8, col = "orange3")
  axis(1, at=xx, labels=paste(agg$yr, agg$mo,  sep = "-"), tick=FALSE, las=2, line=-0.5)
  
}

coverage <- function(csv, nvd_fee) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  nvddata = read.table(nvd_fee, header = FALSE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  # take CVE identifier instead of pubdate because this CVE denotes
  # the feed to which the CVE belongs to
  cve_data$cve_yr <- sub("^.*CVE-([0-9]+)-.*", "\\1-01-01", cve_data$file)
  labelled_nvddata = data.frame(yr = nvddata$V1, total = nvddata$V2)
  x <- as.POSIXct(cve_data$cve_yr)
  yr <- strftime(x, "%Y")
  dd <- data.frame(yr, amt = 1)
  agg <- aggregate(amt ~ yr, dd, FUN = sum)
  joined = merge(x=agg,y=labelled_nvddata,by="yr")
  joined$coverage = joined$amt/joined$total * 100
  xx <- barplot(joined$coverage, 
                col = terrain.colors(6), 
                xlab="NVD Feed Year", 
                ylab="Coverage (%)", 
                ylim = c(0,max(joined$coverage)*1.1),
                args.legend = list(bty = 'n', x = 'top', ncol = 1))
  text(x = xx, y = joined$coverage, label = paste(round(joined$coverage, digits = 2), '%'), pos = 3, cex = 0.66, col = "orange3")
  axis(1, at=xx, labels=joined$yr, tick=FALSE, las=2, line=-0.5)
}

mean_ttm_month <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  x <- as.POSIXct(cve_data$mergedate)
  mo <- strftime(x, "%m")
  yr <- strftime(x, "%Y")
  dd <- data.frame(mo, yr, delta = cve_data$delta, amt = 1)
  agg <- aggregate(delta ~ mo + yr, dd, FUN = mean)

  agg$date = paste(agg$yr, agg$mo, "01",  sep = "-")
  agg$month = paste(agg$yr, agg$mo,  sep = "-")
  agg = agg[-1,]
  xx <- barplot(agg$delta, 
                col = terrain.colors(6), 
                xlab="", 
                ylab="MTTM", 
                ylim = c(0,max(agg$delta)*1.5),
                args.legend = list(bty = 'n', x = 'top', ncol = 1))
  text(x = xx, y = agg$delta, label = round(agg$delta), pos = 3, cex = 0.8, col = "orange3")
  axis(1, at=xx, labels=agg$month, tick=FALSE, las=2, line=-0.5)
}

median_ttm_month <- function(csv) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)) & mydata$delta >= 0, ]
  x <- as.POSIXct(cve_data$mergedate)
  mo <- strftime(x, "%m")
  yr <- strftime(x, "%Y")
  dd <- data.frame(mo, yr, delta = cve_data$delta)
  agg <- aggregate(delta ~ mo + yr, dd, FUN = median)
  
  agg$date = paste(agg$yr, agg$mo, "01",  sep = "-")
  agg$month = paste(agg$yr, agg$mo,  sep = "-")
  agg = agg[-1,]
  xx <- barplot(agg$delta, 
                col = terrain.colors(6), 
                xlab="", 
                ylab="Median TTM", 
                ylim = c(0,max(agg$delta)*1.5),
                args.legend = list(bty = 'n', x = 'top', ncol = 1))
  text(x = xx, y = agg$delta, label = round(agg$delta), pos = 3, cex = 0.8, col = "orange3")
  axis(1, at=xx, labels=agg$month, tick=FALSE, las=2, line=-0.5)
}

end_of_mo <- function(date_str) {
  d <- as.Date(date_str)
  day(d) <- days_in_month(d)
  d
}

acc_ttm_month <- function(csv, accumulate = TRUE, window_size_days = -1) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  
  subtitle = ""
  
  # delta is: t(merge_date) - t(pubdate)
  # only consider advisories where delta < window_size_days
  if(window_size_days > 0) {
    cve_data <- cve_data[ cve_data$delta < window_size_days & cve_data$delta >= 0, ]
    subtitle = paste("for advisories merged within", window_size_days, "days")
  }
  cve_data$dmergedate <- as.Date(cve_data$mergedate)
  x <- as.POSIXct(cve_data$mergedate)
  mo <- strftime(x, "%m")
  yr <- strftime(x, "%Y")
  dd <- data.frame(mo, yr, delta = cve_data$delta, adnum = 1)
  agg <- aggregate(. ~ mo + yr, dd, FUN = function(x) c(sum = sum(x)))
  t = paste(agg$yr, agg$mo, '01',  sep = '-')
  agg$date <- as.Date(t, "%Y-%m-%d")
  
  acc_delta = c(agg[1, "delta"])
  acc_adnum = c(agg[1, "adnum"])
  start_date = agg[1, "date"]
  end_date = end_of_mo(start_date)
  
  median_selection = cve_data[cve_data$dmergedate >= start_date & cve_data$dmergedate <= end_date,]
  acc_median = c(median(median_selection$delta))
  
  # Compute time differences for the past month
  for(row in 2:nrow(agg)){
    delta_cur <- agg[row, "delta"]
    adnum_cur <- agg[row, "adnum"]
    end_date <- end_of_mo(agg[row, "date"])
    last_acc_delta = tail(acc_delta, n = 1)
    last_acc_adnum = tail(acc_adnum, n = 1)
    median_selection = cve_data[cve_data$dmergedate >= start_date & cve_data$dmergedate <= end_date,]
    acc_median <- c(acc_median, median(median_selection$delta))
    computed_delta = delta_cur
    computed_adnum = adnum_cur
    # accumulate time differentes/ advisory numbers
    if(accumulate){
      computed_delta = last_acc_delta + delta_cur
      computed_adnum = last_acc_adnum + adnum_cur
    }
    acc_delta <- c(acc_delta, computed_delta)
    acc_adnum <- c(acc_adnum, computed_adnum)
  }
  
  agg <- data.frame(agg, acc_delta, acc_adnum, acc_median)
  agg$acc_mttm <- agg$acc_delta/agg$acc_adnum
  
  ulimit = max(agg$acc_median, agg$acc_mttm)
  llimit = min(agg$acc_median, agg$acc_mttm)
  
  plot(agg$acc_mttm~agg$date,log = "y", xaxt='n', type='b', ylab = "TTM (days)", xlab = "", col = "blue", ylim=c(llimit*0.9,ulimit*1.2))
  title(bquote("Mean" ~ phantom("and") ~ phantom("Median TTM") ~ .(subtitle)),col.main="blue")
  title(bquote(phantom("Mean") ~ phantom("and") ~ "Median TTM" ~ .(subtitle)),col.main="green")
  title(bquote(phantom("Mean") ~ "and" ~ phantom("Median TTM") ~ .(subtitle)),col.main="black")
  
  lines(agg$acc_median~agg$date, type = "b", col = "green")
  axis(1, agg$date, format(agg$date, "%Y-%m"), las=2)
}

acc_ttm_week_box <- function(csv, weekly=TRUE, window_size_days = -1) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  subtitle = ""
  if(window_size_days > 0) {
    cve_data <- cve_data[ cve_data$delta < window_size_days & cve_data$delta >= 0, ]
    subtitle = paste("with a", window_size_days, "days merge window")
    slog = ''
  } else {
    cve_data <- cve_data[ cve_data$delta >= 0, ]
    subtitle = ""
    slog = 'y'
  }
  
  cve_data$dmergedate <- as.Date(cve_data$mergedate)
  x <- as.POSIXct(cve_data$mergedate)
  moyr <- strftime(x, "%Y-%m")
  weekyr <- strftime(cve_data$mergedate, format = "%Y-%V")
  dd <- data.frame(moyr, weekyr, delta = cve_data$delta, adnum = 1)
  
  type = ""
  if(weekly) {
    boxplot(dd$delta ~ dd$weekyr, xaxt='n', type='b', log = slog, ylab = "TTM (days)", xlab = "", col = "lightgrey", medcol="steelblue")
    meanagg <- aggregate(delta ~ weekyr, dd, FUN = mean)
    medianagg <- aggregate(delta ~ weekyr, dd, FUN = median)
    total <- aggregate(adnum ~ weekyr, dd, FUN = sum)
    type = "Weekly"
    axis(1, dd$weekyr, dd$weekyr, las=3)
  } else {
    boxplot(dd$delta ~ dd$moyr, xaxt='n', type='b', log = slog, ylab = "TTM (days)", xlab = "", col = "lightgrey", medcol="steelblue")
    meanagg <- aggregate(delta ~ moyr, dd, FUN = mean)
    medianagg <- aggregate(delta ~ moyr, dd, FUN = median)
    total <- aggregate(adnum ~ moyr, dd, FUN = sum)
    type = "Monthly"
    axis(1, dd$moyr, dd$moyr, las=2)
  }

  points(meanagg,col="orange3", pch=18)
#  text(meanagg, 
#       labels = round(meanagg$delta,1),
#       pos = 2, cex = 0.9, font = 1, col = "orange3")
  
#  text(medianagg, 
#       labels = round(medianagg$delta,1),
#       pos = 4, cex = 0.9, font = 1, col = "midnightblue")

  title(paste(type, "TTM distribution", subtitle))
  #print(total)
}

acc_ttm_week_band <- function(csv, weekly=TRUE, window_size_days = -1) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  subtitle = ""
  if(window_size_days > 0) {
    cve_data <- cve_data[ cve_data$delta < window_size_days & cve_data$delta >= 0, ]
    subtitle = paste("with a", window_size_days, "days merge window")
  } else {
    cve_data <- cve_data[ cve_data$delta >= 0, ]
    subtitle = ""
  }
  
  cve_data$dmergedate <- as.Date(cve_data$mergedate)
  x <- as.POSIXct(cve_data$mergedate)
  moyr <- strftime(x, "%Y-%m")
  weekyr <- strftime(cve_data$mergedate, format = "%Y-%V")
  dd <- data.frame(moyr, weekyr, delta = cve_data$delta, adnum = 1)
  
  type = ""
  if(weekly) {
    tframe = delta ~ weekyr
  } else {
    tframe = delta ~ moyr
  }
  aggmean <- setNames(aggregate(tframe, dd, FUN = mean), c("period", "mean"))
  aggmedian <- setNames(aggregate(tframe, dd, FUN = median), c("period", "median"))
  aggtotal <- setNames(aggregate(tframe, dd, FUN = sum), c("period", "total"))
  aggmin <- setNames(aggregate(tframe, dd, FUN = min), c("period", "min"))
  aggmax <- setNames(aggregate(tframe, dd, FUN = max), c("period", "max"))
    
  plotdata = merge(merge(merge(merge(aggtotal, aggmin, by="period"), aggmax, by="period"), aggmean, by = "period"), aggmedian, by = "period")
  p = ggplot(plotdata, aes(x=plotdata$period, group = 1))
  p = p + geom_ribbon(aes(x = period, ymin=min,ymax=max),fill="gray",alpha=0.5) 
  if (weekly) {
    type = "Weekly"
  } else {
    type = "Monthly"
  }

  p = p + geom_line(aes(y = median), color = "blue") + ylim(0, max(plotdata$max)*1.1)
  p = p + geom_line(aes(y = mean), color = "orange3")
  p = p + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  p = p + labs(size= "Nitrogen",
               x = "",
               y = "TTM",
               title = paste(type, "TTM measures", subtitle))
  p = p + geom_text(aes(label = sprintf("%.1f",round(mean,1)), y = 30), size = 3, color = "orange3")
  p = p + geom_text(aes(label = sprintf("%.1f",round(median,1)), y = 29), size = 3, color = "blue")
  p = p + geom_hline(yintercept=7, color = "red", linetype = 'dashed', size=0.5)
  show(p)
}

acc_ttm_week_facets <- function(csv, weekly=TRUE, window_size_days = -1) {
  mydata = read.table(csv, header = TRUE,  sep = ",")
  cve_data <- mydata[ which(grepl('CVE', mydata$file)), ]
  subtitle = ""
  if(window_size_days > 0) {
    cve_data <- cve_data[ cve_data$delta < window_size_days & cve_data$delta >= 0, ]
    subtitle = paste("for a", window_size_days, "days merge window")
  } else {
    cve_data <- cve_data[ cve_data$delta >= 0, ]
    subtitle = ""
  }
  
  cve_data$dmergedate <- as.Date(cve_data$mergedate)
  x <- as.POSIXct(cve_data$mergedate)
  moyr <- strftime(x, "%Y-%m")
  weekyr <- strftime(cve_data$mergedate, format = "%Y-%V")
  dd <- data.frame(moyr, weekyr, delta = cve_data$delta, adnum = 1)

  if (weekly) {
    type = "Weekly"
    tframe = weekyr
  } else {
    type = "Monthly"
    tframe = moyr
  }
  
  agg = aggregate(adnum~tframe+delta, dd, FUN = sum)
  
  p <- ggplot(data = agg, aes(x=agg$delta, weight=agg$adnum)) + 
    geom_histogram(binwidth = 1, colour="black") + 
    facet_wrap(tframe ~ .) + geom_vline(aes(xintercept=7), color="red", linetype="dashed", size=1)
  
  p = p + labs(size= "Nitrogen",
               x = "Days",
               y = "Number of Advisories",
               title = paste(type, "advisory distribution", subtitle))
  show(p)
}

#print(median_time_to_merge('../data/data.csv'))
#acc_mean_ttm_month('../data/data.csv')
#throughput('../data/data.csv')
#coverage('data/data.csv', 'data/nvd.csv')
#package_type_distro('../data/data.csv')
#cve_distro('../data/data.csv')
#merged_advisories('../data/data.csv')
#print(mean_time_to_merge('../data/data.csv'))
#print(median_time_to_merge('../data/data.csv'))
#acc_ttm_month('data/data.csv', FALSE, 30)
#acc_ttm_week_box('data/data.csv', TRUE)
#acc_ttm_month('data/data.csv', FALSE, 30)
#median_ttm_month('../data/data.csv')
#acc_ttm_week_box('data/data.csv', TRUE, 30)
#acc_ttm_week_facets('data/data.csv', TRUE, 30)
#acc_ttm_week_band('data/data.csv', TRUE, 30)

