module Paperclip
  module UrlGenerator
    class GCI
      def escape(string)
        encoding = string.encoding
        string.b.gsub(/([^ a-zA-Z0-9_.\-~]+)/) do |m|
          '%' + m.unpack('H2' * m.bytesize).join('%').upcase
        end.tr(' ', '+').force_encoding(encoding)
      end

      # URL-decode a string with encoding(optional).
      #   string = CGI.unescape("%27Stop%21%27+said+Fred")
      #      # => "'Stop!' said Fred"
      def unescape(string,encoding=@@accept_charset)
        str=string.tr('+', ' ').b.gsub(/((?:%[0-9a-fA-F]{2})+)/) do |m|
          [m.delete('%')].pack('H*')
        end.force_encoding(encoding)
        str.valid_encoding? ? str : str.force_encoding(string.encoding)
      end
    end
  end
end