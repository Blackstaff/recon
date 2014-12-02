require 'gruff'

class Visualizer
  def self.make_class_pie_chart(classes)
    chart = Gruff::Pie.new
    chart.title = "Lines of code"
    sorted_classes = classes.sort
    sorted_classes.last(4).each do |klass|
      chart.data(klass.name, klass.lines)
      sorted_classes.delete(klass)
    end

    chart.data("other", sorted_classes.map {|k| k.lines}.inject(:+))

    chart.to_blob
  end

  def self.make_method_pie_chart
  end

  def self.make_dependency_diagram
  end
end
