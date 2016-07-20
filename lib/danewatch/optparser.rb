require 'optparse'

class OptParser
  # Parse command line options
  def self.parse_options(args)
    parsed_options = {
      interval: 1,
      notify: []
    }

    options = OptionParser.new do |opts|
      opts.on('-t', '--time INTERVAL', Integer, 'Update interval in hours') do |i|
        parsed_options[:interval] = i.to_i
      end

      opts.on('-e', '--emails EMAILS', Array, 'Comma separated list of emails to notify') do |emails|
        parsed_options[:notify] = emails
      end
    end

    begin
      options.parse! args
    rescue OptionParser::ParseError => error
      $stderr.puts error
      $stderr.puts '(-h or --help will show valid options)'
      exit 1
    end

    parsed_options
  end
end
