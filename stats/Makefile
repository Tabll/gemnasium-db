prepare_data: nvd-mirror-data
	mkdir -p data
	./scripts/prepare_data.rb .. data
	cp nvd.csv data/nvd.csv
	R -e "setwd('./scripts'); rmarkdown::render('stats.Rmd')"
	mkdir -p ../public
	cp scripts/stats.html ../public/index.html	
	tar -czvf data/data.tar.gz data/data.csv
	tar -czvf data/nvd.tar.gz data/nvd.csv
	cp -a data ..

nvd-mirror-data:
	git clone https://guest:${NVD_MIRROR_GUEST_TOKEN}@gitlab.com/gitlab-org/secure/vulnerability-research/advisories/nvd-mirror-data.git --depth 1	
	unzip nvd-mirror-data/nvd.db.zip
	scripts/nvd_stats.rb db/nvd.db nvd.csv

clean:
	rm -rf data nvd-mirror-data db
