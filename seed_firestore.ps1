# Seed Firestore with all questions from questions_seed.json
$PROJECT_ID = "card-connect-1"
$API_KEY    = "AIzaSyAgCJF7Op3Vm3_uUulY5QfV_GIRNjlTt5o"
$BASE_URL   = "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/questions"

$jsonPath = Join-Path $PSScriptRoot "questions_seed.json"
$questions = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json

$total = $questions.Count
$i = 0
$errors = 0

foreach ($q in $questions) {
    $i++
    $body = [ordered]@{
        fields = [ordered]@{
            mode  = @{ stringValue  = $q.mode }
            depth = @{ integerValue = "$($q.depth)" }
            en    = @{ stringValue  = $q.en }
            ar    = @{ stringValue  = $q.ar }
        }
    } | ConvertTo-Json -Depth 5 -Compress

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $null = Invoke-RestMethod -Method Post `
            -Uri "$BASE_URL`?key=$API_KEY" `
            -Body $bodyBytes `
            -ContentType "application/json; charset=utf-8"
        Write-Host "[$i/$total] OK: $($q.mode) d$($q.depth) - $($q.en.Substring(0, [Math]::Min(40,$q.en.Length)))..."
    } catch {
        $errors++
        Write-Host "[$i/$total] ERROR: $($q.mode) d$($q.depth) - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Uploaded $($total - $errors)/$total questions. Errors: $errors"
