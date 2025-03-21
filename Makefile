DIR = ${CURDIR}
start:
	docker run -it --rm -v $(DIR):/app -p 8080:8080 node:16 /bin/bash

.PHONY: start
