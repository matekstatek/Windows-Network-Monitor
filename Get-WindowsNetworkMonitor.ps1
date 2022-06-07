# path to log file
$logFilePath = ".\logfile.log"

# counter for average
$bufferSize = 200
$counterBuffor = 0

"" > $logFilePath

# pobieramy z "Get-Counter" nagłówki, żeby zrobić tabelę
# taking header from Get-Counter to make a table
$headers = (Get-Counter | 
    select -ExpandProperty countersamples | 
        select -ExpandProperty path) -split "\\"

write-host "Server Name: $($headers[2])"
write-host

# all data printed in CLI is also put to logfile
$line = ""
$line += "| {0,28}" -f "DateTime"

# add headers to $line
for($i=0; $i -lt $headers.count; $i++)
{
    if($($i % 5 - 3) -eq 0)
    {
        if($i -eq 3)
        {
            $line += " | {0,28}" -f $($headers[$i]).Split("(")[0]
        }
        else
        {
            $line += " | {0,28}" -f $($headers[$i])
        }
    }
}

$line += " |"
write-host $line  
$line >> $logFilePath

$line = ""
$line += "| {0,28}" -f "DD.MM.YYYY HH:mm:SS"

# add headers data to $line
for($i=0; $i -lt $headers.count; $i++)
{
    if($($i % 5 - 4) -eq 0)
    {
        $line += " | {0,28}" -f $($headers[$i])
    }
}

$line += " |"
write-host $line
$line >> $logFilePath

$line2 = ""

for($i=0; $i -lt $line.Length; $i++)
{
    $line2 += "-" 
    
}
$line2 >> $logFilePath
Write-Host $line2

# in buffer there are sums of X measurements for 6 headers
# X - number of measurements specified in $bufferSize
$buffer = {0,0,0,0,0,0}

# until script is running
for($i=0; $true; $i++)
{
    $line = ""
    # set zeros in buffer
    $buffer = (0,0,0,0,0,0)

    # for X measurements
    for($j=0; $j -lt $bufferSize; $j++)
    {
        $counter = get-counter | 
            select -ExpandProperty countersamples | 
                select -ExpandProperty cookedvalue

        # putting amount for header on specific index in $buffers
        $k = 0
        foreach($c in $counter)
        {
            $buffer[$k] += $c
            $k ++
        }
    }

    # counting average values
    for($k = 0; $k -lt $counter.Count; $k++)
    {
        $buffer[$k] /= $bufferSize
    }

    # printing
    $line += "| {0,28}" -f $(get-date)
    foreach($b in $buffer)
    {
        $line += " | {0,28}" -f [Math]::Round($($b),2)
    }

    $line += " |"
    write-host $line

    # print to file
    $line >> $logFilePath
}