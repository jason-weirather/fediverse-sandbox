FROM vacation/ktistec:2.0.0-11

# Install the ca-certificates package
RUN apk --no-cache add ca-certificates

COPY ./certs/myCA.pem /usr/local/share/ca-certificates/myCA.crt
RUN update-ca-certificates

ENV KTISTEC_DB=/db/ktistec.db
CMD ["/bin/server"]
VOLUME /db /uploads
EXPOSE 3000
