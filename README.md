[![Build Status](https://travis-ci.org/cikl/cikl.svg)](https://travis-ci.org/cikl/cikl)

# Cikl
Cikl is a cyber threat intelligence management system. It began as a fork of the [Collective Intelligence Framework (CIF)](https://code.google.com/p/collective-intelligence-framework/), which aims for the same goal. Cikl aims to provide a threat intelligence management system that scales well and is easy to deploy. 

## Documentation
Currently? We haven't got much in the way of documentation. Please accept my appologies.

## Development Environment

### Prerequisites 
Development for Cikl is done within a set of Docker containers managed by Fig.

- Software Requirements
  - [Docker](https://www.docker.com/) 
    - Provides the container framework 
    - Tested/recommended with docker >= 1.3.0
    - The particulars of installing and running Docker will vary by platform. 
      For Windows and Mac OS X, see [boot2docker](http://boot2docker.io/). 
      Linux packages are available for a large number of distributions.
  - [Fig](http://www.fig.sh/)
    - Manages our Docker containers.
    - Tested with fig 1.0.0
    - Install with: ```sudo pip install -U fig```

### Get the code
```
git clone https://github.com/cikl/cikl.git
cd cikl
```

### Starting all services in the background:
```make dev-up```

- This will build all the require docker images, and then bring the dev 
  environment up.
- That's it! You should now be able to access the environment.

### Viewing logs
To tail the logs for all services started by fig:
```fig logs```

Hit ctrl-c to stop tailing the logs.

If you want to tail the logs of a single service (example: 'api'):
```fig logs api```

### Listing the status of services:
This command will list the names of the Docker containers that are running the
services, as well as their statuses:
```fig ps```

### Stopping services
The following will stop all services:
```make dev-stop```

or

```fig stop```

To stop a specific service (example: 'dnsworker'):
```fig stop dnsworker```

### Opening a root shell on a container that's running a service:
First, get the name of the docker container:
```fig ps```

Execute a shell:
```docker exec -ti cikl_api_1 /bin/bash```


### Accessing the development environment
- [Cikl UI](http://localhost:8080/)
- [API Documentation](http://localhost:8080/api/doc/)

Currently broken:
- [Elasticsearch Head](http://localhost:9292/_plugin/head/)


### Importing data

Now that you've got everything up and running, maybe you want to process a 
feed or two? 

Cikl uses [Threatinator](https://github.com/cikl/threatinator) for all of its
threat data feed fetching and parsing needs. You can find details on 
Threatinators usage on its project page.

#### Listing all feeds

```
fig run scheduler threatinator-list
```

#### Running a specific feed

If you want to import the 'mirc' 'domain_reputation' feed:
```
fig run dnsworker threatinator-run mirc domain_reputation
```

#### Running all feeds
If you're especially brave, you can import all feeds with one easy command:

```
fig run dnsworker threatinator-run-all
```

### Updating 
This is an actively developed project, so you'll want to keep things up to
date. 

```
# Stop all services and clean builds
make dev-stop
# Switch to your master branch
git checkout master
# Pull any updatream changes into your master branch
git pull origin master
# Bring services back up:
make dev-up
```

### Clearing out existing data after an upgrade
This is accomplished by stopping and removing all existing services (and data):
```
make clean
```

### Running unit and integration tests
To run all the unit tests for Cikl:

```
make test
```

You'll see all the test executions scroll past. If all goes well, it will exit
without error and generate a coverage report in the coverage/ directory.


## Roadmap
You can find our roadmap [here](https://github.com/cikl/cikl/wiki/Roadmap).


## Contributing and Issue Tracking

Before you file a bug or submit a pull request, please review our 
[contribution guidelines](https://github.com/cikl/cikl/wiki/Contributing).

All issues are managed within the primary repository: [cikl/cikl/issues](https://github.com/cikl/cikl/issues). Pull requests should be sent to their respective reposirotires, referencing some issue within the main project repository.

We use Huboard for managing our issues (to the extent that it can). [Our HuBoard!](https://huboard.com/cikl/cikl#/).

## License

Copyright (c) 2014 Michael Ryan. See the LICENSE file for license rights and limitations (LGPLv3).
