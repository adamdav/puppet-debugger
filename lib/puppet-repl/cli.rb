require 'puppet'
require 'puppet/pops'
require 'readline'
require_relative 'support'
module PuppetRepl
  class Cli
    include PuppetRepl::Support

    def puppet_eval(input)
      begin
        parser.evaluate_string(scope, input)
      rescue ArgumentError => e
        e.message
      rescue Puppet::ParseErrorWithIssue => e
        e.message
      rescue Exception => e
        e.message
      end
    end

    def normalize_output(result)
      if result.instance_of?(Array)
        if result.count == 1
          return result.first
        end
      end
      result
    end

    def handle_input(input)
      case input
      when 'help'
        PuppetRepl::Cli.print_repl_desc
      when 'functions'
        puts function_files
      when 'types'
        puts "list of types coming soon"
      when '_'
        puts(" => #{@last_item}")
      when 'exit'
        exit 0
      when 'pry'
        require 'pry'
        binding.pry
      when 'reset'
        @scope = nil
      else
        result = puppet_eval(input)
        @last_item = result
        puts(" => #{normalize_output(result)}")
      end
    end

    def self.ripl_start
      Ripl.start
    end

    def self.print_repl_desc
      puts(<<-EOT)
Puppet Version: #{Puppet.version}
Puppet Repl Version: #{PuppetRepl::VERSION}
Created by: NWOps <corey@nwops.io>
Type "exit", "functions", "types", "reset", "help" for more information.

      EOT
    end

    def self.start
      print_repl_desc
      repl_obj = new
      while buf = Readline.readline(">> ", true)
        repl_obj.handle_input(buf)
      end
    end
  end
end