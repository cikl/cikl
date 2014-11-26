upstream cikl_api {
  keepalive 10;
  server CIKL_API_HOST:CIKL_API_PORT fail_timeout=0;
}

server {
  listen   80; ## listen for ipv4; this line is default and implied
  root /opt/cikl-ui/public;

  index index.html index.htm;

  location /api {
    proxy_pass http://cikl_api;

    proxy_redirect off;

    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  Host $http_host;
  # Allow for keepalives.
    proxy_http_version 1.1;
    proxy_set_header Connection "";
  }

}

