FROM alpine:3.7

# Add community repos.
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
	echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
	echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
	echo "http://dl-5.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Install packages.
RUN apk add --no-cache \
	tini \
	unison

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ \
	"unison", "/host", "/volume", \
	"-auto", \
	"-batch", \
	"-repeat", "watch", \
	"-copyonconflict", \
	"-prefer", "newer" \
]
