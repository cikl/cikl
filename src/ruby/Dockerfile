FROM cikl/base:0.0.2
MAINTAINER Mike Ryan <falter@gmail.com>

RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6 && \
  echo deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main > /etc/apt/sources.list.d/brightbox.list && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y ruby2.1 libunbound2 libcurl3 libxml2 libxslt1.1 && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure that theonly thing that triggers a rebuild is modifications to the 
# Gemfile, and not anything else inside the src dir.
ADD Gemfile /opt/cikl/ruby/Gemfile
ADD VERSION /opt/cikl/ruby/VERSION
ADD cikl.gemspec /opt/cikl/ruby/cikl.gemspec
ADD cikl-api/cikl-api.gemspec /opt/cikl/ruby/cikl-api/cikl-api.gemspec
ADD cikl-worker/cikl-worker.gemspec /opt/cikl/ruby/cikl-worker/cikl-worker.gemspec
ADD cikl-event/cikl-event.gemspec /opt/cikl/ruby/cikl-event/cikl-event.gemspec
ADD threatinator-output-cikl/threatinator-output-cikl.gemspec /opt/cikl/ruby/threatinator-output-cikl/threatinator-output-cikl.gemspec

WORKDIR /opt/cikl/ruby
RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  buildDeps="gcc g++ make libc6-dev ruby2.1-dev zlib1g-dev libssl-dev patch libxml2-dev libxslt1-dev" && \
  apt-get update && \
  apt-get install -y --no-install-recommends $buildDeps && \
  gem install bundler && \
  bundle config build.nokogiri --use-system-libraries --with-xml2-include=/usr/include/libxml2/ && \
  bundle install --jobs=7 && \
  rm /var/lib/gems/2.1.0/cache/*.gem && \
  apt-get remove -y --purge --auto-remove $buildDeps && \
  apt-get autoremove -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

ADD . /opt/cikl/ruby
ADD docker/threatinator-command.sh /etc/docker-entrypoint/commands.d/threatinator
ADD docker/dns-worker-command.sh /etc/docker-entrypoint/commands.d/dns-worker
ADD docker/api-command.sh /etc/docker-entrypoint/commands.d/api
ADD docker/test-unit-command.sh /etc/docker-entrypoint/commands.d/test-unit
ADD docker/core-pre.sh /etc/docker-entrypoint/pre.d/core.sh

RUN chmod a+x /etc/docker-entrypoint/commands.d/threatinator \
              /etc/docker-entrypoint/commands.d/dns-worker \
              /etc/docker-entrypoint/commands.d/api \
              /etc/docker-entrypoint/commands.d/test-unit

VOLUME [ "/data" ]
RUN useradd -s /bin/false -d /data -m cikl
ENV ENTRYPOINT_DROP_PRIVS 1
ENV ENTRYPOINT_USER cikl

ENV RUBYOPT -I/opt/cikl/ruby/cikl-event/lib

ENV CIKL_MONGO_URI mongodb://mongodb/cikl
ENV CIKL_ELASTICSEARCH_URI http://elasticsearch:9200/
ENV CIKL_ELASTICSEARCH_INDEX cikl
ENV CIKL_RABBITMQ_URL amqp://cikl:cikl@rabbitmq/%2Fcikl

CMD [ "help" ]

# Expose cikl-api service
EXPOSE 9292
