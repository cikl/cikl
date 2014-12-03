include Makefile.common

all: build

build: core scheduler

core:
	cd docker/core; $(MAKE) build $(MFLAGS)

core-clean:
	cd docker/core; $(MAKE) clean $(MFLAGS)

scheduler:
	cd docker/scheduler; $(MAKE) build $(MFLAGS)

scheduler-clean:
	cd docker/scheduler; $(MAKE) clean $(MFLAGS)

dev-up: core scheduler
	fig up -d

dev-stop:
	fig stop

dev-logs:
	fig logs

dev-clean: dev-stop
	fig rm --force

test: core
	fig -f fig-test.yml up

test-stop: 
	fig -f fig-test.yml stop

test-clean: test-stop
	fig -f fig-test.yml rm --force
	rm -fr coverage/

clean: dev-clean test-clean core-clean scheduler-clean
