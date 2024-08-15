namespace Rit.Game.Structures.Map;

public class StructureHitObject {
    public double StartTime { get; set; }
    public int Data { get; set; }
    public double EndTime { get; set; }
    public string HitSounds { get; set; } = string.Empty;
    public bool IsLN => EndTime != StartTime && EndTime != 0;
    public bool MoveWithScroll = true; // If its a LN, this will be set to false for a good LN thingy idk what to call it ngl
    public bool CanBeHit = false;
    public bool TooLatge = false;
    public bool WasGoodHit = false;

    public void OnHit() {
        // TODO: Play hitsound
    }
}
