# frozen_string_literal: true

module Overcommit::Hook::PreCommit
  # Runs `erb-lint` against any modified Ruby ERB files.
  #
  # @see https://github.com/Shopify/erb-lint
  class ErbLint < Base
    MESSAGE_REGEX = /^\s*(?<file>(?:\w:)?[^:]+):(?<line>\d+)/

    def run
      result = execute(command, args: applicable_files)
      output = result.stdout.chomp.lstrip
      return :pass if result.success?
      output = output.split("\n").select { |output| output[/^\s*(?:\w:)?[^:]+:\d+.*/] }
      # example message:
      #   path/to/file.rb:1:1: Error message (ruleName)
      extract_messages(
        result.stdout.split("\n\n")[1..],
        MESSAGE_REGEX
      )
    end
  end
end
