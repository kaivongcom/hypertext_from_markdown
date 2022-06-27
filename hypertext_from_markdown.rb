<<<<<<< HEAD
require 'uri'
class HypertextFromMyMarkdownParser < Object
=======
class HyperTextFromMarkdownParser < Object
>>>>>>> 5165a10 (change name)
	attr_reader :results
	NEW_LINE = "\n"
	START_TABLE = '<table summary="">'
	TABLE_HEADER = 'thead'

	def initialize(markdown_text, attrs_hash={})
		attrs_hash = { 'html_element' => attrs_hash } if String == attrs_hash.class
		if attrs_hash['html'] # pure HTML (is this a lint?)
			@results = markdown_from_markup(markdown_text, attrs_hash)
		else
			@attrs = make_attrs(attrs_hash)
			@attrs[:element_name] = element_name = attrs_hash['html_element'] || attrs_hash['element_name']
			@markdown_text = markdown_text.chomp
			element_name = find_element(element_name, @markdown_text) if element_name == nil
			length = @markdown_text.scan(/\n/).count
			markdown_searches(markdown_text)
			markdown_obj = { text: @markdown_text, length: length }
			@results = wrap_markdown(element_name, markdown_obj, @attrs)
		end
	end

	def make_attrs(attrs)
		attrs_hash = {
			:class => attrs['attr_class'],
			:href => attrs['href'],
			:id => attrs['attr_id'],
			:role => attrs['role'],
			:title => attrs['link_title'] }
	end

	def markdown_from_markup(text, attrs)
		html_image = '<img alt="alt text here" height="120" id="example-id" src="/example/picture.jpg" width="100">'
		element, alt, height_key, height, id_key, id, src_key, src, width_key, width = text.split('"')
		"![#{alt}](#{ src + '^' + width + 'x' + height + ' #' + id })"
	end

	def call
		self.results
	end

	def markdown_searches(md)
		find_bold(md)
		find_emphasis(md)
		find_html_img(md); find_links(md); find_list(md);
		# find_strong(md); 
		find_tables(md)
	end

	def find_bold(markdown_text)
		find_strong(markdown_text)
	# 	matches = markdown_text.match(/\*\*(.*)\*\*/)
	# 	strong_html(matches) if matches
	end

	def find_element(element, md)
		element = (md.scan(/^#/).count) == 1 || (md.scan(/ $/).count) == 1
	end

	def find_emphasis(markdown_text)
		matches = markdown_text.match(/\*(.*)\*/)
		em_html(matches) if matches
	end

	def find_html_img(markdown_text)
		matches = markdown_text.match(/^!\[(.*)\]\((.*)\)/)
		html_img(matches) if matches
	end

	def html_img(matches)
		height, width = ' ',''
		src, id = matches[2].split(' #')
		if src.include?('^')
			src, dimensions = src.split('^')
			width, height = dimensions.split('x')
			height = ' height="' + height + '" '
			width = ' width="' + width + '"'
		end
		# placeholder=\"placeholder-.gif\"  nextjs.org lies...
		attrs = ""
		image = "<img alt=\"#{matches[1]}\""+ height + "id=\"#{id}\" loading=\"eager\" src=\"#{src}\"" + width+ ">"
		@markdown_text.gsub!(matches[0], image)
	end

	def find_list(markdown_text)
		matches = markdown_text.match(/^\*\s(.*)/)
		html_list(matches) if matches
	end

	def html_list(matches)
		li_html = matches[1]
		@attrs[:element_name] = 'li'
		@markdown_text =  li_html
	end

	def find_strong(markdown_text)
		attrs, matches = {}, markdown_text.match(/\*\*(.*)\*\*/)
		if matches && matches[0].include?('^')
			attrs[:lang],attrs[:title] =  '', ''
			attrs[:lang], attrs[:title] = matches[0].match(/\^(.*)\^(.*)\^/)[1..2]
		end
		strong_html(matches, attrs) if matches
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
		attributes += @attrs[:role] ? " class=\"#{@attrs[:role]}\"" : ''
		table_row = "<tr#{attributes}>"
		html = table_element_partial + table_row + (arr.compact.collect { |item| '<td>' + item.strip + '</td>'   }.join) + "</tr>#{element ? '</' + element + '>' : '' }"
		@markdown_text.gsub!(markdown, html)
	end

	def strong_html(strong_matches, attrs={})
		# strong_html = "<strong>#{strong_matches[1]}</strong>"
		element_text = strong_matches[1]
		element_text = strong_matches[1].gsub("^#{attrs[:lang]}^#{attrs[:title]}^",'') if !attrs.empty?
		strong_html = wrap_html({text: element_text},'strong',attrs)
		@markdown_text.gsub!(strong_matches[0], strong_html)
	end

	def em_html(em_matches)
		html_em = "<em>#{em_matches[1]}</em>"
		@markdown_text.gsub!(em_matches[0], html_em)
	end

	def wrap_markdown(element, markdown, attrs)
		if element == false
			@markdown_text.chomp
		elsif element == true
			if @markdown_text.match(/^#|====/)
				header_html(markdown)
			elsif @attrs[:element_name] == 'li'
				wrap_html(markdown, @attrs[:element_name], attrs)
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
		attrs[:href] = url
		title = title[1..-1].join(' ')
		title = title.length > 1 ? title.to_s : ''
		if title.include?('external')
			url = URI(url)
			attrs[:class] = 'external'
			attrs[:domain] = url.scheme  + '://' + url.host
		end
		attrs[:title] = title if (title.length > 1)
		attrs
	end

	def find_links(markdown_text)
		potential_link = markdown_text.split(")")[0]
		potential_link = potential_link ? potential_link + ')' : markdown_text
		link_matches = potential_link.match(/\[(.*)\]\((.*)\)/)
		# puts 'elemnt name', @attrs[:element_name], @attrs
		if @element_name == 'a'
			link_matches = { link_tag_name: @attrs[:element_name], href: @attrs[:href] }
		end
		link_html(markdown_text, link_matches) if link_matches
	end

	def link_html(text, match_data)
		potential_link = text.split(")")[0]
		potential_link = potential_link ? potential_link + ')' : text
		full_link = potential_link.match(/\[(.*)\)/)[0]
		attrs, element_attrs, text = split_title_arr(match_data),{},match_data[1]
		['href','title', 'id', 'class', 'role'].each do |attr|
			element_attrs[attr] = attrs[attr] if attrs[attr]
		end
		element_and_attrs = element_attrs.collect { |attr, value| " #{attr}=\"#{value.gsub("'",'')}\"" }.join('')
		external_domain = attrs[:domain] ? (' (' + attrs[:domain].gsub('https://','') + ')') : ''
		if text.include?('!iconLink')
			icon_link = "<span class=\"link-text\">(link)</span>"
			text = icon_link_text = "<i class=\"bi bi-link-45deg\" title=\"icon link\"></i> #{icon_link}"
		end
		link_text = wrap_html({text: text}, 'a', attrs) + external_domain
		@markdown_text.gsub!(full_link, link_text)
	end

	def single_header_html(text)
		element_number = if text.scan(/^####/).length == 1; 4;
		elsif text.scan(/^###/).length == 1; 3;
		elsif text.scan(/^##/).length == 1; 2;
		elsif text.scan(/^#/).length == 1; 1;
		end
		element = "h#{element_number}"
		header_md = '#' * element_number
		class_attr = text.scan(/^#{header_md}\.(\w+)/)
		class_name = if class_attr.empty? 
				{}
			else 
				class_attr = class_attr[0][0]
				text.gsub!(('.' + class_attr.to_s),'')
				{ class: class_attr.to_s }
			end
		plain_text = text[element_number..-1].strip
		# "<#{element}#{class_name}>#{plain_text}</#{element}>"
		wrap_html({text: plain_text}, element, class_name)
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

	def sp_wrapper(obj)
		# "\"#{obj}\""
		'"' + obj + '"'
	end

	def wrap_html(obj, element_name, attrs)
		text = obj[:text]
		element_attrs = ''
		element_attrs += ' id=' + sp_wrapper(attrs[:id]) if attrs[:id]
		element_attrs += ' class=' + sp_wrapper(attrs[:class]) if attrs[:class]
		element_attrs += ' href=' + sp_wrapper(attrs[:href]) if attrs[:href]
		element_attrs += ' href=' + sp_wrapper(attrs['href'])  if attrs['href']
		element_attrs += ' lang=' + sp_wrapper(attrs[:lang]) if attrs[:lang]
		element_attrs += ' role=' + sp_wrapper(attrs[:role]) if attrs[:role]
		element_attrs += ' title=' + sp_wrapper(attrs[:title]) if attrs[:title]
		if text.include?(NEW_LINE)
			text.split().collect do |element_text|	

				"<#{element_name }#{element_attrs}>#{element_text}</#{element_name}>"
			end.join
		else
			"<#{element_name}#{element_attrs}>#{text}</#{element_name}>"
		end
	end
end

def parse_markdown(markdown, objects)
	HyperTextFromMarkdownParser.new(markdown, objects).results
end
