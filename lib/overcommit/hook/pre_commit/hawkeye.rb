# frozen_string_literal: true

module Overcommit::Hook::PreCommit
  # Runs `Hawkeye` against any modified files.
  #
  # @see https://github.com/BTLzdravtech/scanner-cli
  class Hawkeye < Base
    def run
      result = execute(command, args: applicable_files)
      output = result.stdout.chomp.lstrip
      return :pass if result.success?
      output = output.split("\n").select { |output| output[/.*(low|medium|high|critical).*/] }.join("\n")
      [:fail, output]
    end
  end
end
