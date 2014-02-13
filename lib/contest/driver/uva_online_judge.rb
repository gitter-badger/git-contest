#
# uva_online_judge.rb
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'contest/driver/common'

module Contest
  module Driver
    class UvaOnlineJudge < DriverBase
      def initialize_ext
        @client = Mechanize.new {|agent|
          agent.user_agent_alias = 'Windows IE 7'
        }
      end

      def get_opts_ext
        define_options do
          opt(
            :problem_id,
            "Problem ID (Ex: 100, 200, etc...)",
            :type => :string,
            :required => true,
          )
        end
      end

      def get_problem_id(options)
        "#{options[:problem_id]}"
      end

      def get_site_name
        "UVa"
      end

      def get_desc
        "UVa Online Judge (URL: http://uva.onlinejudge.org/)"
      end

      def resolve_language(label)
        case label
        when "c"
          return "1"
        when "cpp"
          return "3"
        when "cpp11"
          return "5"
        when "java"
          return "2"
        when "pascal"
          return "4"
        else
          abort "unknown language"
        end
      end

      def submit_ext
        trigger 'start'
        problem_id = @options[:problem_id]

        # submit
        trigger 'before_login'
        login_page = @client.get 'http://uva.onlinejudge.org/'
        login_page.form_with(:id => 'mod_loginform') do |form|
          form.username = @config["user"]
          form.passwd = @config["password"]
        end.submit
        trigger 'after_login'

        trigger 'before_submit', @options
        submit_page = @client.get 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=25'
        res_page = submit_page.form_with(:action => 'index.php?option=com_onlinejudge&Itemid=25&page=save_submission') do |form|
          form.localid = problem_id
          form.radiobutton_with(:name => 'language', :value => @options[:language]).check
          form.code = File.read(@options[:source])
        end.submit
        trigger 'after_submit'

        # <div class="message">Submission received with ID 12499981</div>
        trigger 'before_wait'
        submission_id = get_submission_id(res_page.body)
        status = get_status_wait(submission_id)
        trigger(
          'after_wait',
          {
            :submission_id => submission_id,
            :status => status,
            :result => get_commit_message(status),
          }
        )

        trigger 'finish'
        get_commit_message(status)
      end

      def is_wait_status(status)
        case status
        when "Sent to judge", "Running", "Compiling", "Linking", "Received", ""
          true
        else
          false
        end
      end

      def get_status_wait(submission_id)
        submission_id = submission_id.to_s
        # wait result
        12.times do
          sleep 10
          my_page = @client.get 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=9'
          status = get_submission_status(submission_id, my_page.body)
          return status unless is_wait_status status
          trigger 'retry'
        end
        trigger 'timeout'
        return 'timeout'
      end

      def get_submission_id(body)
        doc = Nokogiri::HTML(body)
        text = doc.xpath('//div[@class="message"]')[0].text().strip
        text.match(/Submission received with ID ([0-9]+)/)[1]
      end

      def get_submission_status(submission_id, body)
        doc = Nokogiri::HTML(body)
        doc.xpath('//tr[@class="sectiontableheader"]/following-sibling::node()').search('tr').each do |elm|
          td_list = elm.search('td')
          item_submission_id = td_list[0].text.strip
          if item_submission_id == submission_id
            item_problem_id = td_list[1].text.strip
            item_status = td_list[3].text.strip
            return item_status
          end
        end
        'timeout'
      end
    end
  end
end
