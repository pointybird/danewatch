require 'mechanize'
require 'hashdiff'
require 'log4r'
require 'gmail'

require 'set'
require 'yaml'

module DaneWatch
  Log = Log4r::Logger.new 'Watcher'
  # Log all messages to stdout
  Log.add Log4r::Outputter.stdout
  # Log errors to disk
  Log.add Log4r::FileOutputter.new('logfile',
                                   filename: './monitor.log',
                                   trunc: false,
                                   level: Log4r::ERROR)

  class Watcher
    URL = 'http://rmgreatdane.org/available-great-danes/'.freeze
    CONTENT_DIV = "//div[@class='usquare_module_wrapper']".freeze
    TARGET_SPAN_STYLE = "[@style='color: #000000 !important;']".freeze
    DOGS_FILE = 'dogs.yml'.freeze

    # Scrapes webpage to get a listing of available dogs and their current status
    def self.available_dogs
      mechanize = Mechanize.new
      page = mechanize.get URL

      dogs = []
      page.xpath(CONTENT_DIV + '//h2').children.each do |dog|
        dogs << dog.text
      end

      statuses = []
      page.xpath(CONTENT_DIV + '//span' + TARGET_SPAN_STYLE).children.each do |status|
        next if status.text == 'info:'
        statuses << status.text
      end

      # Create hash matching each dog with its current status
      dogs.zip(statuses).to_h
    end

    # Generates text summarizing the changes in listings since last update
    def self.difference_report(old_dogs, new_dogs)
      diffs = HashDiff.diff(old_dogs, new_dogs)

      return '' if diffs.empty?

      report = []
      diffs.each do |diff|
        report <<
          case diff[0]
            when '-' then "#{diff[1]} is no longer available"
            when '~' then "#{diff[1]} has changed from '#{diff[2]}' to '#{diff[3]}'"
            when '+' then "#{diff[1]} has been added with a status of '#{diff[2]}'"
          end
      end

      report.join("\n")
    end

    # Set of emails registered to receive updates
    def self.recipients
      @recipients ||= Set.new
    end

    # Adds email address to be notified of changes
    def self.add_recipient(recipient)
      return unless recipient && !recipient.empty?

      recipients << recipient
      Log.info "#{recipient} added to recipient list"
    end

    def self.load_dogs(file = DOGS_FILE)
      YAML.load_file(file).to_h
    end

    def self.save_dogs(latest_dogs, file = DOGS_FILE)
      File.open(file, 'w') do |f|
        f.write latest_dogs.to_yaml
      end
    end

    MAX_SOCKET_RETRIES = 3
    RETRY_WAIT = 10 # seconds

    def self.give_up(exception)
      Log.error "#{exception}: Giving up for now..."
    end

    # Compare current listings against cached ones and see if anything has changed
    def self.check_for_updates
      num_retries = 0

      begin
        latest_dogs = available_dogs

        # Load last results
        previous_dogs = load_dogs
      rescue Errno::ENOENT
        # First run presumably, save list and return
        save_dogs latest_dogs
        return
      rescue SocketError => e
        num_retries += 1
        if num_retries <= MAX_SOCKET_RETRIES
          sleep RETRY_WAIT
          Log.error "#{e}: Retrying in #{RETRY_WAIT} seconds..."
          retry
        end
        give_up e
        return
      rescue StandardError => e
        # Some other error happened, bail out
        give_up e
        return
      end

      report = difference_report(previous_dogs, latest_dogs)

      # Nothing to do
      return if report.empty?

      # Update cached listings
      save_dogs latest_dogs

      # Send notifications
      notify report
    end

    # Send notification email from a gmail account
    def self.send_gmail(recipient, report)
      creds = YAML.load_file('gmail.yml').to_h

      unless creds
        Log.error 'Unable to load gmail credentials. Store account and password in gmail.yml'
        return
      end

      gmail = Gmail.connect!(creds['account'], creds['password'])
      gmail.deliver do
        to recipient
        subject 'Updates to Great Dane listings'
        body report
      end
      gmail.logout
    end

    # Send an email with listing updates to all registered recipients
    def self.notify(report)
      return if !report || report.empty? || @recipients.empty?

      failures = 0
      @recipients.each do |recipient|
        begin
          send_gmail(recipient, report)
        rescue StandardError => e
          Log.error "Unable to send mail to #{recipient}: #{e}"
          failures += 1
        end
      end

      Log.error "Undelivered message:\n\n#{report}" if failures > 0
    end
  end
end
