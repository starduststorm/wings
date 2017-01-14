public class PulsePattern {
  int pulseStart = -1;
  
  int lastY = 0;
  int regionWidth, regionHeight;
  
  int theLight = 0;
  int theHue = 0;
  
  int mode;
  
  float pos;
  float velocity;
    
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
  
  public int fadeRate()
  {
    if (mode == 2) {
      return 10;
    }
    return 6;
  }
  
  public void startIfNeeded()
  {
    if (pulseStart == -1) {
      pulseStart = millis();
      
      mode = (int)random(3);
      theHue = (int)random(100);
      velocity = 0;
      pos = 0;
    }
  }
  
  public void update(boolean trackingPerson)
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
          if (trackingPerson) {
            pulseStart = -1;
          }
          theLight = -1;
        }
      }
      ++theLight;
    } else if (mode == 1) {
      pushStyle();
      int pulseElapsed = currentMillis - pulseStart;
      float percentComplete = cubicEaseOut(pulseElapsed, 1200.0);
      
      int pulseY = (int)ceil(percentComplete * (regionHeight + 1));
      
      colorMode(RGB, 100);
      noSmooth();
      for (int i = lastY; i < pulseY; ++i) {
        float alpha = max(40, 100 * (i / (float)pulseY));
        stroke(0, 30, 50, alpha);
        line(0, i, regionWidth, i);
      }
      
      if (pulseElapsed > 1100) {
        // don't start a new pulse if we have a user
        pulseStart = (trackingPerson ? -1 : currentMillis);
        lastY = 0;
      } else {
        lastY = pulseY;
      }
    } else {
      
      if (velocity < 0 && velocity + 0.1 >= 0) {
        // don't start a new pulse if we have a user
        pulseStart = (trackingPerson ? -1 : currentMillis);
        lastY = 0;
        theHue = (int)random(100);
        velocity = 0;
        pos = 0;
      }
      velocity += 0.1;
      pos += velocity;
      if (pos > wingsRegionHeight) {
        velocity *= -1;
        pos = wingsRegionHeight;
      }
      
      colorMode(HSB, 100);
      noSmooth();
      stroke(theHue, 100, 100);
      for (int i = 0; i < abs(pos - lastY); ++i) {
        int sign = (pos - lastY > 0 ? -1 : 1);
        int y = (int)(pos + i * sign);
        //println("pos = " + pos, ", lastY = " + lastY + ", i = " + i + ", y = " + y);
        line(0, y, regionWidth, y);
      }
      
      if (pos < 0) {

      } else {
        lastY = (int)pos;
      }
    }
    delay(20);
  }
}