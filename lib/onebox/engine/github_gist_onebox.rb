module Onebox
  module Engine
    class GithubGistOnebox
      include Engine
      include LayoutSupport

      matches_regexp Regexp.new("^http(?:s)?://gist\\.(?:(?:\\w)+\\.)?(github)\\.com(?:/)?")

      # merged from githubblob
      EXPAND_AFTER = 0b001 
      EXPAND_BEFORE = 0b010
      EXPAND_NONE = 0b0
      
      DEFAULTS = {
              :EXPAND_ONE_LINER => EXPAND_AFTER|EXPAND_BEFORE, #set how to expand a one liner. user EXPAND_NONE to disable expand
              :LINES_BEFORE => 10,
              :LINES_AFTER => 10,
              :SHOW_LINE_NUMBER => true,
              :MAX_LINES => 20,
              :MAX_CHARS => 5000
      }

      def initialize(link, cache = nil, timeout = nil)
        super link, cache , timeout
        #merge engine options from global Onebox.options interface
        # self.options = Onebox.options["GithubBlobOnebox"] #  self.class.name.split("::").last.to_s
        # self.options = Onebox.options[self.class.name.split("::").last.to_s] #We can use this a more generic approach. extract the engine class name automatically 
        
        self.options = DEFAULTS

        # Define constant after merging options set in Onebox.options
        # We can define constant automatically. 
        options.each_pair {|constant_name,value|
          constant_name_u = constant_name.to_s.upcase
              if constant_name_u == constant_name.to_s
                #define a constant if not already defined
                self.class.const_set  constant_name_u.to_sym , options[constant_name_u.to_sym]  unless self.class.const_defined? constant_name_u.to_sym
              end
        }
      end

@selected_lines_array  = nil
@selected_one_liner = 0
def calc_range(m,contents_lines_size)
        #author Lidlanca  09/15/2014
        truncated = false
        from = /\d+/.match(m[:from])             #get numeric should only match a positive interger
        to   = /\d+/.match(m[:to])               #get numeric should only match a positive interger
        range_provided = !(from.nil? && to.nil?) #true if "from" or "to" provided in URL
        from = from.nil? ?  1 : from[0].to_i     #if from not provided default to 1st line
        to   = to.nil?   ? -1 : to[0].to_i       #if to not provided default to undefiend to be handled later in the logic
        
        if to === -1 && range_provided   #case "from" exists but no valid "to". aka ONE_LINER
          one_liner = true
          to = from
        else
          one_liner = false
        end

        unless range_provided  #case no range provided default to 1..MAX_LINES
          from = 1 
          to   = MAX_LINES
          truncated = true if contents_lines_size > MAX_LINES
          #we can technically return here
        end

        from, to = [from,to].sort                                #enforce valid range.  [from < to]
        from = 1 if from > contents_lines_size                   #if "from" out of TOP bound set to 1st line
        to   = contents_lines_size if to > contents_lines_size   #if "to" is out of TOP bound set to last line.
        
        if one_liner
          @selected_one_liner = from
          if EXPAND_ONE_LINER != EXPAND_NONE
            if (EXPAND_ONE_LINER & EXPAND_BEFORE != 0) # check if EXPAND_BEFORE flag is on
              from = [1, from - LINES_BEFORE].max      # make sure expand before does not go out of bound
            end

            if (EXPAND_ONE_LINER & EXPAND_AFTER != 0)          # check if EXPAND_FLAG flag is on
              to = [to + LINES_AFTER, contents_lines_size].min # make sure expand after does not go out of bound
            end

            from = contents_lines_size if from > contents_lines_size   #if "from" is out of the content top bound 
            # to   = contents_lines_size if to > contents_lines_size   #if "to" is out of  the content top bound
          else
            #no expand show the one liner solely 
          end
        end
        
        if to-from > MAX_LINES && !one_liner  #if exceed the MAX_LINES limit correct unless range was produced by one_liner which it expand setting will allow exceeding the line limit
          truncated = true
         to = from + MAX_LINES-1  
        end

        {:from               => from,                 #calculated from
         :from_minus_one    => from-1,                #used for getting currect ol>li numbering with css used in template
         :to                 => to,                   #calculated to
         :one_liner          => one_liner,            #boolean if a one-liner
         :selected_one_liner => @selected_one_liner,  #if a one liner is provided we create a reference for it.
         :range_provided     => range_provided,       #boolean if range provided 
         :truncated          => truncated}
      end

      #minimize/compact leading indentation while preserving overall indentation 
      def removeLeadingIndentation  str
        #author Lidlanca 2014
        min_space=100
        a_lines = str.lines
        a_lines.each {|l|
          l = l.chomp("\n")  # remove new line 
          m = l.match /^[ ]*/ # find leading spaces 0 or more
          unless m.nil? || l.size==m[0].size || m[0].size==0 # no match | only spaces in line | empty line
            m_str_length  = m[0].size
            if m_str_length <= 1  # minimum space is 1 or nothing we can break we found our minimum
              min_space = m_str_length
              break #stop iteration
            end 
            if m_str_length < min_space
              min_space = m_str_length
            end 
          else
            next # SKIP no match or line is only spaces
          end 
        }
        a_lines.each {|l|
          re = Regexp.new "^[ ]{#{min_space}}"  #match the minimum spaces of the line
          l.gsub!(re, "")
        }
        a_lines.join
      end

      def line_number_helper(lines,start,selected) 
        #author Lidlanca  09/15/2014
        lines = removeLeadingIndentation(lines.join).lines # A little ineffeicent we could modify  removeLeadingIndentation to accept array and return array, but for now it is only working with a string
        hash_builder =[]
        output_builder = []
        lines.map.with_index { |line,i|
          lnum = (i.to_i+start)
          hash_builder.push({:line_number => lnum, :data=> line.gsub("\n",""), :selected=> (selected==lnum)? true: false} )
          output_builder.push "#{lnum}: #{line}"
        }
        {:output=>output_builder.join(), :array=>hash_builder}
      end
# /merged from githubblob


# Gist Helpers | Lidlanca 10/12/2014
#---------------------------------------------------------------------
# 
      # Convert a native file name to the hash gist is using for permalinks
      def gist_file_to_hash filename
        filename.gsub!( /[^A-z0-9!@#$%^&*()<>+.\-_'"\\ ]+/ , "" ) #remove none-english none-numeric and none-accepted chars
        filename.gsub!( /[!@#$%^&*()<>+.\-"'\\ ]+/ , "-" )        #convert acceptable char to "-"
        # only single dash will be produced between each valid char
        filename.downcase!                                        
        filename
      end 

      # find matching files returned by the api to the given url#hash
      # more then 1 file can match the url#hash. we return all matched 
      # but we probably goingto use only the first one.
      def find_matching_files hash, file_list, prefix ="file-"
        match_files = []
        file_list.each {|f|
          filename = f[1]["filename"]
          prefix_file_name = (prefix + gist_file_to_hash(filename)).gsub('--','-') # if file name from json contain leading - and prefix contain - at the end we need to clean double dash --
            
          if hash == prefix_file_name  # add prefix to file name from json
            match_files << f 
          end
        }
        match_files = nil if match_files.size==0
        match_files
      end 

      # parse a gist url and return a breakdown
      # Author Lidlanca
      # Abstraction of the matcher
      # http(s)://gist.github.com/<org>/<repo/commit>/#<filename><line_range>
      # org
      # repo_commit      
      # fname
      # lines_range
      # only_fname       fname and only_fname will require post processing   fname = fname | only_fname
      # m =url.match /https?:\/\/gist.github.com\/(?<org>[^\/]+)\/(?<repo_commit>(?<repo>[^#\/\n]+)?(\/(?<commit>[^#\n\/]+))?)\/?((#(?<fname>[^A-Z\n]+)-(?<lines_range>L[0-9]+-?(L[0-9]*)?))|#(?<only_fname>[^\nA-Z#\/]+)?)?/ 
      def parse_gist_url url
        m = url.match /https?:\/\/gist.github.com\/(?<org>[^\/]+)\/(?<repo_commit>(?<repo>[^#\/\n]+)?(\/(?<commit>[^#\n\/]+))?)\/?((#(?<fname>[^A-Z\n]+)-(?<lines_range>L(?<from>[0-9]+)-?(L(?<to>[0-9]*))?))|#(?<only_fname>[^\nA-Z#\/]+)?)?/
        {
          :file_name    => m["fname"] || m["only_fname"],   # make sure we get one of the matched names
          :repo_commit  => m["repo_commit"],
          :lines_range  => m["lines_range"],
          :from => m["from"],
          :to => m["to"],
          :match => m # orignal match object
        }
      end
#----------------------/Gist Helpers ------------------


private

      def raw
        options_id = self.class.name.split("::").last.to_s  #get class name without module namespace
        return @raw if @raw

        m = parse_gist_url @url
        if m
          from = /\d+/.match(m[:from])   #get numeric should only match a positive interger
          to   = /\d+/.match(m[:to])     #get numeric should only match a positive interger
          json_url = "https://api.github.com/gists/" + m[:repo_commit]
          json_data  = ::MultiJson.load(open(json_url,"Accept"=>"application/vnd.github.v3.text+json",:read_timeout=>timeout )) #custom Accept header so we can get body as text.
          

          unless m[:file_name].nil?  
              mf = find_matching_files m[:file_name] , json_data["files"] # return matching files array or null    
              if mf
                contents = mf.first[1]["content"]   # grab the first matching file
              else
                contents = json_data["files"].first[1]["content"] #if file provided but no match default to first file
                #we could add a warning to the output but for now we just handel this scenrio 
              end
          else            #if no specific file is provided in url#hash we default to the first file in the gist
              contents = json_data["files"].first[1]["content"]
          end

          contents_lines = contents.lines           #get contents lines 
          contents_lines_size = contents_lines.size #get number of lines


          #---- Use the same logic from github blob onebox
                cr = calc_range(m,contents_lines_size)    #calculate the range of lines for output
                selected_one_liner = cr[:selected_one_liner] #if url is a one-liner calc_range will return it
                from           = cr[:from]
                to             = cr[:to]
                @truncated     = cr[:truncated]
                range_provided = cr[:range_provided]
                one_liner      = cr[:one_liner]
                @cr_results = cr
                if range_provided || true  #enable for all     #if a range provided (single line or more)  
                    if SHOW_LINE_NUMBER
                      lines_result = line_number_helper(contents_lines[from-1..to-1], from, selected_one_liner)  #print code with prefix line numbers in case range provided
                      contents = lines_result[:output]
                      @selected_lines_array = lines_result[:array] 
                    else 
                      contents = contents_lines[from-1..to-1].join()
                    end
                # else
                  # contents = contents_lines[from-1..to-1].join()
                end

                if contents.length > MAX_CHARS    #truncate content chars to limits
                  contents = contents[0..MAX_CHARS]
                  @truncated = true
                end

                @raw = contents
                
              #-----
      end 
    end

    #not called/used with the new engine
    def match
      @match ||= @url.match(%r{gist\.github\.com/([^/]+/)?(?<sha>[0-9a-f]+)})
    end
     
      def data
              @data ||= {title: link.sub(/^https?\:\/\/github\.com\//, ''),
                         link: link,
                         content: raw,
                         lines:  @selected_lines_array ,
                         has_lines: !@selected_lines_array.nil?,
                         selected_one_liner: @selected_one_liner,
                         cr_results:@cr_results,
                         truncated: @truncated}
      end


    end
  end
end