class GoogledriveController < ApplicationController
  protect_from_forgery except: :get_docs # get_docsアクションを除外

  def index
    @files = GoogleDriveDatum.order('fullpath')
  end

  def docs
    @files = GoogleDriveDatum.where("content <> ''").order('fullpath')
  end

  def get_docs
    ajax_action unless params[:ajax_handler].blank?

    # Ajaxリクエストではない時の処理
  end

  def ajax_action
    if params[:ajax_handler] == 'handle_name1'
      # Ajaxの処理
      id = params[:id]
      @data = GoogleDriveDatum.find(id)
      @output_html = "表示不可"
      if @data.content != ""
        File.open(@data.content, "r") do |f|
          @output_html = f.read
        end
      end
      render
    end
  end

end
