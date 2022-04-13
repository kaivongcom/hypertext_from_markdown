class HypertextFromMyMarkdownParser < Object
	attr_reader :results
	START_TABLE = '<table summary="">'
	TABLE_HEADER = 'thead'

	def initialize(markdown_text, attrs_hash={})
		@attrs = {}
		element_name, @attrs[:class], @attrs[:title], @attrs[:href],@attrs[:id] = attrs_hash['element_name'], attrs_hash['attr_class'], attrs_hash['link_title'], attrs_hash['href'], attrs_hash['attr_id']
		@markdown_text = markdown_text.chomp
		element_name = find_element(element_name, markdown_text) if element_name == nil
		markdown_searches(markdown_text) #
		length = @markdown_text.scan(/\n/).count
		markdown_obj = { text: @markdown_text, length: length }
		@results = wrap_markdown(element_name, markdown_obj, @attrs)
	end

	def markdown_searches(md)
		find_bold(md)
		find_emphasis(md)
		find_img(md)
		find_links(md)
		find_strong(md)
		find_tables(md)
	end

	def find_element(element, md)
		element = (md.scan(/^#/).count) == 1 || (md.scan(/ $/).count) == 1
	end

	def find_bold(markdown_text)
		matches = markdown_text.match(/\*\*(.*)\*\*/)
		strong_html(matches) if matches
	end


	def find_emphasis(markdown_text)
		matches = markdown_text.match(/\*(.*)\*/)
		em_html(matches) if matches
	end

	def find_img(markdown_text)
		matches = markdown_text.match(/^!\[(.*)\]\((.*)\)/)
		html_img(matches) if matches
	end

	def html_img(matches)
		image = "<img alt=\"#{matches[1]}\" src=\"#{matches[2]}\">"
		@markdown_text.gsub!(matches[0], image)
	end

	def find_strong(markdown_text)
		matches = markdown_text.match(/\*\*(.*)\*\*/)
		strong_html(matches) if matches
	end

	def find_tables(text)
		table_arr = text.split("|")
		table_html(table_arr, text) if table_arr.size > 1 
	end

	def table_html(arr, markdown)
		arr.shift
		element = (arr.shift == ' # ') ?  TABLE_HEADER : false
		table_element_partial = !element ? '' : START_TABLE + '<' + element + '>'
		# items = arr.compact.collect { |item| find_links(item) if item != nil }

		attributes = @attrs[:id] ? " id=\"#{@attrs[:id]}\"" : ''
		attributes += @attrs[:class] ? " class=\"#{@attrs[:class]}\"" : ''
		table_row = "<tr#{attributes}>"
		html = table_element_partial + table_row + (arr.compact.collect { |item| '<td>' + item.strip + '</td>'   }.join) + "</tr>#{element ? '</' + element + '>' : '' }"
		@markdown_text.gsub!(markdown, html)
	end

	def strong_html(strong_matches)
		strong_html = "<strong>#{strong_matches[1]}</strong>"
		@markdown_text.gsub!(strong_matches[0], strong_html)
	end

	def em_html(em_matches)
		html_em = "<em>#{em_matches[1]}</em>"
		@markdown_text.gsub!(em_matches[0], html_em)
	end

	def find_links(markdown_text)
		link_matches = markdown_text.match(/\[(.*)\]\((.*)\)/)
		link_html(markdown_text, link_matches) if link_matches
	end

	def wrap_markdown(element, markdown, attrs)
		if element == false
			@markdown_text.chomp
		elsif element == true
			if @markdown_text.match(/^#|====/)
				header_html(markdown)
			else
				paragraph_html(markdown, attrs)
			end
		else
			if @markdown_text.match(/^#|====/)
				header_html(markdown)
			elsif @markdown_text.match(/^!/)
				unescaped_html(@markdown_text)
			else
				wrap_html(markdown, element, attrs)
			end
		end
	end

	def split_title_arr(match_data)
		attrs, title  = {}, match_data[2].split(' ')
		url = title[0]
		attrs['href'] = url
		title = title[1..-1].join(' ')
		title = title.length > 1 ? title.to_s : ''
		if title.include?('external')
			url = URI(url)
			attrs['class'] = 'external'
			attrs['domain'] = url.scheme  + '://' + url.host
		end
		attrs['title'] = title if (title.length > 1)
		attrs
	end

	def link_html(text, match_data)
		full_link = text.match(/\[(.*)\)/)[0]
		attrs, element_attrs, text = split_title_arr(match_data),{},match_data[1]
		['href','title', 'id', 'class'].each do |attr|
			element_attrs[attr] = attrs[attr] if attrs[attr]
		end
		element_and_attrs = element_attrs.collect { |attr, value| " #{attr}=\"#{value.gsub("'",'')}\"" }.join('')
		external_domain = attrs['domain'] ? (' (' + attrs['domain'].gsub('https://','').gsub('www.','') + ')') : ''
		link_text = "<a#{element_and_attrs}>#{text}</a>#{ external_domain }"
		@markdown_text.gsub!(full_link, link_text)
	end

	def single_header_html(text)
		element_number = if text.scan(/^####/).length == 1
			4
		elsif text.scan(/^###/).length == 1
			3
		elsif text.scan(/^##/).length == 1
			2
		elsif text.scan(/^#/).length == 1
			1
		end
		element = "h#{element_number}"
		header_md = '#' * element_number
		class_attr = text.scan(/^#{header_md}\.(\w+)/)
		class_name = if class_attr.empty? 
				''
			else 
				class_attr = class_attr[0][0]
				text.gsub!(".#{class_attr} ",'')
				" class=\"#{class_attr}\""
			end
		plain_text = text[element_number..-1].strip
		"<#{element}#{class_name}>#{plain_text}</#{element}>"
	end

	def multi_header_html(text)
		single_header_html '#' + text.split("\n")[0]
	end

	def header_html(obj)
		if obj[:length] == 0
			single_header_html(obj[:text])
		elsif obj[:length] == 1
			multi_header_html(obj[:text])
		end
	end

	def paragraph_html(obj, attrs)
		obj[:text] == ' ' ? '' : wrap_html(obj, 'p', attrs)
	end

	def unescaped_html(text)
		text[1..-1]
	end

	def wrap_html(obj, element_name, attrs)
		element_attrs = ''
		element_attrs += " id=\"#{attrs[:id]}\"" if attrs[:id]
		element_attrs += " class=\"#{attrs[:class]}\"" if attrs[:class]
		element_attrs += " href=\"#{attrs[:href]}\"" if attrs[:href]
		obj[:text].split("\n").collect do |element_text|
			"<#{element_name}#{element_attrs}>#{element_text}</#{element_name}>"
		end.join
	end
end
