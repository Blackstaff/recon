require_relative '../analyzer.rb'

class View

	include GladeGUI

	def before_show()
    dialog_response, dialog = show_file_chooser_dialog
    if dialog_response == Gtk::Dialog::RESPONSE_ACCEPT
      analyzer = Analyzer::Analyzer.new
      @classes, @methods, @smells = analyzer.analyze(dialog.filename)
      build_general_stats_view
      @builder['dataviewport'].add(@general_stats_view)
    end
    dialog.destroy
	end

	def button1__clicked(*args)
		#@builder["button1"].label = @builder["button1"].label == "Hello World" ? "Goodbye World" : "Hello World"
	end

  def build_general_stats_view
      @general_stats_view = Gtk::TextView.new
      @general_stats_view.editable = false
      @general_stats_view.cursor_visible = false
      @general_stats_view.buffer.text = "Total number of classes: #{@classes.length} \n"
      @general_stats_view.buffer.text += "Total number of methods: #{@methods.length}"
  end

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

end
