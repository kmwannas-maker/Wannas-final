# Seed Firestore with sport questions from sport_questions.json
$PROJECT_ID = "card-connect-1"
$API_KEY    = "AIzaSyAgCJF7Op3Vm3_uUulY5QfV_GIRNjlTt5o"
$BASE_URL   = "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/questions"

$jsonPath  = Join-Path $PSScriptRoot "sport_questions.json"
$questions = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json

$total  = $questions.Count
$i      = 0
$errors = 0

foreach ($q in $questions) {
    $i++

    # Base fields always present
    $fields = [ordered]@{
        mode  = @{ stringValue  = $q.mode }
        depth = @{ integerValue = "$($q.depth)" }
        en    = @{ stringValue  = $q.en }
        ar    = @{ stringValue  = $q.ar }
    }

    # Add answer fields only when they exist in the JSON
    if ($q.answerEn) {
        $fields["answerEn"] = @{ stringValue = $q.answerEn }
    }
    if ($q.answerAr) {
        $fields["answerAr"] = @{ stringValue = $q.answerAr }
    }

    $body      = [ordered]@{ fields = $fields } | ConvertTo-Json -Depth 6 -Compress
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $null = Invoke-RestMethod -Method Post `
            -Uri "$BASE_URL`?key=$API_KEY" `
            -Body $bodyBytes `
            -ContentType "application/json; charset=utf-8"
        $preview = $q.en.Substring(0, [Math]::Min(50, $q.en.Length))
        Write-Host "[$i/$total] OK  d$($q.depth): $preview..." -ForegroundColor Green
    } catch {
        $errors++
        Write-Host "[$i/$total] ERR d$($q.depth): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Uploaded $($total - $errors)/$total questions. Errors: $errors" -ForegroundColor Cyan
