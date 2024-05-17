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
        return $drawnCard
    }
}


$myCard = [Card]::new("K", "H")

Write-Output [string]$myCard

$myCard.points()


Write-Output "Hand class now"
$myHand = 
[Hand]::new(@(
    [Card]::new("2", "H")
    , [Card]::new("J", "S")
    , [Card]::new("9", "D")
    , [Card]::new("A", "D")
    , [Card]::new("A", "S")
))

Write-Output $myHand.ToString()

Write-Output "Which is" $myHand.Points() "points"
Write-Output "With " $myHand.AceCount() "aces"
Write-Output "And is the hand soft?" $myHand.IsHandSoft()

Write-Output "Creating the deck"

$cardList = [Card]::AllCards()
$myDeck = [Deck]::new($cardList)
Write-Output "There are $($myDeck.Size()) cards in the deck"
Write-Output "Here are the cards in the deck:"
Write-Output "Shuffling...."
$myDeck.Shuffle()
Write-Output "Drawing a card"
Write-Output $myDeck.Draw()
Write-Output "Now here are the cards in the deck:"
Write-Output ([string]$myDeck)
Write-Output "There are $($myDeck.Size()) cards in the deck"