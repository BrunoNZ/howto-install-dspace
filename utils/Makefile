.DEFAULT_GOAL = build
.PHONY: build install update deploy clean

DSPACE_WEBAPPS_FOLDER = [DIR_INSTALACAO]/webapps
TOMCAT_WEBAPPS_FOLDER = /var/lib/tomcat7/webapps

MIRAGE2_FLAG = true

build:
	mvn clean package \
		-Dmirage2.on=$(MIRAGE2_FLAG) \
		-P '!dspace-sword, !dspace-swordv2, !dspace-jspui' \

install:
	cd dspace/target/dspace-installer; \
	ant fresh_install

update:
	cd dspace/target/dspace-installer; \
	ant update

deploy:
	rsync --checksum --delete-delay --recursive $(DSPACE_WEBAPPS_FOLDER)/* $(TOMCAT_WEBAPPS_FOLDER)/

clean:
	mvn clean

