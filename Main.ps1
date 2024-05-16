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
    {return 11} 
    else 
    {return [int]$this.Rank}
  }
}

$myCard = [Card]::new("3", "H")

Write-Output [string]$myCard

$myCard.points()