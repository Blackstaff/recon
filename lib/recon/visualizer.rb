require 'gruff'
require 'ruby-graphviz'

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

  def self.make_bar_chart(title, data)
    chart = Gruff::Bar.new
    chart.minimum_value = 0
    chart.maximum_value = data.first[:value]
    chart.title = title.to_s
    data.each do |item|
      chart.data(item[:label], item[:value])
    end

    chart.to_blob
  end

  def self.make_dependency_diagram(classes)
    diagram = GraphViz.new(:G, :type => :digraph)
    nodes = classes.map { |c| diagram.add_nodes(c.name) }
    classes.each do |klass|
      classes.each do |other_klass|
        if !klass.dependencies.index {|d| d == other_klass.name }.nil?
          node, other_node = [klass, other_klass].map {|k| nodes.find {|n| n[:label].to_s.gsub('"', '') == k.name}}
          diagram.add_edges(node, other_node)
        end
      end
    end
    diagram.output(:png => String)
  end
end
