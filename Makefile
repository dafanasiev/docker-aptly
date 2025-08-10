#!/usr/bin/env make
VER_APTLY=1.6.2

.PHONY:oci-image
oci-image:
	docker buildx build --pull --progress=plain \
	--build-arg VER_APTLY=${VER_APTLY} \
	-t urpylka/aptly:${VER_APTLY} \
	-t urpylka/aptly:latest \
	.
