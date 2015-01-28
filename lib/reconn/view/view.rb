require_relative '../analyzer.rb'
require_relative '../visualizer.rb'

class View

	include GladeGUI

	def before_show()
    dialog_response, dialog = show_file_chooser_dialog
    if dialog_response == Gtk::Dialog::RESPONSE_ACCEPT
      analyzer = Analyzer::Analyzer.new
      @classes, @methods, @smells = analyzer.analyze(dialog.filename)

      @general_stats_view = build_general_stats_view
      @builder['dataviewport'].add(@general_stats_view)
    end
    dialog.destroy
	end

#########################################
  # On button clicked methods

	def on_general_stats_button_clicked
    clean_data_view

    unless @general_stats_view
      @general_stats_view = build_general_stats_view
    end

    @builder['dataviewport'].add(@general_stats_view)
	end

  def on_class_stats_button_clicked
    clean_data_view

    unless @class_stats_view
      @class_stats_view = build_class_stats_view
    end

    @builder['dataviewport'].add(@class_stats_view)
  end

  def on_class_diag_button_clicked
    clean_data_view

    unless @class_diag_view
      @class_diag_view = build_class_diag_view
    end

    @builder['dataviewport'].add(@class_diag_view)
  end

  def on_class_dep_button_clicked
    clean_data_view

    unless @class_dep_view
      @class_dep_view = build_class_dep_view
    end

    @builder['dataviewport'].add(@class_dep_view)
  end

  def on_method_stats_button_clicked
    clean_data_view

    unless @method_stats_view
      @method_stats_view = build_method_stats_view
    end

    @builder['dataviewport'].add(@method_stats_view)
  end

  def on_method_diag_button_clicked
    clean_data_view

    unless @method_diag_view
      @method_diag_view = build_method_diag_view
    end

    @builder['dataviewport'].add(@method_diag_view)
  end

  def on_if_smell_button_clicked
    clean_data_view

    unless @if_smell_view
      @if_smell_view = build_if_smell_view
    end

    @builder['dataviewport'].add(@if_smell_view)
  end

  def on_method_smell_button_clicked
    clean_data_view

    unless @method_smell_view
      @method_smell_view = build_method_smell_view
    end

    @builder['dataviewport'].add(@method_smell_view)
  end

###########################################
    # View builders

  def build_general_stats_view
    lines = 0
    @methods.each do |method|
      lines += method.lines
    end

    text_arr = ["Total number of classes: #{@classes.length} \n"]
    text_arr << "Total number of methods: #{@methods.length} \n"
    text_arr << "Total number of lines of code: #{lines} \n"

    largest_class = @classes.sort_by {|c| c.lines}.pop

    class_methodnum = Hash.new(0)
    @classes.each do |klass|
      class_methodnum.store(klass.name, klass.methods.size)
    end
    class_methodnum = class_methodnum.sort_by {|name, methods| methods}

    text_arr << "\n"
    text_arr << "Largest class: #{largest_class} \n"
    text_arr << "Number of lines: #{largest_class.lines} \n"
    text_arr << "\n"
    text_arr << "Class with largest number of methods: #{class_methodnum.last[0]} \n"
    text_arr << "Number of methods: #{class_methodnum.last[1]} \n"

    largest_method = @methods.sort_by {|m| m.lines}.pop
    text_arr << "\n"
    text_arr << "Largest method: #{largest_method} \n"
    text_arr << "Number of lines: #{largest_method.lines} \n"

    build_text_view(text_arr.join)
  end

  def build_class_stats_view
    features = [ {name: "Number of lines", data: prepare_data(@classes, :lines)} ]
    features << {name: "Cyclomatic complexity", data: prepare_data(@classes, :complexity)}
    features << {name: "Number of methods", data: prepare_data(@classes, :methods_number)}
    text = prepare_text(features)
    build_text_view(text)
  end

  def build_method_stats_view
    features = [ {name: "Number of lines", data: prepare_data(@methods, :lines)} ]
    features << {name: "Cyclomatic complexity", data: prepare_data(@methods, :complexity)}
    text = prepare_text(features)
    build_text_view(text)
  end

  def build_if_smell_view
    text_arr = []
    @smells.each {|s| text_arr << s.to_s + "\n" if s.type == :too_complex_method}
    build_text_view(text_arr.join)
  end

  def build_method_smell_view
    text_arr = []
    @smells.each {|s| text_arr << s.to_s + "\n" if s.type == :too_big_method}
    build_text_view(text_arr.join)
  end

  def build_text_view(text)
    stats_view = Gtk::TextView.new
    stats_view.editable = false
    stats_view.cursor_visible = false
    stats_view.buffer.text = text
    stats_view.show
    stats_view
  end

  def prepare_text(features)
    text_arr = []
    features.each do |feature|
      text_arr << "#{feature[:name]}: \n"
      data = feature[:data]
      data.each_index do |i|
        break if i == 30
        item = data[i]
        text_arr << "#{i+1}. #{item[:label]} => #{item[:value]} \n"
      end
      text_arr << "\n"
    end
    text_arr.join
  end

  def build_class_diag_view
    diagrams = [ {title: "Lines of code", parameter: :lines} ]
    diagrams << {title: "Cyclomatic complexity", parameter: :complexity}
    diagrams << {title: "Number of methods", parameter: "methods_number"}
    build_diag_view(@classes, diagrams)
  end

  def build_method_diag_view
    diagrams = [ {title: "Lines of code", parameter: :lines} ]
    diagrams << {title: "Cyclomatic complexity", parameter: :complexity}
    build_diag_view(@methods, diagrams)
  end

  def build_diag_view(raw_data, diagrams)
    tabbed_panel = Gtk::Notebook.new

    diagrams.each do |diag|
      data = prepare_data(raw_data, diag[:parameter])

      title = diag[:title]

      pie_chart = build_pie_chart(title, data)
      bar_chart = build_bar_chart(title, data.first(10))

      container = Gtk::VBox.new(false, 4)
      container = container.pack_end(pie_chart)
      container = container.pack_end(bar_chart)
      container.show

      tabbed_panel.append_page(container, Gtk::Label.new(title))
    end

    tabbed_panel.show
  end

  def build_pie_chart(title, data)
    binary_chart = Visualizer.make_pie_chart(title, data, 4)
    chart_to_image(binary_chart)
  end

  def build_bar_chart(title, data)
    binary_chart = Visualizer.make_bar_chart(title, data)
    chart_to_image(binary_chart)
  end

  def chart_to_image(binary_chart)
    loader = Gdk::PixbufLoader.new("png")
    loader.last_write(binary_chart)
    chart = loader.pixbuf
    Gtk::Image.new(chart).show
  end
#######
  def build_class_dep_view
    binary_chart = Visualizer.make_dependency_diagram(@classes)
    loader = Gdk::PixbufLoader.new("png")
    loader.last_write(binary_chart)
    chart = loader.pixbuf
    Gtk::Image.new(chart).show
  end

##########################################

  def show_file_chooser_dialog
    dialog = Gtk::FileChooserDialog.new("Open File",
                                       nil,
                                       Gtk::FileChooser::ACTION_SELECT_FOLDER,
                                       nil,
                                       [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                       [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
    dialog_response = dialog.run
    return dialog_response, dialog
  end

  def clean_data_view
    @builder['dataviewport'].each do |child|
      @builder['dataviewport'].remove(child)
    end
  end

  def prepare_data(raw_data, parameter)
    data = raw_data.sort_by {|d| d.send(parameter.to_s)}.reverse
    data.map! {|d| {label: d.to_s, value: d.send(parameter.to_s)}}
  end

  private :build_general_stats_view, :build_class_stats_view,
    :build_method_stats_view, :build_if_smell_view,
    :build_method_smell_view, :build_text_view
end
