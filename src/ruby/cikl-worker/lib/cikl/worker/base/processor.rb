require 'cikl/worker/logging'
require 'cikl/worker/base/tracker'
require 'thread'

module Cikl
  module Worker
    module Base
      class Processor 
        include Cikl::Worker::Logging

        def initialize(job_result_handler, config)
          @job_result_handler = job_result_handler
          @timeout = config[:job_timeout]
          @tracker = Cikl::Worker::Base::Tracker.new(@timeout)
          @running = true
          @pruning_thread = Thread.new do
            run_pruner()
          end
        end

        # returns the number of jobs currently processing
        def num_jobs_processing
          @tracker.count
        end

        def job_finished(job, result)
          if @tracker.delete(job) && result
            @job_result_handler.handle_job_result(result)
          end
        end

        def run_pruner
          while @running == true
            next_prune = @tracker.next_prune
            sleep_time = nil
            now = Time.now
            if next_prune.nil?
              sleep_time = @timeout
            elsif next_prune > now
              sleep_time = next_prune - now
            end

            if sleep_time
              debug "Sleeping #{sleep_time} seconds"
              sleep sleep_time
              next
            end

            old_jobs = @tracker.prune_old
            debug "Pruning #{old_jobs.count} old jobs"

            old_jobs.each do |job|
              handle_pruned_job(job)
            end
          end
        end
        private :run_pruner

        def handle_pruned_job(job)
        end

        def stop
          debug "-> Processor#stop"

          @running = false
          debug "Pruner: stopping"
          @pruning_thread.wakeup rescue ThreadError # in case it's already stopped
          if @pruning_thread.join(2).nil?
            # :nocov:
            warn "Killing pruning thread"
            @pruning_thread.kill
            # :nocov:
          end
          debug "<- Processor#stop"
        end

        def process_job(job)
          @tracker.add(job)
          if @tracker.count == 1
            # This helps ensure that the 
            @pruning_thread.wakeup
          end
        end
      end

    end
  end
end



