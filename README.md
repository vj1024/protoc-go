# protoc-go
protoc with almost all golang plugins and includes.

## Dockerfile
[github.com/vj1024/protoc-go](https://github.com/vj1024/protoc-go/blob/main/Dockerfile)

## Contents

### /usr/local/bin
- **protoc** (3.17.0)
- **protoc-gen-go** (v1.26.0)
- **protoc-gen-go-grpc** (v1.1.0)
- **protoc-gen-grpc-gateway** (v2.4.0)
- **protoc-gen-openapiv2** (v2.4.0)

### /usr/local/include
- github.com/googleapis/**googleapis** (latest 2021-05-21)
- github.com/grpc-ecosystem/**grpc-gateway** (v2.4.0)
- github.com/envoyproxy/**protoc-gen-validate** (v0.6.1)


## Usage

example of generate **go**, **grpc-gateway**, **openapiv2(swagger)** :

```
docker run -w /proto -v /your_proto_path:/proto -it --rm vj1024/protoc-go:latest protoc -I . \
    --go_out=. \
    --go_opt=paths=source_relative \
    --go-grpc_out=. \
    --go-grpc_opt=paths=source_relative \
    --grpc-gateway_out . \
    --grpc-gateway_opt logtostderr=true \
    --grpc-gateway_opt paths=source_relative \
    --openapiv2_out . \
    --openapiv2_opt logtostderr=true \
    your_service.proto
```
