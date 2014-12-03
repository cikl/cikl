require 'sidekiq'

module Cikl
  module Workers
    class TestWorker
      include Sidekiq::Worker

      def perform(*args)
        puts "TestWorker#perform starting! #{args.map(&:inspect).join(', ')}"
        sleep 5
        puts "TestWorker#perform all done! #{args.map(&:inspect).join(', ')}"
      end
    end
  end
end
