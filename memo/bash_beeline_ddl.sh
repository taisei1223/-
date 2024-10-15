#!/bin/bash

# Beeline接続情報
jdbc_url="jdbc:hive2://localhost:10000/default"
user="your_username"
password="your_password"

# SQLファイルを読み込み、それぞれのSQLコマンドを実行
# 'queries.sql' ファイルに複数のSQLが記載されている前提
sql_file="queries.sql"

# 一時的なファイルを作成して、それぞれのSQLコマンドの結果を保存する
counter=1

# 1回のbeeline接続で複数のSQLを実行し、各結果を個別のファイルに保存
while IFS= read -r sql_cmd || [ -n "$sql_cmd" ]; do
    # 空行やコメント行をスキップ
    if [[ -z "$sql_cmd" || "$sql_cmd" == --* ]]; then
        continue
    fi
    
    # SQL実行結果をファイルに保存（例: result_1.txt, result_2.txt など）
    beeline -u $jdbc_url -n $user -p $password --silent=true --outputformat=tsv2 -e "$sql_cmd" > "result_$counter.txt"
    
    echo "SQLコマンド '$sql_cmd' の結果を result_$counter.txt に保存しました。"
    
    # カウンターをインクリメント
    counter=$((counter+1))
done < "$sql_file"