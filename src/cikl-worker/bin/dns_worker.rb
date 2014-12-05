#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __FILE__)

require 'cikl/worker/dns/config'
require 'cikl/worker/dns/job_builder'
require 'cikl/worker/dns/processor'
require 'cikl/worker/dns/resolver'
require 'cikl/worker/base/consumer'
require 'cikl/worker/amqp'

lambda do
  config = Cikl::Worker::DNS::Config.create_config(WorkerEnvironment::APP_ROOT)
  config.use :config_file
  config_file = ARGV.shift
  if config_file
    config_file = File.expand_path(config_file)
    if !File.readable?(config_file)
      raise "Cannot read '#{config_file}'. Perhaps you need to provide an absolute path?"
    end
    config.read(config_file)
  end
  config.resolve!

  amqp = Cikl::Worker::AMQP.new(config)
  amqp.start
  job_builder = Cikl::Worker::DNS::JobBuilder.new
  resolver = Cikl::Worker::DNS::Resolver.new(config)
  processor = Cikl::Worker::DNS::Processor.new(resolver, amqp.job_result_handler, config)
  consumer = Cikl::Worker::Base::Consumer.new(processor, job_builder, config)
  amqp.register_consumer(consumer)
  running = true
  trap(:INT) do
    running = false
  end

  while running == true
    sleep 0.1
  end

  amqp.stop
end.call
