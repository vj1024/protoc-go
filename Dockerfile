FROM golang:1.22 as builder

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get clean

# download protoc
RUN cd /tmp && \
    wget 'https://github.com/protocolbuffers/protobuf/releases/download/v27.3/protoc-27.3-linux-x86_64.zip' -O protoc.zip && \
    unzip protoc.zip

# install protoc go plugin and download grpc-gateway proto to include
RUN export GOPATH=/go
RUN mkdir -p /go/src/github.com/grpc-ecosystem && \
    cd /go/src/github.com/grpc-ecosystem && \
    git clone https://github.com/grpc-ecosystem/grpc-gateway.git -b v2.22.0 --depth=1 && \
    cp -R ./grpc-gateway/protoc-gen-openapiv2 /tmp/include
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.22.0
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.22.0
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.2
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1

# download googleapis proto to include
RUN cd /tmp && \
    git clone https://github.com/googleapis/googleapis.git -b master --depth=1 && \
    cp -R googleapis/* /tmp/include/

# download protoc-gen-validate proto to include
RUN git clone https://github.com/envoyproxy/protoc-gen-validate.git -b v1.1.0 --depth=1 && \
    cp -R protoc-gen-validate/validate /tmp/include && \
    cd protoc-gen-validate && go install .

RUN cd /tmp/include && find . -type f -not -name '*.proto' -exec rm {} \;

FROM bash:5.2

# copy binarys and includes
COPY --from=builder /go/bin/ /usr/local/bin/
COPY --from=builder /tmp/bin/ /usr/local/bin/
COPY --from=builder /tmp/include/ /usr/local/include/

# copy libs required by protoc
COPY --from=builder /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=builder /lib64/ /lib64/

RUN chmod a+x /usr/local/bin/*

WORKDIR /usr/local/bin

CMD ["protoc"]
