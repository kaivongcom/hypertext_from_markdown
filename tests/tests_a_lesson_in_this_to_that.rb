require "test/unit"
require_relative "../mymarkdown_to_hypertext"

class TestMyMarkdownToHypertextParser < Test::Unit::TestCase

	def assert_equal_of_MyMarkdownToHypertextParser(original, html, wrapper_element=true, attr_class=false)
		actual, expected = MyMarkdownToHypertextParser.new(original, wrapper_element, attr_class).results, html
		# actual, expected = MyMarkdownToHypertextParser.new(original, wrapper_element).results, html
		assert_equal(expected, actual)
	end

	def test_for_h1
		assert_equal_of_MyMarkdownToHypertextParser('# A First Level Header', '<h1>A First Level Header</h1>')
	end

	def test_for_h2
		assert_equal_of_MyMarkdownToHypertextParser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_for_h1_long_parse
		assert_equal_of_MyMarkdownToHypertextParser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_for_paragraph
		paragraph = "example text line for unstyled\n"
		assert_equal_of_MyMarkdownToHypertextParser(paragraph, "<p>example text line for unstyled</p>")
	end

	def test_to_only_text
		markdown = "example text line for unstyled"
		expected = "example text line for unstyled"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected, false)
	end

	def test_to_only_links
		markdown = "[example link](/example/ 'With a Title')"
		expected = "<a href='/example/' title=\"With a Title\">example link</a>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected, false)
	end

	def test_text_left_side_to_short_link_in_paragraph
		markdown = "This is an [example link](/example/ 'With a Title')."
		expected = "<p>This is an <a href='/example/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_text_left_side_to_http_link_in_paragraph
		markdown = "This is an [example link](http://example.com/ \"With a Title\")."
		expected = "<p>This is an <a href='http://example.com/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_text_right_side_to_short_link_in_paragraph
		markdown = "[example link](/example/ 'With a Title') for that."
		expected = "<p><a href='/example/' title=\"With a Title\">example link</a> for that.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_wrapped_in_text_link_paragraph
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		actual = "<p>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual)
	end

	def test_class_name_paragraph
		actual = "<p class=\"new-class\">here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'p', 'new-class')
	end

	def test_emoji_class_name
		actual = "<span class=\"emoji\"><a href='#' title=\"emoji\">🦔</a></span>"
		md = "[🦔](# \"emoji\")"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'span', 'emoji')
	end

	def test_wrapper_p2
		actual = "<strong>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</strong>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'strong')
	end

	def test_complex_link
		act = "<a href='https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data' title=\"Media Queries Level 5 Editor’s Draft, 21 November 2020\">CSS prefers-reduced-data media-query</a>"
		md = "[CSS prefers-reduced-data media-query](https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data 'Media Queries Level 5 Editor’s Draft, 21 November 2020')"
		assert_equal_of_MyMarkdownToHypertextParser(md, act, false)
	end

end
