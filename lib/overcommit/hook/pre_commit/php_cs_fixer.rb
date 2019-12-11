# frozen_string_literal: true

module Overcommit::Hook::PreCommit
  # Runs `php-cs-fixer` against any modified PHP files.
  class PhpCsFixer < Base
    MESSAGE_REGEX = /\d+\)\s+(?<file>.*\.php)(?<violated_rules>\s+\((?:.*)\))/

    def run
      messages = []
      feedback = ''

      # Exit status for all of the runs. Should be zero!
      exit_status_sum = 0

      applicable_files.each do |file|
        result = execute(command, args: [file])
        output = result.stdout.chomp
        exit_status_sum += result.status

        if result.status
          messages = output.lstrip.split("\n")
        end
      end

      unless messages.empty?
        feedback = parse_messages(messages)
      end

      if exit_status_sum == 0
        :pass
      else
        feedback.empty? ? :fail : [:fail, feedback]
      end
    end

    def parse_messages(messages)
      output = []

      messages.map do |message|
        message.scan(MESSAGE_REGEX).map do |file, violated_rules|
          output << file + violated_rules
        end
      end

      output
    end
  end
end
