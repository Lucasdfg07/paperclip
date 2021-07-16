module Paperclip
  class HttpUrlProxyAdapter < UriAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        String === target && target =~ REGEXP
      end
    end

    REGEXP = /\Ahttps?:\/\//

    def initialize(target, options = {})
      escaped = GCI.escape(target)
      super(URI(target == GCI.unescape(target) ? escaped : target), options)
    end
  end
end
