import processing.sound.*;

public class SpectrumPattern extends IdlePattern
{
  FFT fft;
  AudioIn audioIn;
  
  int audioBands;
  
  float[] audioSpectrum;
  float[] normalizedSpectrum;
  
  final float kVolumeThreshold = 3.5; // volume at which to start fading waveform out
  float volumeRunningAverage = 0;
  final int kVolumeFrameCount = 300; // how many frames to run the running average over
  
  boolean waveformVisible;
  
  float startStopMulti;
  
  public SpectrumPattern(int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
    audioBands = wingWidth;
    
    audioSpectrum = new float[audioBands];
    normalizedSpectrum = new float[audioBands];
    
    fft = new FFT(sketch, audioBands);
    audioIn = new AudioIn(sketch, 0);
    audioIn.start();
    fft.input(audioIn);
  }
  
  public void startPattern()
  {
    super.startPattern();
    startStopMulti = 1.0;
  }
  
  public void lazyStop()
  {
    super.lazyStop();
  }
  
  public void update()
  {
    if (this.isStopping()) {
      startStopMulti -= 0.01;
      if (startStopMulti <= 0.0) {
        this.stopCompleted();
        return;
      }
    } else if (millis() - startMillis < 2000) {
      startStopMulti = min(1.0, (millis() - startMillis) / 2000.0);
    }
    
    fft.analyze(audioSpectrum);
    
    float volumePeak = 0;
    float prevAmp = -1;
    for (int i = 0; i < audioBands; ++i) {
      // amplify and balance
      float moddedAudio = audioSpectrum[i] * displayHeight * 40;// * (i / 2.0 + 5);
      
      final float normCount = 5.0;
      normalizedSpectrum[i] = (normalizedSpectrum[i] * (normCount - 1) + moddedAudio) / normCount;

      if (audioSpectrum[i] > volumePeak) {
        volumePeak = normalizedSpectrum[i];
      }
    }
    
    volumeRunningAverage = (volumeRunningAverage * (kVolumeFrameCount - 1) + volumePeak) / kVolumeFrameCount;  
    
    float volumeWaveformAlpha = 100;
    
    if (volumeRunningAverage < kVolumeThreshold) {
      // fade waveform out if quiet for too long
      volumeWaveformAlpha = 100 * max(0, 5 * volumeRunningAverage / kVolumeThreshold - 4);
    }
    
    float waveformAlpha = 0.4 * volumeWaveformAlpha;
    waveformVisible = (waveformAlpha > 0);
    //if (!waveformVisible) {
    //  this.lazyStop();
    //  this.stopCompleted();
    //  return;
    //}
    
    blendMode(BLEND);
    colorMode(HSB, 100);
    
    for (int i = 0; i < audioBands; ++i) {
      float amp = normalizedSpectrum[i];
      amp *= startStopMulti;
      //if (amp > 2 * displayHeight / 3.0) {
      //  amp = log(amp - displayHeight / 2.) + displayHeight / 2.;
      //}
      
      // Flip upside down
      amp = displayHeight - amp;
      
      if (prevAmp != -1) {
        //float hue = (i + millis() / 100.0);
        float rangeMin = millis() / 1000.0;
        int rangeLen = 30;
        float hue = (i + millis() / 200.0 + rangeMin) % ((rangeMin + rangeLen) * 2);
        hue = (hue > (rangeMin + rangeLen) ? (rangeMin + rangeLen)*2 - hue : hue);
        //float hue = (amp * 6 + millis() / 100.0);
        stroke(hue % 100, 100, 100, waveformAlpha);
        
        color c1 = color(hue, 100, 20);
        color c2 = color((hue + 40 * (displayHeight - amp) / displayHeight) % 100, 100, 100);
        // FIXME: waveformAlpha
        //lineGradient(wingWidth + i, wingWidth, displayHeight + i, amp, c1, c2);
        //lineGradient(wingWidth - i - 1, wingWidth, displayHeight - i - 1, amp, c1, c2);
      }
      
      prevAmp = amp;
    }
  }
}