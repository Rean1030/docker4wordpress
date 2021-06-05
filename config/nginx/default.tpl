
upstream fastcgi_backend {
  least_conn;
  # server unix:/var/run/docker.sock;
  server ${WORDPRESS_HOST}:${WORDPRESS_PORT};
}

server {
  listen 80;
  server_name ${SERVER_NAME}; 
  return 301 https://${DOLLAR}host${DOLLAR}request_uri;
}

server {
  listen [::]:443 ssl http2 ipv6only=on;
  listen 443 ssl http2;

  server_name ${SERVER_NAME}; 

  ssl_certificate /etc/nginx/certs/nginx.crt;
  ssl_certificate_key /etc/nginx/certs/nginx.key;

  ssl_session_cache         shared:SSL:20m;
  ssl_session_timeout       10m;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;   
  ssl_prefer_server_ciphers on;

  fastcgi_buffer_size 64k;
  fastcgi_buffers 8 128k;

  include /var/www/html/nginx[.]conf;
  
  root /var/www/html;
  index index.php;
  #add_header "X-UA-Compatible" "IE=Edge";

  gzip on;
  gzip_disable "msie6";

  gzip_comp_level 6;
  gzip_min_length 1100;
  gzip_buffers 16 8k;
  gzip_proxied any;
  gzip_types
      text/plain
      text/css
      text/js
      text/xml
      text/javascript
      application/javascript
      application/x-javascript
      application/json
      application/xml
      application/xml+rss
      image/svg+xml;
  gzip_vary on;
  
  location ~ /.well-known/acme-challenge {
      allow all;
      root /var/www/html;
  }

  location / {
      try_files ${DOLLAR}uri ${DOLLAR}uri/ /index.php${DOLLAR}is_args${DOLLAR}args;
  }

  location ~ \.php${DOLLAR} {
      try_files ${DOLLAR}uri =404;
      fastcgi_split_path_info ^(.+\.php)(/.+)${DOLLAR};
      fastcgi_pass fastcgi_backend;
      fastcgi_index index.php;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME ${DOLLAR}document_root${DOLLAR}fastcgi_script_name;
      fastcgi_param PATH_INFO ${DOLLAR}fastcgi_path_info;
  }

  location ~ /\.ht {
          deny all;
  }

  location = /favicon.ico {
          log_not_found off; access_log off;
  }
  location = /robots.txt {
          log_not_found off; access_log off; allow all;
  }
  location ~* \.(css|gif|ico|jpeg|jpg|js|png)${DOLLAR} {
          expires max;
          log_not_found off;
  }
}
