# frozen_string_literal: true

module DatabaseRecorder
  module ActiveRecord
    module Recorder
      module_function

      def setup
        ::ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
          prepend AbstractAdapterExt
        end

        # ::ActiveRecord::Base.class_eval do
        #   prepend BaseExt
        # end
      end
    end
  end
end
