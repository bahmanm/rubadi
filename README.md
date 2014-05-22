# Rubadi #
Rubadi is a simple Ad server in Ruby.

# Status #
Currently Rubadi is maturing to reach [v1.0 milestone](https://github.com/bahmanm/rubadi/issues?milestone=1&state=open).

# Softwares Used
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
