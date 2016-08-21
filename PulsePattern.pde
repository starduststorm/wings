public class PulsePattern {
  int pulseStart = -1;
  
  int startx, starty;
  int lastY = 0;
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
    pushStyle();
    if (userId != -1 && pulseStart == -1) {
      return;
    }
    pushMatrix();
    translate(startx, starty, 0);
    if (pulseStart == -1) {
      pulseStart = millis();
    }
    
    int pulseElapsed = millis() - pulseStart;
    float percentComplete = cubicEaseOut(pulseElapsed, 1200.0);
    
    int pulseY = (int)ceil(percentComplete * regionHeight);
    
    colorMode(RGB, 100);
    noSmooth();
    for (int i = lastY; i < pulseY; ++i) {
      float alpha = max(40, 100 * (i / (float)pulseY));
      stroke(0, 30, 50, alpha);
      println("Line at " + i + ", alpha = " + alpha);
      line(0, i, regionWidth, i);
    }
//    rect(0, lastY, regionWidth, pulseY - lastY);
    popMatrix();
    
    if (pulseElapsed > 1600) {
      pulseStart = -1;
      lastY = 0;
    } else {
      lastY = pulseY;
    }
    popStyle();
  }
}
