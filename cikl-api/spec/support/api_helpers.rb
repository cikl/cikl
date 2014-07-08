
module APIHelpers
  def an_event_with_observable(type, matchers)
    a_hash_including(
      "observables" => {
        type => a_collection_containing_exactly(
          a_hash_including(
            matchers
          )
        )
      }
    )
  end
end
