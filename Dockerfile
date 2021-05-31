FROM golang:1.16 as builder

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get clean

# download protoc
RUN cd /tmp && \
    wget 'https://github.com/protocolbuffers/protobuf/releases/download/v3.17.0/protoc-3.17.0-linux-x86_64.zip' -O protoc.zip && \
    unzip protoc.zip

# install protoc go plugin and download grpc-gateway proto to include
RUN export GOPATH=/go && \
    mkdir -p /go/src/github.com/grpc-ecosystem && \
    cd /go/src/github.com/grpc-ecosystem && \
    git clone https://github.com/grpc-ecosystem/grpc-gateway.git -b v2.4.0 && \
    cd grpc-gateway && \
    find ./protoc-gen-openapiv2 -name '*.proto'|xargs tar -czvf /tmp/grpc-gateway.tgz && \
    cd /tmp/include && \
    tar -xzvf /tmp/grpc-gateway.tgz && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.4.0 && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.4.0 && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26.0 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0

# download googleapis proto to include
RUN cd /tmp && \
    git clone https://github.com/googleapis/googleapis.git && \
    cd googleapis && \
    find . -name '*.proto'|xargs tar -czvf /tmp/googleapis.tgz && \
    cd /tmp/include && \
    tar -xzvf /tmp/googleapis.tgz

# download protoc-gen-validate proto to include
RUN git clone https://github.com/envoyproxy/protoc-gen-validate.git -b v0.6.1 && \
    cd protoc-gen-validate && \
    find ./validate -name '*.proto'|xargs tar -czvf /tmp/protoc-gen-validate.tgz && \
    cd /tmp/include && \
    tar -xzvf /tmp/protoc-gen-validate.tgz


FROM bash:5.1

# copy binarys and includes
COPY --from=builder /go/bin/ /tmp/bin/ /usr/local/bin/
COPY --from=builder /tmp/include/ /usr/local/include/

# copy libs required by protoc
COPY --from=builder /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=builder /lib64/ /lib64/

RUN chmod a+x /usr/local/bin/*

WORKDIR /usr/local/bin

CMD ["protoc"]
