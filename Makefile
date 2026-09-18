PORT ?= 8887
DOCS_DIR := $(shell pwd)
SITE_DIR := $(DOCS_DIR)/www

.PHONY: install build build-35 serve serve-35 clean

install:
	cd $(DOCS_DIR) && npm install

# 3.4 build (default, rhoai_version=3.4 from antora.yml)
build-34: install
	rm -rf $(DOCS_DIR)/www-34
	cd $(DOCS_DIR) && npx antora site-34.yml --stacktrace
	touch $(DOCS_DIR)/www-34/.nojekyll

# 3.5 build (site-35.yml overrides rhoai_version=3.5, maas_api_namespace, dsc_maas_condition)
build-35: install
	rm -rf $(SITE_DIR)
	cd $(DOCS_DIR) && npx antora site-35.yml --stacktrace
	touch $(SITE_DIR)/.nojekyll

serve-34: build-34
	@echo "Serving 3.4 at http://localhost:$(PORT)"
	python3 -m http.server $(PORT) --directory $(DOCS_DIR)/www-34

# default serve target is currently 3.5
serve: build-35
	@echo "Serving 3.5 at http://localhost:$(PORT)"
	python3 -m http.server $(PORT) --directory $(SITE_DIR)

serve-35: serve

clean:
	rm -rf $(SITE_DIR) $(DOCS_DIR)/www-34
	rm -rf $(SITE_DIR) $(DOCS_DIR)/www
