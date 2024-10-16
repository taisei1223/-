#!/bin/bash

# 入力CSVファイル
input_csv="ddl_results.csv"

# 出力ディレクトリ
output_dir="./ddl_outputs"
mkdir -p "$output_dir"

# DDLの抽出に使用するキーワード
keyword="createtab_stmt"

# テンポラリ変数
current_ddl=""
file_name=""
in_ddl_block=false

# ファイル内の行を一つずつ処理
while IFS= read -r line; do
    # デバッグ用: 各行の内容を確認
    echo "Processing line: $line"

    # DDLの開始と終了を検出
    if [[ "$line" == *"$keyword"* ]]; then
        if [ "$in_ddl_block" = true ]; then
            # 既に DDL ブロック内なら、終了と判断してファイルに保存
            current_ddl+=$'\n'"$line"

            # DDLの中から "create table" の行を見つけ、データベース名とテーブル名を取得
            table_info=$(echo "$current_ddl" | grep -i "create table" | awk '{print $3}')

            # テーブル名をファイル名に変換 (データベース名.テーブル名.sql)
            file_name="${table_info//\./_}.sql"

            # DDLをファイルに書き出し
            echo "$current_ddl" > "$output_dir/$file_name"
            echo "Saved DDL to: $output_dir/$file_name"

            # 次のDDLに備えてクリア
            current_ddl=""
            in_ddl_block=false
        else
            # DDLブロックの開始
            current_ddl="$line"
            in_ddl_block=true
        fi
    else
        # DDLが続いている場合は追加
        if [ "$in_ddl_block" = true ]; then
            current_ddl+=$'\n'"$line"
        fi
    fi
done < "$input_csv"

echo "DDLの分割と保存が完了しました。保存場所: $output_dir"
