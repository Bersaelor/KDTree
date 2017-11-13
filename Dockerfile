FROM ibmcom/swift-ubuntu:4.0

MAINTAINER konrad@tactica.de

#swift talk example code
WORKDIR /app

COPY Package.swift ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift package resolve
RUN swift build

ENV PATH ${PATH}:/app/.build/debug

RUN swift test;
CMD while true; do sleep 3600; done
