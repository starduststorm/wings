public color lerpColorMod(color c1, color c2, float amt)
{
  pushStyle();
  colorMode(HSB, 100);
  amt = max(0.0, min(1.0, amt));
  float h1 = hue(c1), h2 = hue(c2);
  float s1 = saturation(c1), s2 = saturation(c2);
  float b1 = brightness(c1), b2 = brightness(c2);
  if (h1 > h2) {
    // loop hue around % 100, so lerpColorMod(color(90, 100, 100), color(0, 100, 100), 0.5) == color(95, 100, 100)
    h2 += 100;
  }
  float h = lerp(h1, h2, amt);
  float s = lerp(s1, s2, amt);
  float b = lerp(b1, b2, amt);
  color c = color(h % 100, s, b);
  popStyle();
  return c;
}

public class ChevronsPattern extends IdlePattern {
  float leadingEdge;
  float leadingValue;
  boolean useColor;
  
  public ChevronsPattern(int displayWidth, int displayHeight, boolean useColor)
  {
    super(displayWidth, displayHeight);
    this.useColor = useColor;
  }
  
  public void startPattern()
  {
    super.startPattern();
    leadingEdge = 0;
    leadingValue = (int)random(100);
  }
  
  private void lineGradient(float x1, float y1, float x2, float y2, color c1, color c2)
  {
    int mils = millis();
    float alpha = (mils - startMillis < 2000 ? 100 * (mils - startMillis) / 2000 : 100);
    colorMode(HSB, 100);
    
    final int segments = 32;
    
    float lastX = x1;
    float lastY = y1;
    for (int i = 1; i <= segments; ++i) {
      // Draw "segments", not points
      float x = x1 + i * (x2 - x1) / segments;
      float y = y1 + i * (y2 - y1) / segments;
      color c = lerpColorMod(c1, c2, i / (float)segments);
      stroke(c, alpha);
      line(lastX, lastY, x, y);
      lastX = x;
      lastY = y;
    }
  }
  
  public void update()
  {
    colorMode(HSB, 100);
    for (int i = 0 ; i < wingWidth * 2; ++i) {
      float chevronVertex = i;
      color startColor, endColor;
      if (useColor) {
        startColor = color((leadingValue + 5 * i) % 100, 100, 100);
        endColor = color((hue(startColor) + 40) % 100, 100, 100);
      } else {
        startColor = color(0, 0, 50 * sin(leadingValue + i) + 50);
        endColor = color(0, 0, 0);
      }
      
      clip(0, 0, wingWidth, displayHeight);
      lineGradient(wingWidth - chevronVertex, displayHeight / 2.0, wingWidth - chevronVertex + 4, 0, 
                  startColor, endColor);
      lineGradient(wingWidth - chevronVertex, displayHeight / 2.0, wingWidth - chevronVertex + 4, displayHeight, 
                  startColor, endColor);
      noClip();
      
      clip(wingWidth, 0, wingWidth, displayHeight);
      lineGradient(wingWidth + chevronVertex, displayHeight / 2.0, wingWidth + chevronVertex - 4, 0, 
                  startColor, endColor);
      lineGradient(wingWidth + chevronVertex, displayHeight / 2.0, wingWidth + chevronVertex - 4, displayHeight,
                  startColor, endColor);
      noClip();
    }
    
    if (useColor) {
      leadingValue = mod(leadingValue - 1, 100);
    } else {
      leadingValue -= 0.1;
    }
    
    leadingEdge = (leadingEdge + 0.1);
    if (leadingEdge > wingWidth) {
      leadingEdge -= wingWidth;
      if (this.isStopping()) {
        this.stopCompleted();
      }
    }
  }
}