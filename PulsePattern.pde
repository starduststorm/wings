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
  
  public boolean isRunning()
  {
    return pulseStart != -1;
  }
  
  public void startIfNeeded()
  {
    if (pulseStart == -1) {
      pulseStart = millis();
    }
  }
  
  public void update(int userId)
  {
    if (pulseStart == -1) {
      return;
    }
    
    int currentMillis = millis();
    pushStyle();
    pushMatrix();
    translate(startx, starty, 0);
    if (pulseStart == -1) {
      pulseStart = currentMillis;
    }
    
    int pulseElapsed = currentMillis - pulseStart;
    float percentComplete = cubicEaseOut(pulseElapsed, 1200.0);
    
    int pulseY = (int)ceil(percentComplete * regionHeight);
    
    colorMode(RGB, 100);
    noSmooth();
    for (int i = lastY; i < pulseY; ++i) {
      float alpha = max(40, 100 * (i / (float)pulseY));
      stroke(0, 30, 50, alpha);
      line(0, i, regionWidth, i);
    }
    popMatrix();
    
    if (pulseElapsed > 1600) {
      // don't start a new pulse if we have a user
      pulseStart = (userId == -1 ? currentMillis : -1);
      lastY = 0;
    } else {
      lastY = pulseY;
    }
    popStyle();
  }
}

