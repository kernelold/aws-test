FROM fedora:26 as builder 

RUN dnf -y install golang glibc-static git && \
    dnf -y clean all 

ADD ./main.go /main.go
RUN go get github.com/gorilla/mux
RUN go get github.com/aws/aws-sdk-go/aws
RUN go get github.com/aws/aws-sdk-go/aws/session
RUN go get github.com/guregu/dynamo

RUN cd /  && CGO_ENABLED=0 GOOS=linux go build -o app -a -ldflags '-extldflags "-static"'  . 

FROM alpine:latest

RUN apk add --no-cache --update ca-certificates bash util-linux libc6-compat 

COPY --from=builder /app /app
ADD ./form.html /form.html

ENTRYPOINT ["/app"]
EXPOSE 8000

