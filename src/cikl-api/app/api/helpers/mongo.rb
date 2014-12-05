module Cikl
  module API
    module Helpers
      module Mongo
        def get_event_by_id(_id)
          Cikl.mongo_event_collection.find_one(_id: BSON::ObjectId.from_string(_id))
        end

        def mongo_each_event(ids)
          mapping = {}

          ids = ids.map { |x| BSON::ObjectId.from_string(x) }

          Cikl.mongo_event_collection.find(_id: { :"$in" => ids }).each do |obj|
            mapping[obj["_id"]] = obj
          end
          ids.each do |_id|
            yield mapping[_id]
          end
        end
      end
    end
  end
end



