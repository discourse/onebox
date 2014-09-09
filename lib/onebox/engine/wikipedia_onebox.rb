module Onebox
  module Engine
    class WikipediaOnebox
      include Engine
      include LayoutSupport
      include HTML

      matches_regexp(/^https?:\/\/.*wikipedia\.(com|org)/)

      private

      def data
        
        paras = []
        text = ""

        
        # Detect Section URL Hash and retrive section paragraphs instead the default first article paragraph
        # Author Lidlanca
        # Date 9/8/2014
        if ( m_url_hash = @url.match /#([^\/?]+)/ ) #extract url hash
          m_url_hash_name= m_url_hash[1]
        end

        unless m_url_hash.nil?
          section_header = raw.xpath("//span[@id='#{m_url_hash_name}']/..")
          if section_header.empty?
            paras = raw.search("p") #default get all the paras
          else #section id not found, id are case sensetive 
            cur_element = section_header[0]
            while ( (next_sibling = cur_element.next_sibling).name =~ /p|text/ ) do  #start from the article section header node and and find all related section <p> tags. (<text> node or a <p> node)
              cur_element = next_sibling
              if cur_element.name == "p"
                paras.push(cur_element)
              end 
            end
          end
        else # no hash found in url
          paras = raw.search("p") #default get all the paras
        end 

  
        unless paras.empty?
          cnt = 0
          while text.length < Onebox::LayoutSupport.max_text && cnt <= 3
            break if cnt >= paras.size
            text << " " unless cnt == 0
            paragraph = paras[cnt].inner_text[0..Onebox::LayoutSupport.max_text]
            paragraph.gsub!(/\[\d+\]/mi, "")
            text << paragraph
            cnt += 1
          end
        end

        text = "#{text[0..Onebox::LayoutSupport.max_text]}..." if text.length > Onebox::LayoutSupport.max_text
        result = {
          link: link,
          title: raw.css("html body h1").inner_text,
          description: text
        }
        img = raw.css(".image img")
        if img && img.size > 0
          img.each do |i|
            src = i["src"]
            if src !~ /Question_book/
              result[:image] = src
              break
            end
          end
        end

        result
      end
    end
  end
end
