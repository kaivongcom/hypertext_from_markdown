!# /usr/bin/ruby
require_relative "./libs/hypertext_from_markdown.rb"

class FromMarkDown

	def initialize()
		@options = ARGV[0]
	end

	def results
		f_input = File.open(@options).read
		f_output = File.open(@options.gsub('.md','.html'),'w+')
		f_input.split("\n").each do |line|
			line.gsub!('(','(http://') if line.include?('.com')
			f_output << HyperTextFromMarkdown.new(line).results
		end
	end
end

