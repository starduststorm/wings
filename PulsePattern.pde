public class PulsePattern {
  int pulseStart = -1;
  
  int lastY = 0;
  int regionWidth, regionHeight;
  
  int theLight = 0;
  int theHue = 0;
  
  int mode;
    
  public PulsePattern(int regionWidth, int regionHeight)
  {
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
      
      mode = (int)random(2);
      theLight = 0;
    }
  }
  
  public void update(int userId)
  {
    if (pulseStart == -1) {
      return;
    }
    
    int currentMillis = millis();
    if (pulseStart == -1) {
      pulseStart = currentMillis;
    }
    
    if (mode == 0) {
      blendMode(BLEND);
      colorMode(HSB, 100);
      color colo = color((theHue++ % 100), 100, 100);
      for (int x = 0; x < 8; ++x) {
        set(x, theLight, colo);
        if (theLight > wingsRegionHeight) {
          if (userId != -1) {
            pulseStart = -1;
          }
          theLight = -1;
        }
      }
      ++theLight;
    } else {
      pushStyle();
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
      
      if (pulseElapsed > 1600) {
        // don't start a new pulse if we have a user
        pulseStart = (userId == -1 ? currentMillis : -1);
        lastY = 0;
      } else {
        lastY = pulseY;
      }
    }
  }
}

