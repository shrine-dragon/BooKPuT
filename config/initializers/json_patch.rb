# config/initializers/json_patch.rb
if RUBY_VERSION >= '3.2.0'
  module JSON
    class << self
      alias_method :orig_parse, :parse
      def parse(source, *args)
        if args[0].is_a?(Hash)
          args[0].delete(:quirks_mode)
          args[0].delete('quirks_mode')
        end
        orig_parse(source, *args)
      end

      alias_method :orig_generate, :generate
      def generate(obj, *args)
        if args[0].is_a?(Hash)
          args[0].delete(:quirks_mode)
          args[0].delete('quirks_mode')
        end
        orig_generate(obj, *args)
      end
    end
  end
end