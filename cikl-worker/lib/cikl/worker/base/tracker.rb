require 'thread'

module Cikl
  module Worker
    module Base
      class Tracker
        class Entry
          attr_reader :object, :deadline
          def initialize(object, deadline)
            @object = object  
            @deadline = deadline
          end
        end

        # @param [Float] tout The amount of time before the object is pruned 
        #  from our dataset
        def initialize(tout)
          @oids = []
          @oid_entry_map = {}
          @tout = tout
          @mutex = Mutex.new
        end

        # returns the timestamp for when the next prune should occur
        def next_prune
          @mutex.lock
          if entry = first_entry
            return first_entry.deadline
          end
          return nil
        ensure 
          @mutex.unlock
        end

        def first_entry
          while !@oids.empty?
            oid = @oids.first
            entry = @oid_entry_map[oid]
            if entry.nil?
              @oid_entry_map.delete(oid)
              @oids.shift
              next
            end
            return entry
          end
          nil
        end
        private :first_entry

        def first
          @mutex.lock
          if entry = first_entry()
            return entry.object
          end
          nil
        ensure 
          @mutex.unlock
        end

        # returns the number of entries tracked
        def count
          @oid_entry_map.count
        end

        # Prunes objects older than 'cutoff_time'. If a block is given, then
        # each pruned object will be yielded.
        # @param [Time] cutoff_time The time before which object will be considered
        # "old"
        def prune_old(cutoff_time = Time.now)
          @mutex.lock
          ret = []
          loop do
            entry = first_entry()

            if entry.nil?
              # We haven't got anything
              break
            end

            if entry.deadline > cutoff_time
              # We're no longer looking at old objects. Let's stop.
              break
            end

            # Delete the entry
            @oid_entry_map.delete(entry.object.object_id)

            ret << entry.object
          end
          ret
        ensure
          @mutex.unlock
        end

        def has?(object)
          @mutex.lock
          @oid_entry_map.has_key?(object.object_id)
        ensure
          @mutex.unlock
        end

        def delete(object)
          @mutex.lock
          entry = @oid_entry_map.delete(object.object_id)
          return nil if entry.nil?
          return entry.object
        ensure
          @mutex.unlock
        end

        def add(object)
          @mutex.lock
          if @oid_entry_map.has_key?(object.object_id)
            raise ArgumentError.new("Already tracking object")
          end
          entry = Entry.new(object, Time.now + @tout)
          oid = object.object_id
          @oids.push(oid)
          @oid_entry_map[oid] = entry
        ensure
          @mutex.unlock
        end
      end
    end
  end
end
