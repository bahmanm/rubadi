# Rubadi #
Rubadi is a simple Ad server in Ruby.

# Status #
Currently Rubadi has reached [v1.0 milestone](https://github.com/bahmanm/rubadi/issues?milestone=1&state=closed).

# Performance #
Using Apache `ab`

* **Version in test**: v1.0
* **Test environment (VPS)**:
- _2 core Pentium 4 CPU_
- _512MB RAM_
- _Ruby 2.1.2_
- _PostgreSQL 9.2.8_
- _nginx 1.4.4 (serving images)_
* **Requests per minute**: 15,000
* **Concurrent requests**: 100
* **Total time**: ~47 seconds for 15,000 requests
* **Requests serviced per second**: ~300

You can view the [full results](performance-test-results.txt).

# Deployment Strategy #
Run one Rubadi instance per each core of the server machine. Use nginx to load
balance the incoming request(s) and serve images for Sinatra.

A sample nginx configuration is as follows. It assumes the server has 2 cores 
and consequently two Rubadi instances are listening on ports 4600 and 4601.


```
upstream rubadi {
        server  127.0.0.1:4600;
        server  127.0.0.1:4601;
}

server {
    listen       80;
    server_name  xyz.example.com rubadi;

    location /images {
        root /srv/www/static/rubadi;
    }

    location / {
        proxy_pass              http://rubadi;
        proxy_set_header        Host            $host;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

# Softwares Used #
Rubadi as a web application is written with [Sinatra](http://sinatrarb.com/) and
uses [eRubis](http://www.kuwata-lab.com/erubis/) to render the view(s). It is 
backed by the almighty [PostgreSQL](http://postgresql.org) and relies heavily 
on [connection pooling](https://github.com/mperham/connection_pool) to achieve
high throughput.

Here's a list of main gems (excluding deps):

* erubis 2.7.0
* sinatra 1.4.5
* sinatra-contrib 1.4.2
* connection_pool 2.0.0
* pg 0.17.1 
