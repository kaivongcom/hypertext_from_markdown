require "test/unit"
require_relative "../hypertext_from_markdown"

class TestHyperTextFromMarkdown < Test::Unit::TestCase
	def assert_equal_of_parser(original, html, wrapper_element=true, attr_class=false, attr_id=false, link_title=false)
		attrs = { "element_name" => wrapper_element, "class" => attr_class, "link_title" => link_title, "id" => attr_id }
		actual_expected, expected = HyperTextFromMarkdown.new(original, attrs).results, html
		assert_equal(expected, actual_expected)
	end

	def test_markdown_from_a_MARKUP # image markup to markdown
		markdown = "![alt text here](/example/picture.jpg^100x120 #example-id)"
		html_image = '<img alt="alt text here" height="120" id="example-id" src="/example/picture.jpg" width="100">'
		test_markdown_parser = HyperTextFromMarkdown.new(html_image, { 'html_img' => true }).results
		assert_equal(markdown,test_markdown_parser)
	end

	def test_for_lists
		actual = "* example item in list"
		assert_equal_of_parser(actual, '<li>example item in list</li>')
	end

	def test_for_lists_with_additional_html # find some kind of err ... from ascii or otherwise? eg. * Dressipi <small>&#x28;https://www.dressipi.com&#x29;</small>
		actual = "* example item <small>in list</small>"
		assert_equal_of_parser(actual, '<li>example item <small>in list</small></li>')
	end

	def test_for_anchor_link_text
		actual_expected = "[home page](/example)"
		assert_equal_of_parser(actual_expected, '<a href="/example">home page</a>', false)
	end

	def test_for_anchor_link_text_with_extra_grammar
		actual_expected = "[home page](/example) from (that homepage)"
		assert_equal_of_parser(actual_expected, '<a href="/example">home page</a> from (that homepage)', false)
	end

	def test_strange_parsing_in_menubar
		actual_expected = '<td class=\"#{text}\">#{text_link}</td>'
		assert_equal_of_parser(actual_expected, '<td class=\"#{text}\">#{text_link}</td>', false) # actually testing unparsed ERB.HTML
	end

	def test_markdown_link_with_icon_link
		actual_expected = "[!iconLink](#example)"
		html_link = '<a href="#example"><i class="bi bi-link-45deg" title="icon link"></i> <span class="link-text">(link)</span></a>'
		assert_equal_of_parser(actual_expected, html_link, false)
	end


	def test_for_anchor_link_text_within_text
		test = { markdown: 'Link to [Google](http://google.com)', html: 'Link to <a href="http://google.com">Google</a>' }
		assert_equal_of_parser(test[:markdown], test[:html], false)
	end

	def test_for_anchor_link_attrs
		test = { html: '<a href="http://google.com">Google</a>'}
		test_markdown = HyperTextFromMarkdown.new('Google', { 'element_name' => 'a', 'href' => 'http://google.com' }).results
		assert_equal(test_markdown, test[:html])
	end

	def test_for_anchor_link_text_wrapped
		markdown = "[home page](/example) "
		markdown = HyperTextFromMarkdown.new(markdown).results
		assert_equal(markdown, '<p><a href="/example">home page</a> </p>')
	end

	def test_for_attrs_with_img
		md = "![pop tarts](/images/notes/square/20.png),  { element_name: 'a', link_title: 'computer game shop', href: 'https://kaivong.com' }"

	end

	def test_complex_link
		md = "[CSS prefers-reduced-data media-query](https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data ""Media Queries Level 5 Editor’s Draft, 21 November 2020"")"
		act = '<a href="https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data" title="Media Queries Level 5 Editor’s Draft, 21 November 2020">CSS prefers-reduced-data media-query</a>'
		assert_equal_of_parser(md, act, false)
	end

	# def test_complex_link2
	# 	md = "[Intel Extreme Masters (IEM)](https://twitter.com/search?q=Intel%20Extreme%20Masters%20IEM 'external')"
	# 	act = '<a class="external" href="https://twitter.com/search?q=Intel%20Extreme%20Masters%20IEM">Intel Extreme Masters (IEM)</a>'
	# 	assert_equal_of_parser(md, act, false)
	# end

	def test_emphesis
		markdown = "*browsing* right now"
		expected = '<em>browsing</em> right now'
		assert_equal_of_parser(markdown, expected, false)
	end

	def test_for_emphasis_text
		test = { md: 'This text is *emphasised*.', html: 'This text is <em>emphasised</em>.' }
		assert_equal_of_parser(test[:md], test[:html], false)
	end

	def test_emoji_class_name_1
	 	md = "[🦔](# ""emoji"")"
	 	actual_expected = '<span><a href="#" title="emoji">🦔</a></span>'
	 	assert_equal_of_parser(md, actual_expected, 'span', 'emoji')
	 end

	def test_emoji_class_name
	 	md = "[🦔](# has title)"
	 	actual_expected = '<a href="#" title="has title">🦔</a>'
	 	assert_equal_of_parser(md, actual_expected, false, 'emoji')
	 end

	def test_for_external_links
		actual_expected = "[home page](http://example.com/pages/index.html external)"
		assert_equal_of_parser(actual_expected, '<a class="external" href="http://example.com/pages/index.html" title="external">home page</a> (http://example.com)', false)
	end

	def test_for_empty_space
		tests = { actual_expected: ' ', expected: '' }
		assert_equal_of_parser(tests[:actual_expected], tests[:expected] )
	end

	def test_for_h2_plus_class
		original = 'A Second Level Header'
		attrs = { 'attr_class' => 'warning', 'element_name' => 'h2' }
		markdown_parsed = HyperTextFromMarkdown.new(original, attrs).results
		expected = '<h2 class="warning">A Second Level Header</h2>'
		assert_equal_of_parser(markdown_parsed, expected, false)
	end

	def test_for_h1_long_parse
		assert_equal_of_parser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_complex_string_with_inline_html
		inline_html = 'My Chinese name is, <strong lang="zh_CN" title="Chinese">黃振佳</strong>. I''m the mix of British-Chinese (see <a href="/about/contact/digital-identity">digital-identity</a> for more).'
		html = '<p>' + inline_html + '</p>'
		assert_equal_of_parser(inline_html, html)
	end

	def test_strong_with_attrs
		actual = 'My Chinese name is, **^zh_CN^Chinese^黃振佳**.'
		expected = '<p>My Chinese name is, <strong lang="zh_CN" title="Chinese">黃振佳</strong>.</p>'
		assert_equal_of_parser(actual, expected)
	end

	def test_for_h1_wrapped
		assert_equal_of_parser("# A First Level Header", '<h1>A First Level Header</h1>', true)
	end


	def test_for_h4_class_name
		markdown =  HyperTextFromMarkdown.new("####.tidy a title").results
		output_html_desired = '<h4 class="tidy">a title</h4>'	
		assert_equal(output_html_desired, markdown)
	end

	def test_for_plain_text_unescaped
		markdown = "example text line for unstyled"
		expected = "example text line for unstyled"
		assert_equal_of_parser(markdown, expected, false)
	end

	def test_for_paragraph_text_without_element
		paragraph = "example text line for unstyled"
		markdown = HyperTextFromMarkdown.new(paragraph).results
		assert_equal_of_parser(markdown, "<p>example text line for unstyled</p>")
	end

	def test_for_h1
		tests = { actual_expected: '# A First Level Header', expected: '<h1>A First Level Header</h1>' }
		assert_equal_of_parser(tests[:actual_expected], tests[:expected] )
	end

	def test_for_h1_hashtag
		markdown = '# Header and the #Hashtag'
		expected = '<h1>Header and the #Hashtag</h1>'
		markdown = HyperTextFromMarkdown.new(markdown).results
		assert_equal(expected, markdown)
	end

	def test_for_h2
		assert_equal_of_parser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_for_h2_without_class
		original = '## A Second Level Header'
		expected = '<h2>A Second Level Header</h2>'
		attrs = { attr_class: 'warning'}
		assert_equal_of_parser(original, expected, true, attrs[:attr_class])
	end

	def test_img_html_basic
		markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg #games-shop)'
		markdown = HyperTextFromMarkdown.new(markdown_image).results
		actual_expected = '<img alt="computer game shop" id="games-shop" loading="eager" src="http://www.kaivong.com/images/square/515.jpg">'
		assert_equal(actual_expected, markdown)
	end

	def test_img_html_with_dimension_is_landscape
		markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg^400x200 #games-shop)'
		markdown = HyperTextFromMarkdown.new(markdown_image).results
		actual_expected = '<img alt="computer game shop" height="200" id="games-shop" loading="eager" src="http://www.kaivong.com/images/square/515.jpg" width="400">'
		assert_equal(actual_expected, markdown)
	end

	def test_img_html_with_dimension_is_portrait
		markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg^200x400 #games-shop)'
		markdown = HyperTextFromMarkdown.new(markdown_image).results
		actual_expected = '<img alt="computer game shop" height="400" id="games-shop" loading="eager" src="http://www.kaivong.com/images/square/515.jpg" width="200">'
		assert_equal(actual_expected, markdown)
	end

	def test_img_html_with_attrs
		markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg #games-shop)'
		attrs = {element_name: false, 'attr_id' => 'games-shop', link_title: 'computer game shop'} # alt
		markdown = HyperTextFromMarkdown.new(markdown_image, attrs).results
		actual_expected = '<img alt="computer game shop" id="games-shop" loading="eager" src="http://www.kaivong.com/images/square/515.jpg">'
		assert_equal(actual_expected, markdown)
	end

	def test_to_links_with_tag_element
		wrapper_element = 'p'
		markdown = "[example page](/example With a Title)"
		expected = '<p><a href="/example" title="With a Title">example page</a></p>'
		assert_equal_of_parser(markdown, expected, wrapper_element)
	end

	def test_to_links_with_title
		markdown = "[example page](/example ""With a Title"")"
		expected = '<a href="/example" title="With a Title">example page</a>'
		assert_equal_of_parser(markdown, expected, false)
	end

	def test_for_paragraph_text
		paragraph = "example text line for unstyled\n"
		assert_equal_of_parser(paragraph, "<p>example text line for unstyled</p>")
	end

	def test_for_table
		markdown = ' '
		expected = '<table summary=""> </table>'
		html = HyperTextFromMarkdown.new(markdown, {'element_name' => 'table', 'summary' => '' }).results
		assert_equal(expected, html )
	end

	def test_for_tables_header
		original = '| # | name1 | name2 | name3 |'
		expected = '<table summary=""><thead><tr><td>name1</td><td>name2</td><td>name3</td></tr></thead>' # expects more tr to follow
		attrs = { element_name: false, attr_class: '' }
		assert_equal_of_parser(original, expected, attrs[:element_name])
	end

	def test_for_table_row
		original = '| ## | bill | bob | jess |'
		expected = '<tr><td>bill</td><td>bob</td><td>jess</td></tr>'
		attrs = { 'element_name' => false }
		html = HyperTextFromMarkdown.new(original, attrs).results
		assert_equal(html, expected)
	end

	def test_for_table_row_id
		original = '| ## | bill | bob | jess |'
		actual_expected = '<tr id="people"><td>bill</td><td>bob</td><td>jess</td></tr>'
		attrs = { 'element_name' => false, 'attr_id' => 'people' }
		markdown = HyperTextFromMarkdown.new(original, attrs).results
		assert_equal(markdown, actual_expected)
	end

	def test_for_table_wrapper # TODO: test with formatting
		fragment_of_html = '<td class=name-1>bill</td><td class=name-2>bob</td><td class=name-3>jess</td>'
		actual_expected = "<tr role=\"names\"><td class=name-1>bill</td><td class=name-2>bob</td><td class=name-3>jess</td></tr>"
		html = HyperTextFromMarkdown.new(fragment_of_html, { 'element_name' => 'tr', 'role' => "names" }).results
		assert_equal(html, actual_expected)
	end

	def test_for_table_row_class_and_id
		original = '| ## | bill | bob | jess |'
		actual_expected = '<tr id="footballers" class="players"><td>bill</td><td>bob</td><td>jess</td></tr>'
		attrs = { 'element_name' => false, 'attr_id' => 'footballers', 'attr_class' => 'players' }
		markdown = HyperTextFromMarkdown.new(original, attrs).results
		assert_equal(markdown, actual_expected)
	end

	def test_text_left_side_to_short_link_in_paragraph
		markdown = "This is an [example link](/example/ ""With a Title"")."
		expected = '<p>This is an <a href="/example/" title="With a Title">example link</a>.</p>'
		assert_equal_of_parser(markdown, expected)
	end

	def test_text_left_side_to_http_link_in_paragraph
		markdown = "This is an [example link](http://example.com/ ""With a Title"")."
		expected = '<p>This is an <a href="http://example.com/" title="With a Title">example link</a>.</p>'
		assert_equal_of_parser(markdown, expected)
	end

	def test_text_right_side_to_short_link_in_paragraph
		markdown = "[example link](/example/ ""With a Title"") for that."
		expected = '<p><a href="/example/" title="With a Title">example link</a> for that.</p>'
		assert_equal_of_parser(markdown, expected)
	end

	def test_label_element
		md = "here is a label"
		md_parsed = HyperTextFromMarkdown.new(md, 'label' ).results
		html = '<label>here is a label</label>'
		assert_equal(md_parsed, html)
	end


	def test_abbrev_and_link_paragraph
		markdown = "<abbrev title=world wrestling entertainment ... federation?>WWE</abbrev> [example link](/example/ ""With a Title"") for that."
		expected = '<p><abbrev title=world wrestling entertainment ... federation?>WWE</abbrev> <a href="/example/" title="With a Title">example link</a> for that.</p>'
		assert_equal_of_parser(markdown, expected)
	end
	
	def test_strong_element
		md = "here is **bold or strong text**"
		html = '<p>here is <strong>bold or strong text</strong></p>'
		assert_equal_of_parser(md, html)
	end

	def test_wrapped_in_text_link_paragraph
		md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
		actual_expected = '<p>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</p>'
		assert_equal_of_parser(md, actual_expected)
	end

	def test_wrapper_p2
		md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
		html = '<strong>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</strong>'
		assert_equal_of_parser(md, html, 'strong')
	end
end
