class Card 
{
  [string] $Suit
  [string] $Rank
  
  Card() 
  {
    $this.Init('2', 'H')
  }
  
  Card([string]$Rank, [string]$Suit)
  {
    $this.Init($Rank, $Suit)
  }
  
  [void] Init([string]$Rank, [string]$Suit)
  {
    $this.Rank = $Rank
    $this.Suit = $Suit
  }
  
  static [string[]] Ranks()
  {
    return @("2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A")
  }

  static [string[]] Suits()
  {
    return @("H", "D", "S", "C")
  }
  
  static [Card[]] AllCards()
  {
    $array = 
    foreach ($rank in [Card]::Ranks()) 
    {
        foreach ($suit in [Card]::Suits()) 
        {
            [Card]::new($rank, $suit)
        }
    }
    return $array
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
    Hand()
    {
        $this.Init(@())
    }

    Hand([Card[]] $importHand)
    {
        $this.Init($importHand)
    }

    [void] Init([Card[]] $importHand)
    {
        $this.Cards = $importHand
    }
    
    [void] AddCard([Card] $newCard)
    {
        $this.Cards += $newCard
    }

    [string] ToString() 
    {
        $arrayOfStrings = 
        $this.Cards | 
        ForEach-Object {
            [string]$_
        }
        $mainString = $arrayOfStrings -join "`n"
        $mainString += "`n for a " + $this.HandSoftness() + " " + $this.Points()
        return $mainString
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

    [string] HandSoftness()
    {
        $returnString = if($this.IsHandSoft()) {"Soft"} else {"Hard"}
        return [string]$returnString
    }
    
    [boolean] IsBust()
    {
        return ($this.Points() -gt 21)
    }
    
    [boolean] BeatsHand([Hand] $OtherHand)
    {
        return (
            (-not $this.IsBust()) -and 
            ($this.Points() -gt $OtherHand.Points() -or $OtherHand.IsBust())
        )
    }
    
    [boolean] DealerDraws()
    {
       #Dealer etiquette 
       return (
        $this.Points() -lt 17 -or 
        ($this.Points() -eq 17 -and $this.IsHandSoft())
        )
    }
}

class Deck
{
    [Card[]] $Cards

    # Full deck for default initialization
    Deck()
    {
        $this.Init([Card]::AllCards())
    }

    Deck([Card[]] $importCardArray)
    {
        $this.Init($importCardArray)
    }

    [void] Init([Card[]] $importCardArray)
    {
        $this.Cards = $importCardArray
    }
    
    [string] ToString() 
    {
        return ( $this.Cards | ForEach-Object { [string]$_ } ) -join "`n"
    }
    
    [int] Size()
    { return $this.Cards.count }
    
    [void] Shuffle()
    { 
        $this.Cards = $this.Cards | Sort-Object {Get-Random}
    }
    
    [Card] Draw()
    {
        ($drawnCard, $this.Cards) = ($this.Cards.Where({1 -eq 1}, 'Split', 1))
        return $drawnCard[0]
    }
}

Function Deal ([Deck]$Deck, [boolean]$ShuffleEveryRound) 
{
    do
    {
        $ShuffleEveryRound = $true
        #Deal Cards
        if ($ShuffleEveryRound)
        {
            $Deck = [Deck]::new([Card]::AllCards())
        }
        $Deck.Shuffle()
        
        $PlayerHand = [Hand]::new(@($Deck.Draw(), $Deck.Draw()))
        $DealerHand = [Hand]::new(@($Deck.Draw()))
        
        $DealtBlackJack = ($PlayerHand.Points() -eq 21)
    }
    while($DealtBlackjack)
    
    return $PlayerHand, $DealerHand, $Deck
}

Function Score([Hand]$PlayerHand, [Hand]$DealerHand)
{
    if($PlayerHand.IsBust() -and $DealerHand.IsBust())
    {
        Write-Output "Both bust!" "This is an Error"
    }
    elseif ( $PlayerHand.BeatsHand($DealerHand) )
    {
        Write-Output "Player wins!"
    }
    elseif ( $DealerHand.BeatsHand($PlayerHand) )
    {
        Write-Output "Dealer wins!"
    }
    else
    {
        Write-Output "Tie!"
    }
    Write-Output "`n`n`n"
}

#TODO: Make this flag truly work. Game should play either way.
$ShuffleEveryRound = $true
$Deck = [Deck]::new()

$ContinueFlag = $true
while($ContinueFlag)
{
    # Eventually I would like a persistent deck
    # ($PlayerHand, $DealerHand, $Deck) = Deal($Deck, $ShuffleEveryRound)
    ($PlayerHand, $DealerHand, $Deck) = Deal -Deck $Deck -ShuffleEveryRound $ShuffleEveryRound
    
    #Player Hit Stay Loop
    Write-Output "Player Hand:" ([string]$PlayerHand)
    Write-Output "Dealer Hand:" ([string]$DealerHand)
    $HitFlag = (Read-Host "Type 'h' to hit, anything else to stay") -eq "h"
    Write-Output ""

    while($HitFlag -and (-not $PlayerHand.IsBust()))
    {
        $PlayerHand.AddCard($Deck.Draw())
        
        Write-Output "Player Hand:" ([string]$PlayerHand)
        Write-Output "Dealer Hand:" ([string]$DealerHand)
        
        if ($PlayerHand.Points() -lt 21)
        {
            $HitFlag = (Read-Host "Type 'h' to hit, anything else to stay") -eq "h"
        }
        elseif ($PlayerHand.Points() -eq 21)
        { Write-Output "Perfect!" }
        else
        { Write-Output "Bust!" }
    }
    
    #Dealer Hit Stay Loop
    while($DealerHand.DealerDraws() -and (-not $PlayerHand.isBust()))
    { $DealerHand.AddCard($Deck.Draw()) }
    
    #Score
    Write-Output "Final Hands:"
    Write-Output "Player Hand:" ([string]$PlayerHand)
    Write-Output "Dealer Hand:" ([string]$DealerHand)
    
    Score -PlayerHand $PlayerHand -DealerHand $DealerHand

    $ContinueFlag = ((Read-Host "Type 'q' to quit, or enter to continue") -ne "q")
}