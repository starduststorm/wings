public class PulsePattern {
  int pulseStart;
  
  int startx, starty;
  int regionWidth, regionHeight;
  
  public PulsePattern(int startx, int starty, int regionWidth, int regionHeight)
  {
    this.startx = startx;
    this.starty = starty;
    this.regionWidth = regionWidth;
    this.regionHeight = regionHeight;
  }
  
  private float cubicEaseOut(float time, float duration)
  {
    time /= duration;
    time--;
    return (time * time * time + 1);
  }
  
  public void update(int userId)
  {
    if (userId != -1 && pulseStart == -1) {
      return;
    }
    pushMatrix();
    translate(startx, starty, 0);
    if (pulseStart == -1) {
      pulseStart = millis();
    }
    
    int pulseElapsed = millis() - pulseStart;
    float percentComplete = cubicEaseOut(pulseElapsed, 800.0);
    println("elapsed: " + pulseElapsed + ", % = " + percentComplete);
    
    float pulseY = percentComplete * regionHeight;
    
    if (pulseElapsed > 1600) {
      pulseStart = -1;
    } 
    
    colorMode(RGB, 100);
    fill(0, 30, 50);
    noStroke();
    // TODO: Draw this rect like a gradient from the previous frame to make it look smooth
    rect(0, pulseY, regionWidth, 4);
    popMatrix();
  }
}
