param(
  [int]$Port = 8735,
  [string]$Root = (Split-Path -Parent $PSScriptRoot)
)
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $Root on http://localhost:$Port/"
$mime = @{ ".html"="text/html; charset=utf-8"; ".css"="text/css"; ".js"="application/javascript"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".gif"="image/gif" }
while ($listener.IsListening) {
  $context = $listener.GetContext(); $req = $context.Request; $res = $context.Response
  $localPath = $req.Url.LocalPath
  if ($localPath -eq "/") { $localPath = "/index.html" }
  $filePath = Join-Path $Root ($localPath.TrimStart("/"))
  if (Test-Path $filePath -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($filePath); $ct = $mime[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
    $bytes = [System.IO.File]::ReadAllBytes($filePath); $res.ContentType = $ct; $res.ContentLength64 = $bytes.Length; $res.OutputStream.Write($bytes,0,$bytes.Length)
  } else { $res.StatusCode = 404; $nf = [System.Text.Encoding]::UTF8.GetBytes("404: $localPath"); $res.OutputStream.Write($nf,0,$nf.Length) }
  $res.OutputStream.Close()
}
