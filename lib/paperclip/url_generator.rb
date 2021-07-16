require 'uri'
require 'active_support/core_ext/module/delegation'
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

module Paperclip
  class UrlGenerator
    def initialize(attachment)
      @attachment = attachment
    end

    def for(style_name, options)
      interpolated = attachment_options[:interpolator].interpolate(
        most_appropriate_url, @attachment, style_name
      )

      escaped = escape_url_as_needed(interpolated, options)
      timestamp_as_needed(escaped, options)
    end

    private

    attr_reader :attachment
    delegate :options, to: :attachment, prefix: true

    # This method is all over the place.
    def default_url
      if attachment_options[:default_url].respond_to?(:call)
        attachment_options[:default_url].call(@attachment)
      elsif attachment_options[:default_url].is_a?(Symbol)
        @attachment.instance.send(attachment_options[:default_url])
      else
        attachment_options[:default_url]
      end
    end

    def most_appropriate_url
      if @attachment.original_filename.nil?
        default_url
      else
        attachment_options[:url]
      end
    end

    def timestamp_as_needed(url, options)
      if options[:timestamp] && timestamp_possible?
        delimiter_char = url.match(/\?.+=/) ? '&' : '?'
        "#{url}#{delimiter_char}#{@attachment.updated_at.to_s}"
      else
        url
      end
    end

    def timestamp_possible?
      @attachment.respond_to?(:updated_at) && @attachment.updated_at.present?
    end

    def escape_url_as_needed(url, options)
      if options[:escape]
        escape_url(url)
      else
        url
      end
    end

    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        GCI.escape(url).gsub(escape_regex){|m| "%#{m.ord.to_s(16).upcase}" }
      end
    end

    def escape_regex
      /[\?\(\)\[\]\+]/
    end

    
  end
end
