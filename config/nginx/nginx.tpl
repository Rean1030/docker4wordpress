# let's assume dual-core machine
worker_processes ${WORKER_PROCESSES};
 
pid /var/run/nginx.pid;

events {
  # this should be equal to value of "ulimit -n"
  # reference: https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  worker_connections ${WORKER_CONNECTIONS};
}

error_log /var/log/nginx/error.log;

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  log_format main
    '${DOLLAR}remote_addr - ${DOLLAR}remote_user [${DOLLAR}time_local] "${DOLLAR}request" '
    '${DOLLAR}status ${DOLLAR}body_bytes_sent "${DOLLAR}http_referer" '
    '"${DOLLAR}http_user_agent" "${DOLLAR}http_x_forwarded_for"';

  access_log /var/log/nginx/access.log;

  sendfile on;
  #tcp_nopush on;

  keepalive_timeout 65;

  #gzip on;

  client_max_body_size 128M;

  include /etc/nginx/conf.d/*.conf;
}
