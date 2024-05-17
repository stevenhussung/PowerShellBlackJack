class Card 
{
  [string] $Suit
  [string] $Rank
  
  Card() {$this.Init('2', 'H')}
  
  Card([string]$Rank, [string]$Suit)
  {
    $this.Init($Rank, $Suit)
  }
  
  [void] Init([string]$Rank, [string]$Suit)
  {
    $this.Rank = $Rank
    $this.Suit = $Suit
  }
  
  [string] ToString() 
  {
    return "$($this.Rank) of $($this.Suit)"
  }
  [int] Points()
  {
    if ($this.Rank -in @("J", "Q", "K")) 
        {return 10} 
    elseif ($this.Rank -eq "A") 
        #Aces are interpreted as "high" within the Card class. Points can be reduced in the hand class.
        {return 11} 
    else 
        {return [int]$this.Rank}
  }
}

class Hand
{
    [Card[]] $Cards

    # Empty hand for default initialization
    Card() {$this.Init(@())}

    Hand([Card[]] $importHand)
    {
        $this.Init($importHand)
    }

    [void] Init([Card[]] $importHand)
    {
        $this.Cards = $importHand
    }
    [string] ToString() 
    {
        $arrayOfStrings = 
        $this.Cards | 
        ForEach-Object {
            [string]$_
        }
        return $arrayOfStrings -join "`n"
    }
    [int] AceCount()
    {
        return ($this.Cards | Where-Object -Property Rank -eq 'A' | Measure-Object).Count
    }
    
    [int] MaxPoints()
    {
        return ($this.Cards | ForEach-Object {$_.Points()} | Measure-Object -Sum).Sum
    }

    [int] MinPoints()
    {
        return $this.MaxPoints() - $this.AceCount()*10
    }

    [int] Points()
    {
        For($points = $this.MaxPoints(); $points -gt 21 -and $points -gt $this.MinPoints(); $points -= 10) {}
        return $points 
    }
    
    [boolean] IsHandSoft()
    {   
        #A hand is soft if an Ace is currently being used as an 11 to increase the points.
        #This means that the Ace could "collapse" to bring Points down closer to MinPoints.
        return ($this.MinPoints() -lt $this.Points())        
    }
}


$myCard = [Card]::new("K", "H")

Write-Output [string]$myCard

$myCard.points()


Write-Output "Hand class now"
$myHand = 
@(
    [Card]::new("2", "H")
    , [Card]::new("J", "S")
    , [Card]::new("9", "D")
    , [Card]::new("A", "D")
    , [Card]::new("A", "S")
)
$myHand2 = [Hand]::new($myHand)

Write-Output $myHand2.ToString()

Write-Output "Which is" $myHand2.Points() "points"
Write-Output "With " $myHand2.AceCount() "aces"
Write-Output "And is the hand soft?" $myHand2.IsHandSoft()