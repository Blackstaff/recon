require_relative '../analyzer.rb'

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
    end

    @builder['dataviewport'].add(Gtk::TextView.new)
  end

  def on_class_dep_button_clicked
    clean_data_view

    unless @class_dep_view
    end

    @builder['dataviewport'].add(Gtk::TextView.new)
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
    end

    @builder['dataviewport'].add(Gtk::TextView.new)
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
      text_arr = ["Total number of classes: #{@classes.length} \n"]
      text_arr << "Total number of methods: #{@methods.length}"
      build_text_view(text_arr.join)
  end

  def build_class_stats_view
      text_arr = []
      build_text_view(text_arr.join)
  end

  def build_method_stats_view
      text_arr = []
      build_text_view(text_arr.join)
  end

  def build_if_smell_view
      text_arr = []
      build_text_view(text_arr.join)
  end

  def build_method_smell_view
      text_arr = []
      build_text_view(text_arr.join)
  end

  def build_text_view(text)
      stats_view = Gtk::TextView.new
      stats_view.editable = false
      stats_view.cursor_visible = false
      stats_view.buffer.text = text
      stats_view
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

end
