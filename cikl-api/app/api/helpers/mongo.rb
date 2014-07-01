module Cikl
  module API
    module Helpers
      module Mongo
        def get_event_by_id(_id)
          mongo_event_collection.find_one(_id: BSON::ObjectId.from_string(_id))
        end

        def mongo_each_event(ids)
          mapping = {}

          ids = ids.map { |x| BSON::ObjectId.from_string(x) }

          mongo_event_collection.find(_id: { :"$in" => ids }).each do |obj|
            mapping[obj["_id"]] = obj
          end
          ids.each do |_id|
            yield mapping[_id]
          end
        end

        def mongo_event_collection
          return env['mongo_event']
        end

        def with_mongo_event_collection
          yield(env['mongo_event'])
        end
      end
    end
  end
end



