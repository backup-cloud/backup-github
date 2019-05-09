FROM alpine:latest

WORKDIR /usr/local/backup/

RUN apk add --no-cache bash gawk sed grep bc coreutils curl git openssh openssl

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN apk add --no-cache py3-gpgme

RUN pip3 install --upgrade awscli==1.16.67 s3cmd==2.0.2 python-magic python-gnupg 

RUN pip3 install git+https://github.com/michael-paddle/backup-base.git@tested

ADD backup-github.sh /usr/local/backup/
ADD backup-github.config /usr/local/backup/
ADD call_base_backup.py /usr/local/backup/
ADD config /root/.ssh/
ADD id_rsa /root/.ssh/

RUN chmod 400 /root/.ssh/id_rsa
RUN chmod a+x /usr/local/backup/backup-github.sh

CMD ["/bin/bash", "/usr/local/backup/backup-github.sh"]