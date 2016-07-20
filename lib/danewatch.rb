require 'clockwork'

require 'optparse'

require_relative 'danewatch/optparser'
require_relative 'danewatch/watcher'

module DaneWatch
  include Clockwork

  # Only do scheduling if script is being called on command line or by clockwork
  if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?('clockwork') || $PROGRAM_NAME.end_with?('clockworkd')

    # Parse command line options
    options = OptParser.parse_options ARGV

    # Add email recipients specified on command line
    recipients = options[:notify]
    if recipients.nil? || recipients.empty?
      $stderr.puts 'Specify at least one email address to receive notifications'
      exit
    end

    recipients.each do |recipient|
      Watcher.add_recipient recipient
    end

    # Create job definitions
    UPDATE_LISTINGS_JOB = 'frequent.update_listings'.freeze

    handler do |job|
      Watcher.check_for_updates if job.eql?(UPDATE_LISTINGS_JOB)
    end

    # Schedule jobs
    every(options[:interval].hours, UPDATE_LISTINGS_JOB)
  end
end
