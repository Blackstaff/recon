require 'gruff'
require 'ruby-graphviz'

class Visualizer
  def self.make_class_pie_chart(classes)
    chart = Gruff::Pie.new
    chart.title = "Lines of code"
    sorted_classes = classes.sort.reverse
    sorted_classes.first(4).each do |klass|
      chart.data(klass.name, klass.lines)
      sorted_classes.delete(klass)
    end

    chart.data("other", sorted_classes.map {|k| k.lines}.inject(:+))

    chart.to_blob
  end

  def self.make_method_pie_chart
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
