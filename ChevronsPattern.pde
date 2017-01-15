public class ChevronsPattern extends IdlePattern {
  int leadingEdge;
  
  public ChevronsPattern(int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
  }
  
  public void startPattern()
  {
    super.startPattern();
    leadingEdge = 0;
  }
  
  public void update()
  {
    colorMode(HSB, 100);
    stroke(100);
    noSmooth();
    
    for (int i = 0 ; i < 3; ++i) {
      clip(0, 0, displayWidth / 2, displayHeight);
      line(displayWidth / 2 - leadingEdge, displayHeight / 2.0, displayWidth / 2 - leadingEdge - 4, 0);
      line(displayWidth / 2 - leadingEdge, displayHeight / 2.0, displayWidth / 2 - leadingEdge - 4, displayHeight);
      noClip();
      
      clip(displayWidth / 2, 0, displayWidth / 2, displayHeight);
      noClip();
    }
    
    leadingEdge++;
  }
}