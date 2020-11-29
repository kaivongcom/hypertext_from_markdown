require "test/unit"
require_relative "../mymarkdown_to_hypertext"

class TestMyMarkdownToHypertextParser < Test::Unit::TestCase

	def actual_expected(original, html)
		actual, expected = MyMarkdownToHypertextParser.new(original).results, html
		assert_equal(expected, actual)
	end

	def test_to_html_for_h1
		actual_expected('# A First Level Header', '<h1>A First Level Header</h1>')
	end

	def test_to_html_for_h2
		actual_expected('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_to_html_for_h1_long_parse
		actual_expected("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_to_html_for_p_singleline
		paragraph = "The quick brown fox jumped over the lazy dog's back.\n"
		actual_expected(paragraph, "<p>The quick brown fox jumped over the lazy dog's back.</p>")
	end

	def test_to_html_for_p
		paragraph = "Now is the time for all good men to come to the aid of their country. This is just a regular paragraph.\n The quick brown fox jumped over the lazy dog's back.\n"
		actual_expected(paragraph, "<p>Now is the time for all good men to come to the aid of their country. This is just a regular paragraph.</p><p> The quick brown fox jumped over the lazy dog's back.</p>")
	end

	def test_to_links_only
		markdown = "[example link](/example/ 'With a Title')"
		expected = "<a href='/example/' title=\"With a Title\">example link</a>"
		actual_expected(markdown, expected)
	end

	def test_to_links_short
		markdown = "This is an [example link](/example/ 'With a Title')."
		expected = "<p>This is an <a href='/example/' title=\"With a Title\">example link</a>.</p>"
		actual_expected(markdown, expected)
	end

	def test_to_links_full
		markdown = "This is an [example link](http://example.com/ \"With a Title\")."
		expected = "<p>This is an <a href='http://example.com/' title=\"With a Title\">example link</a>.</p>"
		actual_expected(markdown, expected)
	end

end

