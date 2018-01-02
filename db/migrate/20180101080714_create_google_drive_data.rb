class CreateGoogleDriveData < ActiveRecord::Migration[5.0]
  def change
    create_table :google_drive_data do |t|
      t.string :fileid
      t.string :title
      t.integer :depth
      t.string :mime_type
      t.string :icon_link
      t.string :web_view_link
      t.string :parent
      t.string :owner
      t.string :permission
      t.text   :content

      t.timestamps
    end
  end
end
