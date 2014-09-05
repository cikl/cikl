require 'cikl/worker/base/job_builder'
require 'cikl/worker/dns/job'
require 'cikl/worker/logging'
require 'multi_json'
require 'cikl/worker/exceptions'

module Cikl
  module Worker
    module DNS
      # Builds DNS jobs
      class JobBuilder < Cikl::Worker::Base::JobBuilder
        include Cikl::Worker::Logging
        include Cikl::Worker::Exceptions
        # @param [String] payload A string payload that contains data a job
        # @param [Hash] opts Options to pass to the job instance.
        # @return job [Cikl::Worker::DNS::Job] A job
        def build(payload, opts = {})
          begin
            data = MultiJson.decode(payload)
            fqdn = data["fqdn"]
            if fqdn.nil?
              raise JobBuildError.new("Missing fqdn")
            end
            return Cikl::Worker::DNS::Job.new(fqdn, opts)
          rescue JobBuildError => e
            error "Error while building job: #{e}"
            # Just pass through
            raise e
          rescue StandardError => e
            error "Error while building job: #{e}"
            # Capture any other exceptions and wrap them as JobBuildError's
            raise JobBuildError.new(e)
          end
        end
      end
    end
  end
end
