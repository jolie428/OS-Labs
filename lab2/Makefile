DIR = test_dir
MAL = malicious_dir
Interval = 5 

.PHONY: run restore setup

run: setup
	./antivirusd.sh ${DIR} ${MAL} ${Interval}

restore: setup
	./restore.sh ${DIR} ${MAL}

setup:
	mkdir -p ${DIR}