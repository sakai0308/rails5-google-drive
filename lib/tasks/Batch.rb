class Tasks::Batch

  #実行コマンド
  #rails runner Tasks::Batch.execute
  def self.execute
    # 実行したいコードを書く
    puts "バッチ開始時刻:" + Time.current.to_s
    GoogleDriveDatum.search_all
    puts "バッチ終了時刻:" + Time.current.to_s
  end

end
