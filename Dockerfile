FROM virtmerlin/c0-worker-gcp

RUN wget https://github.com/pivotal-cf/om/releases/download/0.17.0/om-linux -O /usr/local/bin/om && chmod +x /usr/local/bin/om

COPY check /opt/resource/check
COPY in /opt/resource/in
COPY out /opt/resource/out
