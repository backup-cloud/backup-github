FROM alpine:latest

WORKDIR /usr/local/backup/

RUN apk add --no-cache bash gawk sed grep bc coreutils curl git openssh python py-pip openssl

RUN pip install --upgrade awscli==1.16.67 s3cmd==2.0.2 python-magic

ADD backup-github.sh /usr/local/backup/
ADD backup-github.config /usr/local/backup/
ADD config /root/.ssh/
ADD id_rsa /root/.ssh/

RUN chmod 400 /root/.ssh/id_rsa
RUN chmod a+x /usr/local/backup/backup-github.sh

CMD ["/bin/bash", "/usr/local/backup/backup-github.sh"]