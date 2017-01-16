public class ChevronsPattern extends IdlePattern {
  float leadingEdge;
  float leadingHue;
  
  public ChevronsPattern(int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
  }
  
  public void startPattern()
  {
    super.startPattern();
    leadingEdge = 0;
    leadingHue = (int)random(100);
  }
  
  private void lineGradient(float x1, float y1, float x2, float y2, int hue1, int hue2)
  {
    if (hue2 < hue1) {
      hue2 += 100;
    }
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
      int hue = (hue1 + i * (hue2 - hue1) / segments) % 100;
      stroke(hue, 100, 100, alpha);
      line(lastX, lastY, x, y);
      lastX = x;
      lastY = y;
    }
  }
  
  public void update()
  {
    //colorMode(HSB, 100);
    // FIXME: gradients are not quite right
    // Also, have modes where we go from white/color to black
    
    for (int i = 0 ; i < wingWidth * 2; ++i) {
      float chevronVertex = i;
      int startHue = (int)(leadingHue + 5 * i);
      int endHue = (int)(startHue + 40);
      
      clip(0, 0, wingWidth, displayHeight);
      lineGradient(wingWidth - chevronVertex, displayHeight / 2.0, wingWidth - chevronVertex + 4, 0, 
                  (int)leadingHue, endHue);
      lineGradient(wingWidth - chevronVertex, displayHeight / 2.0, wingWidth - chevronVertex + 4, displayHeight, 
                  (int)leadingHue, endHue);
      noClip();
      
      clip(wingWidth, 0, wingWidth, displayHeight);
      lineGradient(wingWidth + chevronVertex, displayHeight / 2.0, wingWidth + chevronVertex - 4, 0, 
                  (int)leadingHue, endHue);
      lineGradient(wingWidth + chevronVertex, displayHeight / 2.0, wingWidth + chevronVertex - 4, displayHeight,
                  (int)leadingHue, endHue);
      noClip();
    }
    
    leadingHue = mod(leadingHue - 1, 100);
    
    leadingEdge = (leadingEdge + 0.1);
    if (leadingEdge > wingWidth) {
      leadingEdge -= wingWidth;
      if (this.isStopping()) {
        this.stopCompleted();
      }
    }
  }
}