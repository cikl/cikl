if [ "$API_PORT_9292_TCP_ADDR" = "" ]; then
  echo "ERROR: No value for "API_PORT_9292_TCP_ADDR". Expected to be linked to a cikl/api container as 'api'."
  exit 1
fi

if [ "$API_PORT_9292_TCP_PORT" = "" ]; then
  echo "ERROR: No value for "API_PORT_9292_TCP_PORT". Expected to be linked to a cikl/api container as 'api'."
  exit 1
fi

m4 -DCIKL_API_PORT="$API_PORT_9292_TCP_PORT" \
   -DCIKL_API_HOST="$API_PORT_9292_TCP_ADDR" \
   /etc/nginx/cikl-ui.conf.m4 > \
   /etc/nginx/sites-enabled/cikl-ui.conf
