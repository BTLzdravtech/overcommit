# frozen_string_literal: true

module Overcommit::Hook::PreCommit
  # Runs `standardrb` against any modified Ruby files.
  #
  # @see https://github.com/testdouble/standard
  class StandardRb < Base
    MESSAGE_REGEX = /^\s*(?<file>(?:\w:)?[^:]+):(?<line>\d+)/

    def run
      result = execute(command, args: applicable_files)
      output = result.stdout.chomp.lstrip
      return :pass if result.success? && output.empty?
      output = output.split("\n").select { |output| output[/^\s*(?:\w:)?[^:]+:\d+.*/] }

      # example message:
      #   path/to/file.rb:1:1: Error message (ruleName)
      extract_messages(
          output.grep(MESSAGE_REGEX), # ignore header line
          MESSAGE_REGEX
      )
    end
  end
end
