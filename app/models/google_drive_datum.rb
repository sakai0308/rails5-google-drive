class GoogleDriveDatum < ApplicationRecord
  MAX_DEPTH = 99
  MAX_DEPTH.freeze

  #0:通常
  #1:テスト用ロジック実行
  EXEC_MODE = 0
  EXEC_MODE.freeze

  def self.search_all
    client_id     = ENV["CLIENT_ID"]
    client_secret = ENV["CLIENT_SECRET"]
    refresh_token = ENV["REFRESH_TOKEN"]

    client = OAuth2::Client.new(
        client_id,
        client_secret,
        site: "https://accounts.google.com",
        token_url: "/o/oauth2/token",
        authorize_url: "/o/oauth2/auth"
    )
    auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
    auth_token = auth_token.refresh!
    @session = GoogleDrive.login_with_oauth(auth_token.token)

    #DBデータ更新
    GoogleDriveDatum.delete_all
    search("'root' in parents and trashed = false and 'me' in owners", 0, '', '/')
  end

  def self.search(q, depth, parent, filepath)
    @session.files(q: q) do |file|
      # get owners
      owners = []
      file.owners.each do |owner|
        owners << "#{owner.try(:display_name)} <#{owner.try(:email_address)}>"
      end

      permissions = []
      file.permissions.each do |permission|
        permissions << "#{permission.role}:#{permission.display_name} <#{permission.try(:type)}>"
      end

      #ドキュメントの中身取得
      content = ""
      if file.mime_type == 'application/vnd.google-apps.document'
        filedir = "public/output_file/" + file.id
        @session.drive.export_file(file.id,'text/html',download_dest: filedir)
        content = filedir
      end

      #各種情報取得
      id = file.id
      title = file.title
      mime_type = file.mime_type
      icon_link = file.icon_link
      web_view_link = file.web_view_link

      if EXEC_MODE == 1
        change_txt_to_docs(file, parent)
      end

      hash = {
        :fileid => id,
        :title => title,
        :depth => depth,
        :mime_type => mime_type,
        :icon_link => icon_link,
        :web_view_link => web_view_link,
        :parent => parent,
        :owner => owners,
        :permission => permissions,
        :filepath => filepath,
        :fullpath => filepath + title,
        :content => content
      }

      #Google Drive APIより取得したデータをテーブルに保存
      google_drive_data = GoogleDriveDatum.new
      google_drive_data.attributes = hash
      google_drive_data.save

      #フォルダーの中を検索
      if file.mime_type == 'application/vnd.google-apps.folder' and depth < MAX_DEPTH
        search("'#{file.id}' in parents and trashed = false and 'me' in owners", depth + 1, file.id, filepath + title + '/')
      end
    end
  end

  #.txtをGoogle Docsに変換
  def self.change_txt_to_docs(file, parent)
    if file.mime_type == 'text/plain'
      old_file_id = file.id

      #旧ファイル取得
      @session.drive.get_file(file.id, download_dest: "dummy.txt")
      #新ファイル作成
      file_metadata = {
          name: file.title.gsub(/.txt/, ""),
          parents: [parent],
          mime_type: 'application/vnd.google-apps.document'
      }
      @session.drive.create_file(file_metadata,
                                 fields: 'id',
                                 upload_source: 'dummy.txt',
                                 content_type: file.mime_type)
      #旧ファイル削除
      @session.drive.delete_file(old_file_id)
    end
  end

end
