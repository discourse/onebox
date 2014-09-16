module Onebox
  module Engine
    class GithubBlobOnebox
      include Engine
      include LayoutSupport

      MAX_LINES = 20
      MAX_CHARS = 5000

      LINES_BEFORE = 10
      LINES_AFTER = 10

      EXPAND_AFTER = 0b001
      EXPAND_BEFORE = 0b010
      EXPAND_NONE = 0b0
      EXPAND_ONE_LINER = EXPAND_AFTER|EXPAND_BEFORE #set how to expand a one liner. user EXPAND_NONE to disable expand

      SHOW_LINE_NUMBER = true

      matches_regexp(/^https?:\/\/(www\.)?github\.com.*\/blob\//)

      private

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

        {:from            => from,
         :to              => to,
         :one_liner       => one_liner,
         :range_provided  => range_provided,
         :truncated       => truncated}
      end


      def line_number_helper(lines,start) 
        #author Lidlanca  09/15/2014
        output_builder = []
        lines.map.with_index { |line,i|
          lnum = (i.to_i+start)
          output_builder.push "#{lnum}: #{line}"
        }
        output_builder.join()
      end


      def raw
        return @raw if @raw
        m = @url.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)\/blob\/(?<sha1>[^\/]+)\/(?<file>[^#]+)(#(L(?<from>[^-]*)(-L(?<to>.*))?))?/mi)
        if m
          from = /\d+/.match(m[:from])   #get numeric should only match a positive interger
          to   = /\d+/.match(m[:to])     #get numeric should only match a positive interger

          @file = m[:file]
          contents = open("https://raw.github.com/#{m[:user]}/#{m[:repo]}/#{m[:sha1]}/#{m[:file]}", read_timeout: timeout).read
          
          contents_lines = contents.lines 
          contents_lines_size = contents_lines.size
            
          cr = calc_range(m,contents_lines_size)

          from           = cr[:from]
          to             = cr[:to]
          @truncated     = cr[:truncated]
          range_provided = cr[:range_provided]
          one_liner      = cr[:one_liner]

          if range_provided

            if SHOW_LINE_NUMBER
              contents = line_number_helper(contents_lines[from-1..to-1], from)  #print code with prefix line numbers in case range provided
            else 
              contents = contents_lines[from-1..to-1].join()
            end

          else
            contents = contents_lines[from-1..to-1].join()
          end

          if contents.length > MAX_CHARS    #truncate content chars to limits
            contents = contents[0..MAX_CHARS]
            @truncated = true
          end

          @raw = contents
        end
      end

      def data
        @data ||= {title: link.sub(/^https?\:\/\/github\.com\//, ''),
                   link: link,
                   content: raw,
                   truncated: @truncated}
      end

    end
  end
end
