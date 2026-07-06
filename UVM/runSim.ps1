
Clear-Host
Write-Host ".......... Chamando script no WSL .........." -ForegroundColor Cyan

wsl --exec /home/pedro/Programas_asm/run.sh

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCESSO] Gabarito e memoria gerados"
} else {
    Write-Host "`n[ERRO] Falha ao rodar o script no WSL. Abortando." -ForegroundColor Red
    Exit
}

vsim -c -do simular.do

Write-Host "`n .......... [FIM] .........." -ForegroundColor Green