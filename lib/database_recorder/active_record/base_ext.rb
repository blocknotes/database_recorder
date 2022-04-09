# frozen_string_literal: true

module DatabaseRecorder
  module ActiveRecord
    module BaseExt
      def create_or_update(**, &block)
        return super if !new_record? || !Recording.started?

        cached = Config.replay_recordings && Recording.from_cache ? Recording.pull_entity : false
        if cached
          # self.id = cached['id']
          super
        else
          super.tap do |_result|
            Recording.new_entity(model: self.class.to_s, id: id)
          end
        end
      end
    end
  end
end
