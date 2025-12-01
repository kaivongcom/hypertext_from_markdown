require 'uri'
require_relative '../helpers/hyper-text-helpers.rb'
class HyperTextFromMarkdown < Object
	attr_reader :results

	def initialize(markdown_text, attrs_hash={})
		attrs_hash = (attr_element_name = attrs_hash; { 'html_element' => attr_element_name } ) if String == attrs_hash.class
		if attrs_hash['html_img']
			@results = markdown_from_markup(markdown_text, attrs_hash)
		else
			@attrs = make_attrs(attrs_hash)
			@markdown_text = markdown_text.chomp
			element_name = @attrs[:element_name]
			element_name = find_element(element_name, @markdown_text) if element_name == nil
			length = @markdown_text.scan(/\n/).count
			markdown_searches(markdown_text)
			markdown_obj = { text: @markdown_text, length: length }
			@results = wrap_markdown(element_name, markdown_obj, @attrs)
		end
	end

	def make_attrs(attrs, table_row=false)
		element_name = table_row if table_row != false
		if table_row != false			
			{ 'attr_class' => attrs[:class],
		      'attr_id' => attrs[:id],
		      'element_name' => table_row,
		      'role' => attrs[:role],
		      'summary' => attrs[:summary],
		      'user_resource_loc' => attrs[:user_resource_loc],
		      'border' => attrs[:border] }
		else
			element_name = attrs['element_name'] || attrs['html_element']
			{ :class => attrs['attr_class'],
			   :user_resource_loc => attrs['user_resource_loc'],
			   :element_name => element_name,
			   :href => attrs['href'],
			   :id => attrs['attr_id'],
			   :role => attrs['role'],
			   :summary => attrs['summary'],
			   :border => attrs['border'],
			   :title => attrs['link_title'] }
		end
	end

	def markdown_from_markup(text, attrs)
		element, alt, height_key, height, id_key, id, src_key, src, width_key, width = text.split('"')
		"![#{alt}](#{ src + '^' + width + 'x' + height + ' #' + id })" # html img from markdown ![alt-text](src ^args)
	end

	def call
		self.results
	end

	def markdown_searches(md)
		find_bold(md)
		find_emphasis(md)
		find_html_img(md); link_scan(md); find_list(md);
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
		@attrs[:element_name] = HTML_LIST_ITEM 
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
		attributes = make_attrs(@attrs, HTML_TABLE_ROW)
		table_wrapper = (arr.shift == ' # ') ?  HTML_TABLE_HEADER : false
		td_items = (arr.compact.collect { |item| parse_markdown(item.strip, HTML_TABLE_DATA) }.join)
		html = table_row = parse_markdown(td_items, attributes)
		if @attrs['element_name'] == HTML_TABLE || table_wrapper
			table_head = parse_markdown(table_row, { 'element_name' => HTML_TABLE_HEADER })
			html = parse_markdown(table_head, { 'element_name' => HTML_TABLE, 'summary' => '' })
			html = html.gsub(END_TABLE,'')
		end
		@markdown_text.gsub!(markdown, html)
	end

	def strong_html(strong_matches, attrs={})
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
		attrs[:href] = @attrs[:user_resource_loc] + attrs[:href] if @attrs[:user_resource_loc] != nil
		attrs
	end

	def link_scan(markdown_text)
		# potential_link = if markdown_text.include?(')](')
		# 	markdown_text.split(')](')[1][0..-2]
		# end
		if markdown_text.include?('[') &&  markdown_text.include?(')') && 
			if digits_kept = markdown_text.match(/[\d]{1,4}/) && markdown_text.include?(')]')
				markdown_text.gsub!("(#{digits_kept})",'')
				link_matches = markdown_text.match(/\[(.*)\]\((.*)\)/)
			else
				potential_link = markdown_text.split(")")[0]
				potential_link = potential_link ? potential_link + ')' : markdown_text
				link_matches = potential_link.match(/\[(.*)\]\((.*)\)/)
			end
			if @element_name == 'a'
# 				@attrs[:href] = @attrs[:user_resource_loc] + @attrs[:href] if (@attrs[:user_resource_loc])
				link_matches = { link_tag_name: @attrs[:element_name], href: @attrs[:href] }
			end
			link_html(markdown_text, link_matches) if link_matches
		end
	end

	def link_html(text, match_data)
		html_text, html_link = text.split(']')
		html_text.gsub!('[','')
		potential_link = text.split(")")[0]
		potential_link = potential_link ? potential_link + ')' : text
		full_link = potential_link.match(/\[(.*)\)/)[0]
		attrs, element_attrs, text = split_title_arr(match_data),{},match_data[1]
		external_domain = attrs[:domain] ? (' (' + attrs[:domain].gsub('https://','') + ')') : ''
		if text.include?('!iconLink')
			icon_link = "<span class=\"link-text\">(link)</span>"
			text = icon_link_text = "<i class=\"bi bi-link-45deg\" title=\"icon link\"></i> #{icon_link}"
		end
		link_text = wrap_html({text: text}, 'a', attrs) + external_domain
		@markdown_text.gsub!(full_link, link_text)
		@markdown_text.gsub!('](/notes/)','') if @markdown_text.include?('/notes/')
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
		['id', 'class', 'href', 'lang', 'role', 'summary', 'border', 'title'].each do |attr|
			element_attrs += " #{attr}=" + sp_wrapper(attrs[attr.to_sym]) if attrs[attr.to_sym]
		end
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
	HyperTextFromMarkdown.new(markdown, objects).results
end
