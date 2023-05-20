start:
	docker run -it --rm -v $(pwd):/app -p 8080:8080 node:16 /bin/bash

.PHONY: start
