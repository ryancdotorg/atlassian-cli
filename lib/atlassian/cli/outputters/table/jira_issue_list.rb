require 'highline'
require 'terminal-table'

module Atlassian
  module Cli
    module Outputters
      module Table
        class JiraIssueList < Atlassian::Cli::Outputters::OutputterBase

          attr_accessor :color
          attr_accessor :set_width

          # shared functionality like colors, etc
          # Specifically, defines: format_field(hash, key) and sort_fields(fields)
          include Atlassian::Cli::Outputters::Table::JiraIssueBase

          def initialize(options = {})

            super(options)

            @set_width = options[:set_width]
            if @set_width.nil?
              @set_width = true
            end

            @color = options[:color]
            if @color.nil?
              @color = true
            end
          end

          # called to print the entire object
          # in this case, hash is actually an array of objects
          def print_object(issues)
            if !issues.is_a? Array
              issues = [issues]
            end

            if issues.empty?
              # XXX TODO: better messaging?
              return
            end

            table = Terminal::Table.new do |t|
              if @set_width
                width, height = HighLine::SystemExtensions.terminal_size
                t.style = {:width => width}
              end
              header = []
              sorted_fields = sort_fields(filter_fields(issues.first.keys))
              sorted_fields.each do |key|
                header << key.to_s.capitalize.blue
              end

              t << header
              t << :separator

                issues.each do |hash|
                  row = []
                  sorted_fields.each do |key|
                    row << format_field(hash, key)
                  end
                  t << row
                end
            end
          end
        end # class JiraIssueList
      end
    end
  end
end
