FROM ubuntu:14.04

# Include patches and end-to-end script in image
WORKDIR /openssl-sandbox

# Install some essential tools
RUN apt-get update
RUN apt-get -y install \
    software-properties-common \
    make \
    gcc \
    curl \
    gdb \
    git

# Add nodejs + jks-key-extractor
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - ;\
    apt-get -y install nodejs; \
    npm install -g jks-key-extractor

# Clone openssl-dstu and apply patches
RUN git clone https://github.com/dstucrypt/openssl-dstu.git; \
    cd openssl-dstu; \
    git checkout OpenSSL_1_0_2-dstu

# Build openssl-dstu
RUN cd openssl-dstu; \
    ./Configure --prefix=/usr \
                --openssldir=/usr/lib/ssl \
                --libdir=lib/x86_64-linux-gnu \
                no-idea \
                no-mdc2 \
                no-rc5 \
                no-zlib \
                enable-uadstu \
                enable-ec_nistp_64_gcc_128 \
                enable-ec_nistp_64_gcc_128 \
                debug-linux-x86_64; \
    make depend && \
    make
