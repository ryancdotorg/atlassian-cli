require 'time'

require 'atlassian/exceptions'

module Atlassian
  module Hashifiers

    class JiraIssue
      # this class turns a json object returned by the rest service into a flat hash of column-to-value mappings
      attr_accessor :client
      attr_accessor :include_comments

      # mapping to find each column in the structure returned from the rest API
      ISSUE_COLUMN_MAP = {
        :id => Proc.new {|s,issue| issue[:id] },
        :key => Proc.new {|s,issue| issue[:key] },
        :url => Proc.new {|s,issue| issue[:self] },
        :description => Proc.new {|s,issue| issue[:fields].andand[:description] },
        :created => Proc.new {|s,issue| issue[:fields].andand[:created] },
        :updated => Proc.new {|s,issue| issue[:fields].andand[:updated] },
        :priority => Proc.new {|s,issue| issue[:fields].andand[:priority].andand[:name] },
        :status => Proc.new {|s,issue| issue[:fields].andand[:status].andand[:name] },
        :summary => Proc.new {|s,issue| issue[:fields].andand[:summary] },
        :assignee => Proc.new {|s,issue| issue[:fields].andand[:assignee].andand[:name] },
        :reporter => Proc.new {|s,issue| issue[:fields].andand[:reporter].andand[:name] },
        :resolution => Proc.new {|s,issue| issue[:fields].andand[:resolution].andand[:name] || "<none>" },
        :fixversions => Proc.new {|s,issue| issue[:fields].andand[:fixVersions].andand.collect {|x| x[:name] } },
        :affectsversions => Proc.new {|s,issue| issue[:fields].andand[:versions].andand.collect {|x| x[:name] } },
        :components => Proc.new {|s,issue| issue[:fields].andand[:components].andand.collect {|x| x[:name] } },
        :default => Proc.new {|s,issue,colname| issue[:fields].andand[colname] || nil },
        :type => Proc.new {|s,issue,colname| issue[:fields].andand[:issuetype].andand[:name] },
        :comments => Proc.new {|s,issue| s.include_comments ? s.client.get_comments_for_issue(issue).andand[:comments].collect {|x| { :displayName => x[:author][:displayName], :name => x[:author][:name], :body => x[:body], :created => x[:created] } } : nil },
      }

      def initialize(options = {})
        @client = options[:client]
        @include_comments = options[:include_comments]
      end

      def get_row(cols, issue)
        row = []
        cols.each do |col|
          data = get_column(col, issue)
          data = format_text_by_column(col, data)
          row << data
        end
        row
      end

      def get_hash(rest_issue)
        issue_hash = {}
        ISSUE_COLUMN_MAP.keys.sort.each do |col|
          issue_hash[col] = ISSUE_COLUMN_MAP[col].call(self,rest_issue)
        end
        return issue_hash
      end
    end
  end
end



