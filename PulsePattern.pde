public enum PulsePatternType {
  Rainbow,
  BlueFall,
  Bounce,
};

public class PulsePattern extends IdlePattern {
  int pulseStart = -1;
  
  int lastY = 0;
  
  int theLight = 0;
  int theHue = 0;
  
  PulsePatternType type;
  
  float pos;
  float velocity;
    
  public PulsePattern(PulsePatternType type, int regionWidth, int regionHeight)
  {
    super(regionWidth, regionHeight);
    this.type = type;
  }
  
  private float cubicEaseOut(float time, float duration)
  {
    time /= duration;
    time--;
    return (time * time * time + 1);
  }
  
  public int fadeRate()
  {
    if (type == PulsePatternType.Bounce) {
      return 10;
    }
    return 6;
  }
  
  public void startPattern()
  {
    super.startPattern();
    
    pulseStart = startMillis;
    theHue = (int)random(100);
    velocity = 0;
    pos = 0;
  }
  
  public void update()
  {
    if (pulseStart == -1) {
      return;
    }
    
    int currentMillis = millis();
    if (pulseStart == -1) {
      pulseStart = currentMillis;
    }
    
    if (type == PulsePatternType.Rainbow) {
      blendMode(BLEND);
      colorMode(HSB, 100);
      color colo = color((theHue++ % 100), 100, 100);
      for (int x = 0; x < 8; ++x) {
        set(x, theLight, colo);
        if (theLight > wingsRegionHeight) {
          if (this.isStopping()) {
            this.stopCompleted();
          }
          theLight = -1;
        }
      }
      ++theLight;
    } else if (type == PulsePatternType.BlueFall) {
      pushStyle();
      int pulseElapsed = currentMillis - pulseStart;
      float percentComplete = cubicEaseOut(pulseElapsed, 1200.0);
      
      int pulseY = (int)ceil(percentComplete * (this.displayHeight + 1));
      
      colorMode(RGB, 100);
      noSmooth();
      for (int i = lastY; i < pulseY; ++i) {
        float alpha = max(40, 100 * (i / (float)pulseY));
        stroke(0, 30, 50, alpha);
        line(0, i, displayWidth, i);
      }
      
      if (pulseElapsed > 1100) {
        // don't start a new pulse if we have a user
        if (this.isStopping()) {
          this.stopCompleted();
        } else {
          pulseStart = currentMillis;
        }
        lastY = 0;
      } else {
        lastY = pulseY;
      }
    } else if (type == PulsePatternType.Bounce) {
      
      if (velocity < 0 && velocity + 0.1 >= 0) {
        // don't start a new pulse if we have a user
        if (this.isStopping()) {
          this.stopCompleted();
        } else {
          pulseStart = currentMillis;
          lastY = 0;
          theHue = (int)random(100);
          velocity = 0;
          pos = 0;
        }
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
        line(0, y, displayWidth, y);
      }
      
      if (pos < 0) {
        
      } else {
        lastY = (int)pos;
      }
    }
    delay(20);
  }
}