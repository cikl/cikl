#!/bin/bash
 
/usr/share/elasticsearch/bin/elasticsearch -D es.foreground=yes \
                -D es.cluster.name=test_cikl_cluster \
                -D es.node.name=node-0 \
                -D es.http.port=9250 \
                -D es.gateway.type=none \
                -D es.index.store.type=memory \
                -D es.path.data=/tmp \
                -D es.path.work=/tmp \
                -D es.network.host=localhost \
                -D es.discovery.zen.ping.multicast.enabled=true \
                -D es.script.disable_dynamic=false \
                -D es.node.test=true \
                -D es.node.bench=true
