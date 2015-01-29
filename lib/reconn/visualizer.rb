require 'gruff'
require 'ruby-graphviz'

module Reconn
  class Visualizer
    def self.make_pie_chart(title, data, items_number)
      chart = Gruff::Pie.new
      chart.title = title.to_s
      data = Array.new(data)
      data.first(items_number).each do |item|
        chart.data(item[:label], item[:value])
        data.delete(item)
      end

      chart.data("other", data.map {|itm| itm[:value]}.inject(:+))

      chart.to_blob
    end

    def self.make_bar_chart(title, data, additional_line_value = nil)
      chart = Gruff::Bar.new
      chart.minimum_value = 0
      chart.maximum_value = data.first[:value]
      chart.additional_line_values = [additional_line_value] unless additional_line_value.nil?
      chart.title = title.to_s
      data.each do |item|
        chart.data(item[:label], item[:value])
      end

      chart.to_blob
    end

    def self.make_dependency_diagram(classes)
      diagram = GraphViz.new(:G, :type => :digraph)
      nodes = classes.map { |c| diagram.add_nodes(c.name) }
      external_nodes = classes.map {|c| c.external_deps}.inject(:+).uniq.map {|n| diagram.add_nodes(n)}
      classes.each do |klass|
        classes.each do |other_klass|
          if !klass.dependencies.index {|d| d == other_klass.name }.nil? || klass.dependencies.find_all {|d| other_klass.name =~ /^.*{0,}::#{d}$/}.size == 1
            node, other_node = [klass, other_klass].map {|k| nodes.find {|n| n[:label].to_s.gsub('"', '') == k.name}}
            diagram.add_edges(node, other_node)
          end
        end
        external_nodes.each {|n| n.set {|_n| _n.color = "blue"}}
        external_nodes.each do |ext_node|
          if klass.external_deps.include?(ext_node[:label].to_s.gsub('"', ''))
            node = nodes.find {|n| n[:label].to_s.gsub('"', '') == klass.name}
            diagram.add_edges(node, ext_node)
          end
        end
      end
      diagram.output(:png => String)
    end
  end
end

#Monkeypatching additional line drawing
module Gruff
  class Bar
    def draw
      @center_labels_over_point = (@labels.keys.length > @column_count ? true : false)
      super
      return unless @has_data

      draw_bars
      draw_additional_line
    end
    def draw_bars
      # Setup spacing.
      #
      # Columns sit side-by-side.
     @bar_spacing ||= @spacing_factor # space between the bars
      @bar_width = @graph_width / (@column_count * @data.length).to_f
      padding = (@bar_width * (1 - @bar_spacing)) / 2

      @d = @d.stroke_opacity 0.0

      # Setup the BarConversion Object
      conversion = Gruff::BarConversion.new()
      conversion.graph_height = @graph_height
      conversion.graph_top = @graph_top

      # Set up the right mode [1,2,3] see BarConversion for further explanation
      if @minimum_value >= 0 then
        # all bars go from zero to positiv
        conversion.mode = 1
      else
        # all bars go from 0 to negativ
        if @maximum_value <= 0 then
          conversion.mode = 2
        else
          # bars either go from zero to negativ or to positiv
          conversion.mode = 3
          conversion.spread = @spread
          conversion.minimum_value = @minimum_value
          conversion.zero = -@minimum_value/@spread
        end
      end

      # iterate over all normalised data
      @norm_data.each_with_index do |data_row, row_index|

        data_row[DATA_VALUES_INDEX].each_with_index do |data_point, point_index|
          # Use incremented x and scaled y
          # x
          left_x = @graph_left + (@bar_width * (row_index + point_index + ((@data.length - 1) * point_index))) + padding
          right_x = left_x + @bar_width * @bar_spacing
          # y
          conv = []
          conversion.get_left_y_right_y_scaled( data_point, conv )

          # create new bar
          @d = @d.fill data_row[DATA_COLOR_INDEX]
          @d = @d.rectangle(left_x, conv[0], right_x, conv[1])

          # Calculate center based on bar_width and current row
          label_center = @graph_left + 
                      (@data.length * @bar_width * point_index) + 
                      (@data.length * @bar_width / 2.0)

          # Subtract half a bar width to center left if requested
          draw_label(label_center - (@center_labels_over_point ? @bar_width / 2.0 : 0.0), point_index)
          if @show_labels_for_bar_values
            val = (@label_formatting || '%.2f') % @norm_data[row_index][3][point_index]
            draw_value_label(left_x + (right_x - left_x)/2, conv[0]-30, val.commify, true)
          end
        end
      end

      # Draw the last label if requested
      draw_label(@graph_right, @column_count) if @center_labels_over_point

      draw_additional_line
      @d.draw(@base_image)
    end
    # Draws additional horizontal line
    def draw_additional_line
       @additional_line_colors << '#f61100'
       @d = @d.stroke_opacity 100.0
       i = 0
       @additional_line_values.each do |value|
         @increment_scaled = @graph_height.to_f / (@maximum_value.to_f / value)

         y = @graph_top + @graph_height - @increment_scaled

         @d = @d.stroke(@additional_line_colors[i])
         @d = @d.line(@graph_left, y, @graph_right, y)


         @d.fill = @additional_line_colors[i]
         @d.font = @font if @font
         @d.stroke('transparent')
         @d.pointsize = scale_fontsize(@marker_font_size)
         @d.gravity = EastGravity
         @d = @d.annotate_scaled( @base_image,
                                 @graph_right - LABEL_MARGIN, 1.0,
                                 0.0, y - (@marker_font_size/2.0),
                                 label(value, value), @scale)
         i += 1
       end

      @d = @d.stroke_antialias true
    end
  end
end
