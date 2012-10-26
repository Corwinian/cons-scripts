$ver = "0.4"
$dt=Get-Date -Format "dd-MM-yyyy"
New-Item -ItemType directory log -Force | out-null #Создаю директорию для логов

$global:logfilename="log\"+$dt+"_LOG.log"
[int]$global:errorcount=0 #Ведем подсчет ошибок
[int]$global:warningcount=0 #Ведем подсчет предупреждений

function global:Write-log	# Функция пишет сообщения в лог-файл и выводит на экран.
{param($message,[string]$type="info",[string]$logfile=$global:logfilename,[switch]$silent)	
    $dt=Get-Date -Format "dd.MM.yyyy HH:mm:ss"	
    $msg=$dt + "`t" + $type + "`t" + $message #формат: 01.01.2001 01:01:01 [tab] error [tab] Сообщение
    Out-File -FilePath $logfile -InputObject $msg -Append -encoding unicode
    if (-not $silent.IsPresent) 
    {
        switch ( $type.toLower() )
        {
            "error"
            {			
                $global:errorcount++
                write-host $msg -ForegroundColor red			
            }
            "warning"
            {			
                $global:warningcount++
                write-host $msg -ForegroundColor yellow
            }
            "completed"
            {			
                write-host $msg -ForegroundColor green
            }
            "info"
            {			
                write-host $msg
            }			
            default 
            { 
                write-host $msg
            }
        }
    }
}