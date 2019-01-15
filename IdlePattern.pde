public abstract class IdlePattern
{
  public int displayWidth;
  public int displayHeight;
  
  protected int startMillis = -1;
  protected int stopMillis = -1;
  
  public IdlePattern(int displayWidth, int displayHeight)
  {
    this.displayWidth = displayWidth;
    this.displayHeight = displayHeight;
  }
  
  public void startPattern()
  {
    this.startMillis = millis();
    this.stopMillis = -1;
  }
  
  public void lazyStop()
  {
    this.stopMillis = millis();
  }
  
  public final void stopCompleted()
  {
    this.stopMillis = -1;
    this.startMillis = -1;
  }
  
  public boolean isRunning()
  {
    return startMillis != -1 && this.isStopping() == false;
  }
  
  public boolean isStopping()
  {
    return this.stopMillis != -1;
  }
  
  public abstract void update();
}