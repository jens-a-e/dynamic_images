Gem::Specification.new do |s|
	s.name     = "dynamic_images"
	s.version  = "1.0.1"
	s.summary  = "Ruby library providing image rendering described by dynamic templates"
    s.email    = "dominik.malis@gmail.com"
	s.homepage = "http://github.com/malis/dynamic_images"
	s.authors  = ["Dominik Malis","jens alexander ewald"]
	s.has_rdoc = true

	s.files = [
		"README.rdoc",
		"README_USAGE.rdoc",
		"Rakefile",
		"examples/gtk_window.rb",
		"examples/named_colors_table.rb",
		"init.rb",
		"lib/dynamic_image.rb",
		"lib/elements/block_element.rb",
		"lib/elements/element_interface.rb",
		"lib/elements/image_element.rb",
		"lib/elements/table_cell_element.rb",
		"lib/elements/table_element.rb",
		"lib/elements/text_element.rb",
		"lib/parsers/xml.dtd",
		"lib/parsers/xml_parser.rb",
		"lib/render_image.rb",
		"lib/sources/color_source.rb",
		"lib/sources/gradient_source.rb",
		"lib/sources/source_factory.rb"
	]
end