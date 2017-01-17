class FadeParityPattern extends IdlePattern {
  
  int lerpStartMillis = -1;
  
  color c1, c2;
  color oldc1, oldc2;
  
  public FadeParityPattern(int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
  }
  
  public void startPattern()
  {
    super.startPattern();
    lerpStartMillis = millis();
    newColors();
    oldc1 = #000000;
    oldc2 = #000000;
  }
  
  private void newColors()
  {
    colorMode(HSB, 100);
    oldc1 = c1;
    oldc2 = c2;
    do {
      c1 = color((int)random(100), 100, random(70) + 30);
      c2 = color((int)random(100), 100, random(70) + 30);
    } while (abs(hue(c1) - hue(c2)) < 10 || abs(hue(c1) - hue(c2)) > 90);  
  }
  
  public void update()
  {
    final float lerpDuration = 3000.0;
    
    int currentMillis = millis();
    
    int runningMillis = currentMillis - startMillis;
    int lerpRunningMillis = currentMillis - lerpStartMillis; 
    if (lerpRunningMillis > lerpDuration) {
      lerpStartMillis = currentMillis;
      lerpRunningMillis = lerpRunningMillis % (int)lerpDuration;
      newColors();
    }
    
    float alpha = 1.0;
    if (this.isStopping()) {
      float fadeMulti = (currentMillis - this.stopMillis) / 2000.0;
      if (fadeMulti >= 1.0) {
        this.stopCompleted();
      }
      alpha = 1.0 - fadeMulti;
    } else if (runningMillis < 3000) {
      alpha = runningMillis / 3000.0;
    }
    
    colorMode(HSB, 100);
    blendMode(BLEND);

    color lerpc1 = lerpColor(oldc1, c1, lerpRunningMillis / lerpDuration);
    color lerpc2 = lerpColor(oldc2, c2, lerpRunningMillis / lerpDuration);

    pushStyle();
    for (int w = 0; w < displayWidth; ++w) {
      for (int h = 0; h < displayHeight; ++h) {
        color lerpc = (h % 2 == 0 ? lerpc1 : lerpc2);
        stroke(hue(lerpc), saturation(lerpc), brightness(lerpc), 100 * alpha);
        point(w + 0.5, h + 0.5);
      }
    }
    popStyle();
  }
}