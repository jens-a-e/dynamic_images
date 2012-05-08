require File.dirname(__FILE__) + '/../sources/source_factory.rb'

# Module keeps all elements that can be placed into composition of canvas.
module DynamicImageElements
  # Interface providing default methods for all elements in composite. Also contain some private methods which helps element to process common tasks.
  module ElementInterface
    # Gives array that contains size of dimensions provided for inner elements.
    # It's calculated as #element_size - <i>padding</i>
    def inner_size
      raise Exception.new "not implemented in #{self.class}, but should be"
    end
    def draw!(x, y) #:nodoc:
      raise Exception.new "not implemented in #{self.class}, but should be"
    end

    # Gets original Cairo::ImageSurface object if width and height was given in options or it's created from existing source.
    def surface
      @parent.surface
    end

    # Gets original Cairo::Context of Cairo::ImageSurface object if width and height was given in options or it's created from existing source.
    def context
      @parent.context
    end

    # Gives array that contains real size of element.
    def element_size
      w, h = inner_size
      if @padding
        w += @padding[1] + @padding[3]
        h += @padding[0] + @padding[2]
      end
      [w, h]
    end

    # Gives array that contains size of space occupied of element.
    # It's calculated as #element_size + <i>margin</i>
    def final_size
      w, h = element_size
      if @margin
        w += @margin[1] + @margin[3]
        h += @margin[0] + @margin[2]
      end
      [w, h]
    end

    # Changes element's width option
    def set_width(width, inner = true) #:nodoc:
      if width.nil?
        @options[:width] = nil
      elsif width > 0
        unless inner
          width -= @padding[1] + @padding[3] if @padding
          width -= @margin[1] + @margin[3] if @margin
        end
        @options[:width] = width < 0 ? 0 : width
        @size = nil #nullify any precalculated size
        @elements.each {|e| e[:obj].recalculate_size! } if @elements #propagate size change to inner elements if there is any
      end
    end
    # Changes element's height option
    def set_height(height, inner = true) #:nodoc:
      if height.nil?
        @options[:height] = nil
      elsif height > 0
        unless inner
          height -= @padding[0] + @padding[2] if @padding
          height -= @margin[0] + @margin[2] if @margin
        end
        @options[:height] = height < 0 ? 0 : height
        @size = nil #nullify any precalculated size
        @elements.each {|e| e[:obj].recalculate_size! } if @elements #propagate size change to inner elements if there is any
      end
    end
    # Clears cached size to force recalculating
    def recalculate_size! #:nodoc:
      @size = nil #nullify any precalculated size
    end


    private
    # Processes a given block. Yields objects if the block expects any arguments.
    # Otherwise evaluates the block in the context of first object.
    def process(*objects, &block)
      if block.arity > 0
        yield *objects
      else
        objects.first.instance_eval &block
      end
    end

    # Parse common options from @options Hash by metakey
    def use_options(metakey)
      if metakey == :margin || metakey == :padding
        value = [0, 0, 0, 0]
        if @options[metakey].class == Array
          value = (@options[metakey].map(&:to_i)*4)[0..3]
        else
          value = (@options[metakey].to_s.scan(/\-?\d+/).flatten.map(&:to_i)*4)[0..3] if @options[metakey] && @options[metakey].to_s =~ /\d/
        end
        [:top, :right, :bottom, :left].each_with_index {|side, index| value[index] = @options["#{metakey}_#{side}".to_sym].to_i if @options["#{metakey}_#{side}".to_sym] }
        instance_variable_set "@#{metakey}", value
      end
    end

    # Calculates real position for drawing element by adding margin and x, y if positioning is relative.
    def recalculate_positions_for_draw(x, y)
      if @margin
        x += @margin[3]
        y += @margin[0]
      end
      if @options[:position].to_sym == :relative
        x += @options[:x].to_i
        y += @options[:y].to_i
      end
      [x, y]
    end

    # Aliases for option's keys. You can use these shortcuts:
    # * :w to specify :width
    # * :h to specify :height
    # * :bg to specify :background
    # * :valign to specify :vertical_align
    OPTIONS_ALIASES = {:w => :width, :h => :height, :bg => :background, :valign => :vertical_align}

    # Treats options Hash to generalize it and preparse sources
    def treat_options(options)
      #convert all keys to symbols
      options.keys.each do |key|
        next if key.class == Symbol
        options[key.to_s.gsub("-", "_").downcase.to_sym] = options[key]
      end
      #use aliases
      OPTIONS_ALIASES.each do |alias_key, key|
        next unless options[alias_key]
        options[key] = options[alias_key]
      end
      #check values that must be numeric
      [:x, :y, :z, :cols, :colspan, :rowspan].each do |key|
        options[key] = options[key].to_i if options[key]
      end
      #check values that must be numeric, but can be in percentage
      [:width, :height].each do |key|
        next unless options[key]
        if options[key] =~ /%$/
          options[key] = options[key].to_f/100.0
        else
          options[key] = options[key].to_i
        end
      end
      options[:width] = nil if options[:width] && options[:width] <= 0
      options[:height] = nil if options[:height] && options[:height] <= 0
      options[:position] = :static unless options[:position]
      options[:background] = DynamicImageSources::SourceFactory.parse options[:background] unless options[:background].to_s.empty?
      options[:color] = DynamicImageSources::SourceFactory.parse options[:color] unless options[:color].to_s.empty?
    end

    #drawing helpers
    def draw_background(x, y)
      if @options[:background]
        context.save
        @options[:background].set_source context
        w, h = element_size
        context.rectangle x, y, w, h
        context.clip
        context.paint
        context.restore
      end
    end
    def draw_border(x, y)
      #TODO
    end
  end
end
