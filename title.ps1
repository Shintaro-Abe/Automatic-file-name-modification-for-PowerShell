$folderPath = "C:\path\to\your\folder" # 監視するフォルダのパス

# フォルダ名を取得
$folderName = Split-Path -Path $folderPath -Leaf

# フォルダ内の全てのファイルを取得
$files = Get-ChildItem -Path $folderPath

# 拡張子ごとのカウンターを保存するハッシュテーブルを作成
$extensionCounters = @{}

foreach ($file in $files) {
    # 拡張子を取得（先頭のドットを削除）
    $extension = $file.Extension.TrimStart('.')

    # 既にリネームされたファイルの最大番号を取得
    if ($file.Name -match "$folderName-(\d+).$extension") {
        $currentNumber = [int]$Matches[1]
        if (-not $extensionCounters.ContainsKey($extension) -or $currentNumber -ge $extensionCounters[$extension]) {
            $extensionCounters[$extension] = $currentNumber + 1
        }
    } elseif (-not $extensionCounters.ContainsKey($extension)) {
        $extensionCounters[$extension] = 1
    }
}

# 新しいファイルに対してリネームを実行
foreach ($file in $files) {
    $extension = $file.Extension.TrimStart('.')

    if ($file.Name -notlike "$folderName-*.$extension") {
        $counter = $extensionCounters[$extension]
        $newName = $folderPath + "\" + $folderName + "-" + "{0:D3}" -f $counter + $file.Extension

        if (-not (Test-Path $newName)) {
            Rename-Item $file.FullName $newName
            $extensionCounters[$extension]++
        }
    }
}