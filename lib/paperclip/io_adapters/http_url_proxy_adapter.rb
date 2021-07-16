module Paperclip
  class HttpUrlProxyAdapter < UriAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        String === target && target =~ REGEXP
      end
    end

    REGEXP = /\Ahttps?:\/\//

    def initialize(target, options = {})
      escaped = escape(target)
      super(URI(target == unescape(target) ? escaped : target), options)
    end

    private

    def unescape(string,encoding=@@accept_charset)
      str=string.tr('+', ' ').b.gsub(/((?:%[0-9a-fA-F]{2})+)/) do |m|
        [m.delete('%')].pack('H*')
      end.force_encoding(encoding)
      str.valid_encoding? ? str : str.force_encoding(string.encoding)
    end

    def escape(string)
      encoding = string.encoding
      string.b.gsub(/([^ a-zA-Z0-9_.\-~]+)/) do |m|
        '%' + m.unpack('H2' * m.bytesize).join('%').upcase
      end.tr(' ', '+').force_encoding(encoding)
    end
  end
end
