prepare_data:
	mkdir -p data
	./scripts/prepare_data.rb .. data
	R -e "setwd('./scripts'); rmarkdown::render('stats.Rmd')"
	mkdir -p ../public
	cp scripts/stats.html ../public/index.html	
	tar -czvf data/data.tar.gz data/data.csv
	tar -czvf data/nvd.tar.gz data/nvd.csv
	cp -a data ..

clean:
	rm -rf data
