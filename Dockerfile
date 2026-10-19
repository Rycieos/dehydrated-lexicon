FROM python:3.15-alpine

# Setup dependencies
# Install dehydrated (letsencrypt client) & dns-lexicon
RUN apk add --no-cache bash bind-tools curl git openssl \
 && git clone --depth 1 https://github.com/lukas2511/dehydrated.git /srv/dehydrated \
 && pip install --no-cache-dir dns-lexicon \
 && apk del git

COPY dehydrated.hook.sh /srv/dehydrated/

ENTRYPOINT ["srv/dehydrated/dehydrated"]
CMD ["--cron", "--accept-terms", "--hook", "/srv/dehydrated/dehydrated.hook.sh", "--challenge", "dns-01"]
