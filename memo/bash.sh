#!/bin/bash

# 入力CSVファイル
input_csv="ddl_results.csv"

# 出力ディレクトリ
output_dir="./ddl_outputs"
mkdir -p "$output_dir"

# DDLの抽出に使用するキーワード
start_keyword="createtab_stmt"
end_keyword="createtab_stmt"

# テンポラリ変数
current_ddl=""
file_name=""

# ファイル内の行を一つずつ処理
while IFS= read -r line; do
    # DDLの開始を検出
    if [[ "$line" == *"$start_keyword"* ]]; then
        current_ddl="$line"
    elif [[ "$line" == *"$end_keyword"* ]]; then
        current_ddl+=$'\n'"$line"
        
        # DDLの中から "create table" の行を見つけ、データベース名とテーブル名を取得
        table_info=$(echo "$current_ddl" | grep -i "create table" | awk '{print $3}')
        
        # テーブル名をファイル名に変換 (データベース名.テーブル名.sql)
        file_name="${table_info//\./_}.sql"
        
        # DDLをファイルに書き出し
        echo "$current_ddl" > "$output_dir/$file_name"
        
        # 次のDDLに備えてクリア
        current_ddl=""
    else
        # DDLが続いている場合は追加
        if [[ -n "$current_ddl" ]]; then
            current_ddl+=$'\n'"$line"
        fi
    fi
done < "$input_csv"

echo "DDLの分割と保存が完了しました。保存場所: $output_dir"
