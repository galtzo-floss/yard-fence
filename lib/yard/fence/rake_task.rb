# frozen_string_literal: true

require "rake"
require "rake/tasklib"

module Yard
  module Fence
    # Rake task to prepare for YARD documentation generation.
    # This handles both cleaning the docs directory (if YARD_FENCE_CLEAN_DOCS=true)
    # and preparing the tmp/yard-fence files with sanitized markdown.
    #
    # This is separated from the gem's load-time to ensure these operations only
    # happen when explicitly running documentation tasks, not during other
    # rake tasks like `build` or `release`.
    #
    # @example Usage in Rakefile
    #   require "yard/fence/rake_task"
    #   Yard::Fence::RakeTask.new
    #
    #   # This creates a `yard:fence:prepare` task that is automatically added
    #   # as a prerequisite to the yard task.
    #
    class RakeTask < ::Rake::TaskLib
      # @return [String] the name of the prepare task (default: "yard:fence:prepare")
      attr_accessor :name

      # Initialize the rake task.
      #
      # @param name [String, Symbol] the task name (default: "yard:fence:prepare")
      # @yield [task] optional block to configure the task
      def initialize(name = "yard:fence:prepare")
        super()
        @name = name.to_s

        yield self if block_given?

        define_tasks
      end

      private

      def define_tasks
        namespace(:yard) do
          namespace(:fence) do
            desc("Prepare for YARD documentation (clean docs/, prepare tmp/yard-fence/)")
            task(:prepare) do
              require "yard/fence"
              Yard::Fence.prepare_for_yard
            end

            # Keep a separate clean task for those who want to clean without preparing
            desc("Clean docs/ directory only (yard-fence)")
            task(:clean) do
              require "yard/fence"
              Yard::Fence.clean_docs_directory
            end
          end
        end

        # Auto-enhance the yard task if it exists
        if ::Rake::Task.task_defined?(:yard)
          ::Rake::Task[:yard].enhance(["yard:fence:prepare"])
        end
      end
    end
  end
end
