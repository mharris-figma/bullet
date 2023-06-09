# frozen_string_literal: true

require 'set'

module Bullet
  class NotificationCollector
    attr_reader :collection_to_count
    attr_reader :collection_to_first_ts
    attr_reader :collection_to_last_ts

    def initialize
      reset
    end

    def reset
      @collection_set = Set.new
      @collection_to_count = {}
      @collection_to_first_ts = {}
      @collection_to_last_ts = {}
    end

    def add(value)
      if @collection_set.include?(value)
        @collection_to_count[value] += 1
        @collection_to_last_ts[value] = Time.now.to_f
      else
        @collection_set << value
        @collection_to_count[value] = 1
        timestamp = Time.now.to_f
        @collection_to_first_ts[value] = timestamp
        @collection_to_last_ts[value] = timestamp
      end
    end

    def collection(min_queries: 0, min_duration: 0)
      return @collection_set.filter do |value|
        time_delta = @collection_to_last_ts[value] - @collection_to_first_ts[value]
        
        @collection_to_count[value] >= min_queries && time_delta >= min_duration
      end
    end

    def notifications_present?(min_queries: 0, min_duration: 0)
      !collection(min_queries: min_queries, min_duration: min_duration).empty?
    end
  end
end
