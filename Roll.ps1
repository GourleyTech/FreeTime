function Roll
    {

    <#
    .Synopsis
    Simulate rolling dice of any kind.  Roll multiple of the same kind or a percentage dice.  Add or subtract
    some modifiers while you are at it.

    .Description
    This was written to try an automate some dice rolls and work with different parts of Powershell
    to bring into one project to refer back to in the future.

    .Parameter Roll
    The input for how many Dice to Roll.  You can put in P or % for percentage.
    The default is a single D20 roll.
    You can denote how many of each dice you want to roll.
    You can also add or subtract any modifiers from it.

    .Example
    # Roll a single D20
    Roll 1

    .Example
    # Roll 5 D20s
    Roll 5d50

    .Example
    # Roll a percentage die
    Roll p
    Rolll %
    Roll percentage

    .Example
    # Roll 2 dice that are six sided
    Roll 2d6

    .Example
    # Roll 4 dice that are 4 sided and add 3 to the outcome
    Roll 4d4-3

    .Example
    # Roll 2 dice that are six sided and subtract 2 from it
    Roll 2d6-2

    .Example
    # Roll up a new character
    Roll new
    Roll char
    roll stats
    It will take just the first letter Roll n, c, s
#>

    Param ([array]$Roll)
    $RolledArray = @()
    [Int32]$NumberVerify = $null
    ForEach ($Dice in $Roll)
        {
        Write-Host ""
        Do {
            If($Dice -like "*+*")
                {
                $PlusChange += ($Dice.Split("+")[-1] -as [int])
                $Trim = (($Dice.Split("+")[-1]) | Measure-Object -Character | Select -ExpandProperty Characters) + 1
                $Dice = $Dice.Substring(0,$Dice.Length-$trim)
                }
            #($Dice -split "+") failed
            ElseIf($Dice -like "*-*")
                {
                $MinusChange += ($Dice.Split("-")[-1] -as [int])
                $Trim = (($Dice.Split("-")[-1]) | Measure-Object -Character | Select -ExpandProperty Characters) + 1
                $Dice = $Dice.Substring(0,$Dice.Length-$trim)
                }
            }
        While (($Dice -like "*+*") -or ($Dice -like "*-*"))

        #Roll a percentage die on anything that starts with P or %
        If(($Dice -like "%") -or ($Dice -like "p*"))
            {
            $PercentageRoll = (Get-Random -Minimum 0 -Maximum 100).ToString()+"%"
            $PercentageRoll
            }

        #Roll the number of D20s if a flat number is input
        ElseIf([Int32]::TryParse($Dice,[ref]$NumberVerify))
            {
            1..$Dice | ForEach-Object {$RolledArray += (Get-Random -Minimum 1 -Maximum 20)}
            #$Output = ($RolledArray -join ",")
            $RolledArray | ForEach {$_}# | Out-String
            }

        #Splits number of die to roll and rolls it that many times
        ElseIf($Dice -like "*d*")
            {
            $NumberofDice = ($Dice -split "d")[0]
            $ValueofDice = ($Dice -split "d")[1]
            1..$NumberofDice | ForEach-Object{$RolledArray += (Get-Random -Minimum 1 -Maximum $ValueofDice)}
            $TotalSum = ($RolledArray | Measure-Object -Sum) | Select -ExpandProperty Sum
            $Modify = $PlusChange - $MinusChange
            $EndAfterModify = $TotalSum + $Modify
            $Output = ($RolledArray -join ",")
            Write-Host $Output
            Write-host "$Modify for the modifier"
            Write-host "$EndAfterModify is the total"
            }
        
        #Rolls stats for a new character
        #Will roll 4 times and drop the lowest, stats do not need to be taken in order
        ElseIf(($Dice -like "N*") -or ($Dice -like "S*") -or ($Dice -like "C*"))
            {
            $StatsArray = @()
            ForEach ($Stat in 1..6)
                {
                $CreateArray = @()
                ForEach ($Value in 1..4)
                    {
                    $CreateArray += (Get-Random -Minimum 1 -Maximum 6)
                    }
                $StatsArray += ($CreateArray | Sort-Object -Descending | Select -First 3 | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
                }
            $StatOutput = ($StatsArray -join ",")
            Write-Host $StatOutput
            }
        }
    }