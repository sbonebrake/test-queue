module RSpec::Core
  class World
    alias_method :rspec_register, :register

    # @api private
    #
    # Register an example group.
    def register(example_group)
      @caps ||= ::SauceRSpec.config.caps

      examples     = example_group.examples
      new_examples = []
      examples.each do |ex|
        @caps.each do |cap|
          ex_with_cap = ex.clone
          ex_with_cap.instance_variable_set(:@id, ex_with_cap.id + cap.to_s)
          ex_with_cap.instance_eval "def caps; #{cap}; end"
          new_examples << ex_with_cap
        end
      end

      example_group.instance_variable_set(:@examples, new_examples)

      # invoke original register method
      rspec_register(example_group)
    end
  end if defined?(::SauceRSpec)

  # RSpec 3.2 introduced:
  unless Configuration.method_defined?(:with_suite_hooks)
    class Configuration
      def with_suite_hooks
        begin
          hook_context = SuiteHookContext.new
          hooks.run(:before, :suite, hook_context)
          yield
        ensure
          hooks.run(:after, :suite, hook_context)
        end
      end
    end
  end

  class QueueRunner < Runner
    def initialize
      options = ConfigurationOptions.new(ARGV)
      super(options)
    end

    def example_groups
      setup($stderr, $stdout)
      @world.ordered_example_groups
    end

    def run_specs(iterator)
      @configuration.reporter.report(@world.ordered_example_groups.count) do |reporter|
        @configuration.with_suite_hooks do
          iterator.map { |g|
            start = Time.now
            if g.is_a? ::RSpec::Core::Example
              print "    #{g.full_description}: "
              example = g
              g = example.example_group
              ::RSpec.world.filtered_examples.clear
              ::RSpec.world.filtered_examples[g] = [example]
            else
              print "    #{g.description}: "
            end
            ret = g.run(reporter)
            diff = Time.now-start
            puts("  <%.3f>" % diff)

            ret
          }.all? ? 0 : @configuration.failure_exit_code
        end
      end
    end
    alias_method :run_each, :run_specs
  end
end
